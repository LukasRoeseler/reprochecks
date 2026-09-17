# Python port of Schurgin, Wixted & Brady (2020) NHB analysis.
# Recompute headline statistics from archived MATLAB data using numpy/scipy.
import numpy as np
import scipy.io as sio
from scipy.special import i0e, i1e
from scipy.stats import norm
from scipy.optimize import minimize
import os, sys, math
import warnings
warnings.filterwarnings("ignore")
np.seterr(all='ignore')

WORK = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\work\j2h65"
MODEL = os.path.join(WORK, "Model")

def matlab_round(x):
    # MATLAB round: ties away from zero
    return np.sign(x) * np.floor(np.abs(x) + 0.5)

# ---------- circular statistics (port of MemToolbox) ----------
def sd2k(S):
    R = np.exp(-S**2 / 2.0)
    K = 1.0 / (R**3 - 4.0 * R**2 + 3.0 * R)
    K = np.where(R < 0.85, -0.4 + 1.39 * R + 0.43 / (1.0 - R), K)
    K = np.where(R < 0.53, 2.0 * R + R**3 + (5.0 * R**5) / 6.0, K)
    return K

def deg2k(sd):
    return sd2k(np.radians(sd))

from scipy.special import i1e
def k2sd(K):
    K = np.asarray(K, dtype=float)
    S = np.empty_like(K)
    S[K == 0] = np.inf
    S[np.isinf(K)] = 0.0
    mask = (K != 0) & (~np.isinf(K))
    S[mask] = np.sqrt(-2 * np.log(i1e(K[mask]) / i0e(K[mask])))
    return S

def k2deg(k):
    return np.degrees(k2sd(k))

def log_i0(k):
    # log(I0(k)) computed stably via scaled Bessel i0e (i0e(k)=exp(-|k|)I0(k))
    k = np.asarray(k, dtype=float)
    return np.log(i0e(np.abs(k))) + np.abs(k)

def vonmisespdf(x, mu, k):
    x = np.asarray(x, dtype=float)
    k = np.asarray(k, dtype=float)
    # log space to avoid overflow; log(besseli(0,k,1))+k == log(I0(k))
    return np.exp((k * np.cos(np.radians(x - mu))) - (np.log(360.0) + log_i0(k)))

def normpdf(x, mu, sd):
    return norm.pdf(x, mu, sd)

# ---------- TCC correlated model (uses precomputed pdf table) ----------
class TCCPrecomp:
    def __init__(self):
        v = sio.loadmat(os.path.join(MODEL, "TCCCorrelated_Precomputed.mat"))
        self.pdf = np.abs(v["pdf"])          # (nD, 360)
        self.dprimeList = v["dprimeList"].ravel()  # (nD,)

def tcc_max_like(errors, precomp):
    # c = round(errors + 180); c(c==0)=360; drop NaN
    err = np.asarray(errors, dtype=float).ravel()
    err = err[~np.isnan(err)]
    c = matlab_round(err + 180.0).astype(int)
    c[c == 0] = 360
    idx = c - 1  # 0-based
    loglike = np.zeros(precomp.pdf.shape[0])
    for i in range(precomp.pdf.shape[0]):
        p = precomp.pdf[i, idx]
        with np.errstate(divide='ignore'):
            loglike[i] = np.sum(np.log(p))
    best = int(np.argmax(loglike))
    return precomp.dprimeList[best], loglike[best]

def tcc_pdf_at_bins(vals, precomp, dprime):
    # model.pdf(struct('errors',vals), dprime) -> pdf at bin centers
    vals = np.asarray(vals, dtype=float).ravel()
    i = int(np.argmin(np.abs(dprime - precomp.dprimeList)))
    c = matlab_round(vals + 180.0).astype(int)
    c[c == 0] = 360
    return precomp.pdf[i, c - 1]

