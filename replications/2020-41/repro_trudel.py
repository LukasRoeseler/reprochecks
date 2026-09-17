import math
import numpy as np
from scipy.io import loadmat
from scipy.stats import norm, ttest_1samp, t as tdist
import statsmodels.api as sm
from statsmodels.robust.norms import TukeyBiweight

pi = math.pi
DEG = 180.0 / pi
NSUB = 24
NTR = 45
NPRED = 24

def getf(obj, name):
    if hasattr(obj, name):
        return getattr(obj, name)
    return obj[name]

def col(mat, names, name):
    return np.asarray(mat[:, list(names).index(name)], dtype=float)

def zscore(x, ddof=1):
    x = np.asarray(x, dtype=float)
    s = np.nanstd(x, ddof=ddof)
    if s == 0 or np.isnan(s):
        return x - np.nanmean(x)
    return (x - np.nanmean(x)) / s

# ---------------- Bayesian model ----------------
def build_predmat(log, ntr, npred):
    mat = np.array(getf(log, 'mat'))
    names = list(getf(log, 'names'))
    choice = col(mat, names, 'choice').astype(int)
    diff_advflo = col(mat, names, 'diff_advflo')
    obs_deg = diff_advflo * DEG
    predmat = np.full((ntr, npred), np.nan)
    occ = np.zeros(npred, dtype=int)
    for t in range(len(choice)):
        p = int(choice[t]) - 1
        if occ[p] < ntr:
            predmat[occ[p], p] = obs_deg[t]
            occ[p] += 1
    return predmat

def bayesian_estimates(Dist, sigma):
    maxDist = Dist.max()
    idx = np.where(Dist == maxDist)[0]
    if len(idx) == len(sigma):
        maxval_acc = sigma[-1] / 2.0
    else:
        maxval_acc = sigma[idx[0]]
    cum = np.cumsum(Dist)
    low_conds = np.where(np.round(cum, 3) <= 0.0250)[0]
    lowfinal = (low_conds.max() + 1) if len(low_conds) else 0
    up_conds = np.where(np.round(cum, 3) >= 0.9750)[0]
    upfinal = (up_conds.min() + 1) if len(up_conds) else 0
    unc_range = abs(upfinal - lowfinal)
    return maxval_acc, unc_range

def bayes_update(sigma, priorDist, obs):
    likelihood = norm.pdf(obs, 0, sigma)
    priorDist = priorDist.reshape(sigma.shape)
    post = priorDist * likelihood
    s = post.sum()
    return post / s

def run_bayesian(log, ntr, npred):
    sigma = np.arange(1, 141)
    flat_prior = np.full(len(sigma), 1.0 / len(sigma))
    predmat = build_predmat(log, ntr, npred)
    comb_acc = np.full((ntr + 1, npred), np.nan)
    comb_unc = np.full((ntr + 1, npred), np.nan)
    for p in range(npred):
        obs = predmat[:, p]
        obs = obs[~np.isnan(obs)]
        n = len(obs)
        Prior_acc = np.full(n, np.nan); Post_acc = np.full(n, np.nan)
        Prior_unc = np.full(n, np.nan); Post_unc = np.full(n, np.nan)
        priorDist = flat_prior.copy()
        for io in range(n):
            ma, unc = bayesian_estimates(priorDist, sigma)
            Prior_acc[io] = ma; Prior_unc[io] = unc
            postDist = bayes_update(sigma, priorDist, obs[io])
            ma2, unc2 = bayesian_estimates(postDist, sigma)
            Post_acc[io] = ma2; Post_unc[io] = unc2
            priorDist = postDist
        if n == 0:
            ma, unc = bayesian_estimates(flat_prior, sigma)
            Prior_acc = np.array([ma]); Prior_unc = np.array([unc])
        comb_acc[0, p] = -Prior_acc[0]
        comb_unc[0, p] = Prior_unc[0]
        if n > 0:
            comb_acc[1:n + 1, p] = -Post_acc[0:n]
            comb_unc[1:n + 1, p] = Post_unc[0:n]
    return comb_acc, comb_unc