def tcc_loglike_at_dprime(errors, precomp, dprime):
    err = np.asarray(errors, dtype=float).ravel()
    err = err[~np.isnan(err)]
    c = matlab_round(err + 180.0).astype(int)
    c[c == 0] = 360
    idx = c - 1
    i = int(np.argmin(np.abs(dprime - precomp.dprimeList)))
    p = precomp.pdf[i, idx]
    return np.sum(np.log(p))

# ---------- discrete mixture models (port) ----------
def dsm_pdf(errors, g, sd):
    # Discrete standard mixture model pdf over bins -179..180
    xv = np.arange(-179, 181)
    pdf = (1.0 - g) * vonmisespdf(xv, 0, deg2k(sd)) + (g) * (1.0 / 360.0)
    pdf = pdf / pdf.sum()
    err = np.asarray(errors, dtype=float).ravel()
    err = err[~np.isnan(err)]
    c = matlab_round(err + 180.0).astype(int)
    c[c == 0] = 360
    return pdf[c - 1]

def dsm_loglike(errors, g, sd):
    p = dsm_pdf(errors, g, sd)
    return np.sum(np.log(p))

_DVP_STDS = np.linspace(0.5, 100, 500)
_DVP_KVALS = deg2k(_DVP_STDS).ravel()
_DVP_BASEK = log_i0(_DVP_KVALS)
_DVP_CURXVALS = np.arange(-179, 181, dtype=float)
_DVP_X = np.tile(_DVP_CURXVALS[:, None], (1, len(_DVP_KVALS)))
_DVP_K = np.tile(_DVP_KVALS[None, :], (len(_DVP_CURXVALS), 1))
_DVP_NEWBASEK = np.tile(_DVP_BASEK[None, :], (len(_DVP_CURXVALS), 1))
_DVP_V = np.exp((_DVP_K * np.cos(np.radians(_DVP_X))) - (np.log(360.0) + _DVP_NEWBASEK))

def dvp_pdf(errors, g, mnSTD, stdSTD):
    probEachSD = norm.pdf(_DVP_STDS, mnSTD, stdSTD)
    s = probEachSD.sum()
    if s <= 0:
        probEachSD = np.full_like(probEachSD, 1.0 / len(probEachSD))
    else:
        probEachSD = probEachSD / s
    probDataUnderThisNormal = (1.0 - g) * _DVP_V + (g) * (1.0 / 360.0)
    probEachSDBig = np.tile(probEachSD[None, :], (probDataUnderThisNormal.shape[0], 1))
    pdf = np.sum(probDataUnderThisNormal * probEachSDBig, axis=1)
    pdf = pdf / pdf.sum()
    err = np.asarray(errors, dtype=float).ravel()
    err = err[~np.isnan(err)]
    c = matlab_round(err + 180.0).astype(int)
    c[c == 0] = 360
    return pdf[c - 1]

def dvp_loglike(errors, g, mnSTD, stdSTD):
    p = dvp_pdf(errors, g, mnSTD, stdSTD)
    return np.sum(np.log(p))

# ---------- model comparison (port of ModelComparison_AIC_BIC) ----------
def model_comparison_AIC_BIC(dataLen, model_names, loglikes, k_vals):
    AIC = np.array([-2 * ll + 2 * k for ll, k in zip(loglikes, k_vals)])
    AICc = np.array([-2 * ll + 2 * k * (dataLen / (dataLen - k - 1)) for ll, k in zip(loglikes, k_vals)])
    BIC = np.array([-2 * ll + (np.log(dataLen) + np.log(2 * np.pi)) * k for ll, k in zip(loglikes, k_vals)])
    return AIC, BIC, np.array(loglikes), AICc

# ---------- R^2 (port of GetModelRSquared / ContinuousReport) ----------
def model_r_squared(errors, model_pdf_fn):
    NumberOfBins = 40
    x = np.linspace(-180, 180, NumberOfBins + 1)
    x = x[:-1] + (x[1] - x[0]) / 2.0
    # histogram of data over these bins
    n, _ = np.histogram(errors, bins=np.linspace(-180, 180, NumberOfBins + 1))
    # model pdf evaluated at bin centers (binned, normalized)
    model_pdf = model_pdf_fn(x)
    model_pdf = model_pdf / model_pdf.sum()
    data_pdf = n / n.sum()
    r = np.corrcoef(data_pdf, model_pdf)[0, 1]
    return r * r, r

# ---------- psychophysical scaling (port of FitTriadData) ----------
def fit_triad():
    d = sio.loadmat(os.path.join(WORK, "Figure1", "F", "ColorTriadData.mat"))
    allData = d["allData"]  # (n,3): dist closer, dist further, choice
    posOffsets = np.array([0, 3, 5, 8, 10, 13, 15, 20, 25, 30, 35, 45,
                           55, 65, 75, 85, 100, 120, 140, 160, 180], dtype=float)
    dataAsIndex = np.zeros(allData.shape)
    for i in range(allData.shape[0]):
        dataAsIndex[i, 0] = np.where(posOffsets == allData[i, 0])[0][0] + 1
        dataAsIndex[i, 1] = np.where(posOffsets == allData[i, 1])[0][0] + 1
        dataAsIndex[i, 2] = allData[i, 2]

    startParams = np.diff(posOffsets) / 100.0

    idx0 = (dataAsIndex[:, 0] - 1).astype(int)
    idx1 = (dataAsIndex[:, 1] - 1).astype(int)
    choice = dataAsIndex[:, 2]

    def model_like(p):
        prefix = np.concatenate([[0.0], np.cumsum(p)])
        diffLength = prefix[idx1] - prefix[idx0]
        cdfVal = norm.cdf(diffLength, 0, 1)
        cdfVal = np.clip(cdfVal, 1e-300, 1 - 1e-300)
        loglike = np.sum(choice * np.log(cdfVal) + (1 - choice) * np.log(1 - cdfVal))
        return -loglike

    res = minimize(model_like, startParams, method="Nelder-Mead",
                   options={"maxiter": 100000, "xatol": 1e-10, "fatol": 1e-10})
    bestFit = res.x
    rescaledOffsets = 1.0 - np.concatenate([[0.0], np.cumsum(bestFit)])
    return posOffsets, rescaledOffsets, res.fun

def _clip(p):
    return np.clip(p, 1e-300, None)

# ---------- MLE fitting (port of MemToolbox MLE) ----------
def fit_mle(errors, nll_fn, starts, bounds, method="L-BFGS-B"):
    best_ll = -np.inf
    best_p = None
    for st in starts:
        res = minimize(nll_fn, np.asarray(st, dtype=float), method=method,
                       bounds=bounds, options={"maxiter": 100000, "maxfun": 100000})
        if res.success or True:
            ll = -res.fun
            if ll > best_ll:
                best_ll = ll
                best_p = res.x
    return best_p, best_ll

def fit_dsm(errors):
    def nll(p):
        g, sd = p
        return -dsm_loglike(errors, g, sd)
    starts = [[0.2, 10], [0.4, 15], [0.1, 20]]
    bounds = [(0.0, 1.0), (0.0, None)]
    return fit_mle(errors, nll, starts, bounds)

def fit_dvp(errors):
    def nll(p):
        g, mnSTD, stdSTD = p
        return -dvp_loglike(errors, g, mnSTD, stdSTD)
    starts = [[0.0, 15, 5], [0.2, 20, 10], [0.1, 10, 2], [0.2, 30, 3]]
    bounds = [(0.0, 1.0), (0.0, 100.0), (0.0, 100.0)]
    return fit_mle(errors, nll, starts, bounds)