# ---------------- transform_bayesian ----------------
def transform_bayesian(log, pred_order, ntr, npred, comb_acc, comb_unc):
    mat = np.array(getf(log, 'mat'))
    names = list(getf(log, 'names'))
    choice = col(mat, names, 'choice').astype(int)
    pred_order = np.array(pred_order).astype(int)
    nt = len(choice)

    def process(comb):
        dat = np.full((nt, 2), np.nan)
        chosen_mat = np.full((nt, 1), np.nan)
        nonchosen_mat = np.full((nt, 1), np.nan)
        pred_idx = np.ones(npred, dtype=int)
        leftright = np.zeros(nt, dtype=int)
        for i in range(nt):
            left = pred_order[i, 0]; right = pred_order[i, 1]
            cid = int(choice[i])
            chosen_side = 1 if cid == left else 2
            leftright[i] = chosen_side
            row = pred_idx[cid - 1] - 1
            dat[i, chosen_side - 1] = comb[row, cid - 1]
            chosen_mat[i, 0] = comb[row, cid - 1]
            nonchosen_side = 3 - chosen_side
            ncid = int(pred_order[i, nonchosen_side - 1])
            dat[i, nonchosen_side - 1] = comb[pred_idx[ncid - 1] - 1, ncid - 1]
            nonchosen_mat[i, 0] = comb[pred_idx[ncid - 1] - 1, ncid - 1]
            pred_idx[cid - 1] += 1
        return dat, chosen_mat, nonchosen_mat, leftright

    dat_a, ch_a, nch_a, leftright = process(comb_acc)
    dat_u, ch_u, nch_u, _ = process(comb_unc)
    return {
        'maxval_acc': {'dat': dat_a, 'chosen_mat': ch_a, 'nonchosen_mat': nch_a},
        'unc_range': {'dat': dat_u, 'chosen_mat': ch_u, 'nonchosen_mat': nch_u},
        'leftright': leftright,
    }

# ---------------- get_regs ----------------
def get_regs(log, transform):
    mat = np.array(getf(log, 'mat'))
    names = list(getf(log, 'names'))
    leftright = transform['leftright']
    choice = leftright.copy()
    choice[choice == 2] = 0
    acc_left = transform['maxval_acc']['dat'][:, 0]
    acc_right = transform['maxval_acc']['dat'][:, 1]
    unc_left = transform['unc_range']['dat'][:, 0]
    unc_right = transform['unc_range']['dat'][:, 1]
    diff_acc = acc_left - acc_right
    diff_unc = unc_left - unc_right
    chosen_acc = transform['maxval_acc']['chosen_mat'][:, 0]
    chosen_unc = transform['unc_range']['chosen_mat'][:, 0]
    unchosen_acc = transform['maxval_acc']['nonchosen_mat'][:, 0]
    unchosen_unc = transform['unc_range']['nonchosen_mat'][:, 0]
    chounch_acc = chosen_acc - unchosen_acc
    chounch_unc = chosen_unc - unchosen_unc
    blocknr = col(mat, names, 'blocknr')
    blocktime = []; blockidx = []
    blockorder = np.where(blocknr != 0)[0]
    for ib in blockorder:
        curit = int(blocknr[ib])
        if curit in (1, 4):
            idx = 45
        elif curit in (2, 5):
            idx = 30
        elif curit in (3, 6):
            idx = 15
        blocktime.extend(np.sort(np.arange(1, idx + 1))[::-1] / float(idx))
        blockidx.extend([curit] * idx)
    blocktime = np.array(blocktime)
    blockidx = np.array(blockidx)
    CI_curstep = col(mat, names, 'curstep')
    diff_accxblocktime = zscore(diff_acc) * zscore(blocktime)
    diff_uncxblocktime = zscore(diff_unc) * zscore(blocktime)

    names_order = ['choice', 'acc_left', 'acc_right', 'unc_left', 'unc_right',
                   'diff_acc', 'diff_unc', 'chosen_acc', 'chosen_unc',
                   'unchosen_acc', 'unchosen_unc', 'chounch_acc', 'chounch_unc',
                   'blocktime', 'cisize', 'diff_accxblocktime', 'diff_uncxblocktime', 'blockidx']
    cols = [choice, acc_left, acc_right, unc_left, unc_right, diff_acc, diff_unc,
            chosen_acc, chosen_unc, unchosen_acc, unchosen_unc, chounch_acc, chounch_unc,
            blocktime, CI_curstep, diff_accxblocktime, diff_uncxblocktime, blockidx]
    pmat = np.column_stack(cols)
    return pmat, names_order

def get_from_mat(pmat, names, topick):
    if not isinstance(topick, (list, tuple)):
        topick = [topick]
    inds = [names.index(x) for x in topick]
    return pmat[:, inds]

# ---------------- GLMs ----------------
def fit_logit(reg, y):
    X = sm.add_constant(reg)
    model = sm.GLM(y, X, family=sm.families.Binomial())
    return model.fit().params

def fit_ols(reg, y):
    X = sm.add_constant(reg)
    model = sm.GLM(y, X, family=sm.families.Gaussian())
    return model.fit().params

def fit_robust(reg, y):
    X = sm.add_constant(reg)
    rlm = sm.RLM(y, X, M=TukeyBiweight())
    return rlm.fit().params

def behav_glm(pmat, names, run):
    allval = {}
    if run[0] == 1:
        pickregs = ['diff_acc', 'diff_unc', 'blocktime', 'diff_uncxblocktime', 'diff_accxblocktime']
        reg = np.column_stack([zscore(get_from_mat(pmat, names, [r])[:, 0]) for r in pickregs])
        choice = get_from_mat(pmat, names, ['choice'])[:, 0]
        allval[1] = {'betas': fit_logit(reg, choice), 'regnames': pickregs}
    if run[1] == 1:
        pickregs = ['diff_acc', 'diff_unc']
        blockidx = get_from_mat(pmat, names, ['blockidx'])[:, 0].astype(int)
        halves = split_blockhalves(blockidx)
        betas = {}
        for ib in (1, 2):
            idx = halves[ib]
            reg = np.column_stack([zscore(get_from_mat(pmat, names, [r])[idx, 0]) for r in pickregs])
            choice = get_from_mat(pmat, names, ['choice'])[idx, 0]
            betas[ib] = fit_logit(reg, choice)
        allval[2] = {'betas': betas, 'regnames': pickregs}
    if run[2] == 1:
        pickregs = ['diff_acc', 'diff_unc']
        blockidx = get_from_mat(pmat, names, ['blockidx'])[:, 0].astype(int)
        horizons = split_timehorizon(blockidx)
        betas = {}
        for ib in (1, 2, 3):
            idx = horizons[ib]
            reg = np.column_stack([zscore(get_from_mat(pmat, names, [r])[idx, 0]) for r in pickregs])
            choice = get_from_mat(pmat, names, ['choice'])[idx, 0]
            betas[ib] = fit_robust(reg, choice)
        allval[3] = {'betas': betas, 'regnames': pickregs}
    if run[3] == 1:
        pickregs = ['chosen_acc', 'chosen_unc']
        reg = np.column_stack([zscore(get_from_mat(pmat, names, [r])[:, 0]) for r in pickregs])
        Cinterval = get_from_mat(pmat, names, ['cisize'])[:, 0]
        allval[4] = {'betas': fit_ols(reg, Cinterval), 'regnames': pickregs}
    return allval

def split_blockhalves(blockidx):
    half1 = []; half2 = []
    for bidx in range(1, 7):
        btrials = np.where(blockidx == bidx)[0]
        bsize = len(btrials)
        splitidx = int(np.floor(bsize / 2.0 + 0.5))  # MATLAB round (half away from zero)
        half1.extend(btrials[:splitidx])
        half2.extend(btrials[splitidx:])
    return {1: np.sort(np.array(half1)), 2: np.sort(np.array(half2))}

def split_timehorizon(blockidx):
    trials = {}
    for ib in range(1, 7):
        curidx = np.where(blockidx == ib)[0]
        trials[ib] = curidx[:15]
    return {1: np.sort(np.concatenate([trials[1], trials[4]])),
            2: np.sort(np.concatenate([trials[2], trials[5]])),
            3: np.sort(np.concatenate([trials[3], trials[6]]))}

def summary(betas_matrix, names):
    # betas_matrix: nsub x k
    out = []
    for j in range(len(names)):
        b = betas_matrix[:, j]
        t, p = ttest_1samp(b, 0)
        d = np.mean(b) / np.std(b, ddof=1)
        se = np.std(b, ddof=1) / np.sqrt(len(b))
        ci = (np.mean(b) - 2.0687 * se, np.mean(b) + 2.0687 * se)  # t(23) 2.5% = 2.0687
        out.append((names[j], np.mean(b), np.std(b, ddof=1), t, p, d, ci))
    return out

def main():
    d = loadmat('DATA_ntrudelEtAl_2020.mat', squeeze_me=True, struct_as_record=False)
    s = d['s']
    run = [1, 1, 1, 1]
    cond = []
    for ci in range(len(s.cond)):
        m = s.cond[ci]
        subs = []
        for isub in range(NSUB):
            sub = m.sub[isub]
            log = getf(sub, 'logfile')
            pred_order = getf(sub, 'pred_order')
            comb_acc, comb_unc = run_bayesian(log, NTR, NPRED)
            transform = transform_bayesian(log, pred_order, NTR, NPRED, comb_acc, comb_unc)
            pmat, names = get_regs(log, transform)
            allval = behav_glm(pmat, names, run)
            subs.append({'pmat': pmat, 'names': names, 'allval': allval})
        cond.append({'subs': subs, 'Btype': getf(m, 'Btype')})
    return cond

if __name__ == '__main__':
    cond = main()
    print('done')