if __name__ == "__main__":
    precomp = TCCPrecomp()
    print("dprimeList range:", precomp.dprimeList[0], "..", precomp.dprimeList[-1], "n=", len(precomp.dprimeList))

    # sanity: dsm pdf sums to 1
    xv = np.arange(-179, 181)
    print("DSM pdf sum (g=0.2,sd=10):", dsm_pdf(xv, 0.2, 10.0).sum())
    print("DVP pdf sum (g=0.2,mn=15,std=5):", dvp_pdf(xv, 0.2, 15.0, 5.0).sum())

    # Figure3: in-lab high set size
    d = sio.loadmat(os.path.join(WORK, "Figure3", "A_InLabHighSetSize.mat"))
    errors = d["errors"]
    setSize = d["setSize"]
    ssList = [1, 3, 6, 8]
    print("\n=== Figure 3A: In-lab high set size ===")
    for ss in ssList:
        mask = setSize == ss
        err = errors[mask].ravel()
        dprime, ll = tcc_max_like(err, precomp)
        r2, r = model_r_squared(err, lambda x: tcc_pdf_at_bins(x, precomp, dprime))
        print(f"  set size {ss}: n={len(err)}  d'={dprime:.4f}  R^2={r2:.4f} (r={r:.4f})")

    # Figure3: Group model comparisons (BIC)
    print("\n=== Figure 3: Group model comparison (BIC) ===")
    for ss in ssList:
        mask = setSize == ss
        err = errors[mask].ravel()
        n = len(err)
        dprime, tcc_ll = tcc_max_like(err, precomp)
        mixp, mixll = fit_dsm(err)
        varp, varl = fit_dvp(err)
        loglikes = [tcc_ll, mixll, varl]
        ks = [1, 2, 3]
        AIC, BIC, LL, AICc = model_comparison_AIC_BIC(n, ["TCC", "DSM", "DVP"], loglikes, ks)
        BICdiffs = BIC[0] - BIC
        print(f"  set size {ss}: TCC d'={dprime:.3f} | DSM g={mixp[0]:.3f} sd={mixp[1]:.3f} | DVP g={varp[0]:.3f} mn={varp[1]:.3f} std={varp[2]:.3f}")
        print(f"    LL: TCC={tcc_ll:.2f} DSM={mixll:.2f} DVP={varl:.2f}")
        print(f"    BIC: TCC={BIC[0]:.2f} DSM={BIC[1]:.2f} DVP={BIC[2]:.2f}   BICdiff(TCC-other)={np.round(BICdiffs,3)}")

    # Figure1/F: psychophysical scaling via triad task
    print("\n=== Figure 1/F: Triad task psychophysical scaling ===")
    posOffsets, rescaledOffsets, nll = fit_triad()
    for a, b in zip(posOffsets, rescaledOffsets):
        print(f"  dist {int(a):4d}  sim {b:.4f}")
    print("  final nll:", nll)

    # Figure3 B: delay time d' values
    print("\n=== Figure 3B: In-lab delay time ===")
    d = sio.loadmat(os.path.join(WORK, "Figure3", "B_InLabDelayTime.mat"))
    errors = d["errors"]; setSize = d["setSize"]; delay = d["delay"]
    delayTimes = [1, 3, 5]; setSizes = [1, 3, 6]
    for ss in setSizes:
        for dt in delayTimes:
            mask = (setSize == ss) & (delay == dt)
            err = errors[mask].ravel()
            dprime, ll = tcc_max_like(err, precomp)
            print(f"  SS {ss}, delay {dt}: d'={dprime:.4f}")

    # Figure3 C: encoding time d' values
    print("\n=== Figure 3C: In-lab encoding time ===")
    d = sio.loadmat(os.path.join(WORK, "Figure3", "C_InLabEncodingTime.mat"))
    errors = d["errors"]; setSize = d["setSize"]; encTime = d["encodingTime"]
    encTimes = [0.1, 0.5, 1.5]; setSizes = [1, 3, 6]
    for ss in setSizes:
        for et in encTimes:
            mask = (setSize == ss) & (encTime == et)
            err = errors[mask].ravel()
            dprime, ll = tcc_max_like(err, precomp)
            print(f"  SS {ss}, enc {et}: d'={dprime:.4f}")

    # Figure3 IndividualSubjectFits: mean d' per set size
    print("\n=== Figure 3: Individual subject d' (mean +/- SD per set size) ===")
    d = sio.loadmat(os.path.join(WORK, "Figure3", "A_InLabHighSetSize.mat"))
    errors = d["errors"]; setSize = d["setSize"]
    ssList = [1, 3, 6, 8]
    for ss in ssList:
        dsub = []
        for s in range(errors.shape[0]):
            err = errors[s, setSize[s, :] == ss].ravel()
            dprime, ll = tcc_max_like(err, precomp)
            dsub.append(dprime)
        dsub = np.array(dsub)
        print(f"  SS {ss}: mean d'={dsub.mean():.3f}  SD={dsub.std():.3f}")

    # Figure5 BayesFactorCalc (nAFC generalization)
    print("\n=== Figure 5: Bayes factor (TCC signal-detection vs mixture model) ===")
    d = sio.loadmat(os.path.join(WORK, "Figure5", "ColorNAFCData.mat"))
    dEst = sio.loadmat(os.path.join(WORK, "Figure5", "dPrimeUncertaintyGiven2AFC.mat"))
    errorAngle = d["errorAngle"]; nAFC = d["nAFC"]
    probAnyOutcome = dEst["probAnyOutcome"]  # (51,601)
    numCorrectList = dEst["numCorrectList"].ravel()
    dList = dEst["dList"].ravel()
    tccLL = []; mixLL = []
    for s in range(errorAngle.shape[0]):
        numCorrect180 = int(np.sum(np.abs(errorAngle[s, nAFC[s, :] == 2]) < 1))
        probEachD = probAnyOutcome[numCorrectList == numCorrect180, :].ravel()
        err = errorAngle[s, nAFC[s, :] == 360].ravel()
        tccByD = np.array([tcc_loglike_at_dprime(err, precomp, dd) for dd in dList])
        tccLL.append(np.log(np.sum(np.exp(tccByD + np.log(probEachD)))))
        avg180 = np.mean(np.abs(errorAngle[s, nAFC[s, :] == 2]) < 1)
        gRate = 1 - (2 * avg180 - 1)
        if gRate > 1: gRate = 1
        ks = np.arange(1, 201); sds = k2deg(ks)
        mixBySD = np.array([np.sum(np.log(dsm_pdf(err, gRate, sdv))) for sdv in sds])
        mixLL.append(np.log(np.sum(np.exp(mixBySD + np.log(1.0 / len(sds))))))
    BF = np.sum(tccLL) - np.sum(mixLL)
    print(f"  log BF (TCC - mixture), sum over subjects = {BF:.3f}  (exp(BF) = {np.exp(BF):.4g})")

    # Figure4/C BayesFactorCalc (offset 2AFC)
    print("\n=== Figure 4C: Bayes factor (offset 2AFC, signal-detection vs mixture) ===")
    d = sio.loadmat(os.path.join(WORK, "Figure4", "C", "OffsetVariedAFC.mat"))
    dEst = sio.loadmat(os.path.join(WORK, "Figure4", "C", "dPrimeUncertaintyGiven2AFC.mat"))
    eB = sio.loadmat(os.path.join(WORK, "Figure4", "C", "ExpectedNumCorrectGivenEachD_BayesFac.mat"))
    errorAngle = d["errorAngle"]; offsetAFC = d["offsetAFC"]
    allAFCs = [12, 24, 72, 180]
    probAnyOutcome = dEst["probAnyOutcome"]; numCorrectList = dEst["numCorrectList"].ravel()
    expCorrect = eB["expectationAboutCorrect"].ravel()  # cell array (4,)
    numCorrectBySub = np.zeros((len(allAFCs), errorAngle.shape[0]))
    for c, afc in enumerate(allAFCs):
        for s in range(errorAngle.shape[0]):
            numCorrectBySub[c, s] = np.sum(np.abs(errorAngle[s, offsetAFC[s, :] == afc]) < 1)
    likeObserved = np.zeros((len(allAFCs), errorAngle.shape[0]))
    for c, afc in enumerate(allAFCs):
        ec = np.asarray(expCorrect[c])  # (601,51)
        for s in range(errorAngle.shape[0]):
            numCorrect180 = int(np.sum(np.abs(errorAngle[s, offsetAFC[s, :] == 180]) < 1))
            probEachD = probAnyOutcome[numCorrectList == numCorrect180, :].ravel()  # (601,)
            expNumCorr = np.mean(probEachD * ec.T, axis=1)  # (51,)
            expNumCorr = expNumCorr / expNumCorr.sum()
            likeObserved[c, s] = expNumCorr[int(numCorrectBySub[c, s])]
    tccLLsub = np.sum(np.log(likeObserved[0:3, :]), axis=0)
    mixLLsub = np.zeros(errorAngle.shape[0])
    for s in range(errorAngle.shape[0]):
        avg180 = np.mean(np.abs(errorAngle[s, offsetAFC[s, :] == 180]) < 1)
        gRate = 1 - (2 * avg180 - 1)
        if gRate > 1: gRate = 1
        ks = np.arange(1, 201); sds = k2deg(ks)
        pdfMeasure = np.linspace(-180, 180, 180)
        likelist = []
        for c, afc in enumerate(allAFCs[:3]):
            leftPt = afc / 2.0; rightPt = afc / 2.0 + 180
            if rightPt > 180: rightPt -= 360
            mlike = np.zeros(len(sds))
            for i, sdv in enumerate(sds):
                y = dsm_pdf(pdfMeasure, gRate, sdv)
                cdfVals = np.cumsum(y) * (pdfMeasure[1] - pdfMeasure[0])
                cdfVals = cdfVals / cdfVals[-1]
                leftCDF = np.interp(leftPt, pdfMeasure, cdfVals)
                rightCDF = np.interp(rightPt, pdfMeasure, cdfVals)
                theta = abs(rightCDF - leftCDF)
                mlike[i] = math.comb(50, int(numCorrectBySub[c, s])) * theta ** int(numCorrectBySub[c, s]) * (1 - theta) ** (50 - int(numCorrectBySub[c, s]))
            likelist.append(np.sum((1.0 / len(sds)) * mlike))
        mixLLsub[s] = np.sum(np.log(np.array(likelist)))
    BF4 = np.sum(tccLLsub) - np.sum(mixLLsub)
    print(f"  log BF (TCC - mixture), sum over subjects = {BF4:.3f}  (exp(BF) = {np.exp(BF4):.4g})")

    # Psychophysical scaling parameters used by the model (stored confusion vectors)
    print("\n=== Psychophysical scaling parameters (stored confusion vectors) ===")
    c = sio.loadmat(os.path.join(MODEL, "Color_ConfusionVector.mat"))
    cv = c["confusionVector"].ravel(); cx = c["confusionX"].ravel()
    t = sio.loadmat(os.path.join(MODEL, "OtherScaling", "Color_TriadConfusionVector.mat"))
    tv = t["confusionVector"].ravel(); tx = t["confusionX"].ravel()
    print("  dist  LikertConfVec  TriadConfVec")
    for dd in [0, 5, 10, 20, 30, 45, 60, 90, 120, 150, 180]:
        i = int(np.argmin(np.abs(cx - dd))); j = int(np.argmin(np.abs(tx - dd)))
        print(f"  {dd:4d}  {cv[i]:.4f}          {tv[j]:.4f}")
    # FitNAFC: overall d' from percent correct
    d = sio.loadmat(os.path.join(WORK, "Figure5", "ColorNAFCData.mat"))
    pcc = d["percentCorrectByCond"]
    overallPC = np.mean(pcc, axis=0)
    from scipy.stats import norm as _norm
    overallD = (_norm.ppf(overallPC[0]) - _norm.ppf(1 - overallPC[0])) / np.sqrt(2)
    print(f"\n=== Figure 5 FitNAFC: overall d' from nAFC percent correct ===")
    print(f"  mean percentCorrect (by cond): {np.round(overallPC,4)}")
    print(f"  overall d' (2AFC, SD-2AFC formula) = {overallD:.4f}")
