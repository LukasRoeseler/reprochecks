import numpy as np

def orth(rs, n1, k):
    Q, _ = np.linalg.qr(rs.randn(n1, k))
    return Q

def pca_full_vb(X, ncomp, maxiters=30, seed=2, hp=0.001):
    """Port of PCAMV pca_full.m (variational Bayesian PCA) for a dense matrix
    with NaN as missing values. Returns A (n1,ncomp), S (ncomp,n2), Mu (n1,), V.
    Model: X(:,j) = Mu + A*S(:,j) + noise, isotropic noise variance V."""
    rs = np.random.RandomState(seed)
    X = np.array(X, dtype=np.float64)
    n1, n2 = X.shape
    M = ~np.isnan(X)
    Xc = np.where(M, X, 0.0).copy()  # NaN->0, mask in M

    # init
    A = orth(rs, n1, ncomp)
    S = rs.randn(ncomp, n2)
    Nobs_i = M.sum(axis=1).astype(np.float64)
    Mu = np.where(Nobs_i > 0, Xc.sum(axis=1) / np.maximum(Nobs_i, 1), 0.0)
    V = 1.0
    Av = np.repeat(np.eye(ncomp)[None, :, :], n1, axis=0)   # (n1,k,k)
    Sv = np.repeat(np.eye(ncomp)[None, :, :], n2, axis=0)   # (n2,k,k)
    Muv = np.ones(n1)
    Va = 1000.0 * np.ones(ncomp)
    Vmu = 1000.0

    # subtract initial Mu
    Xc = Xc - Mu[:, None] * M
    ndata = M.sum()
    errMx = Xc - A @ S
    rms = np.sqrt((errMx ** 2).sum() / ndata)

    I_k = np.eye(ncomp)
    M_T = M.T.astype(np.float64)   # (n2,n1)
    Xc_T = Xc.T                    # (n2,n1)

    for it in range(maxiters):
        # ---- bias update (uses errMx from previous compute_rms) ----
        dMu = errMx.sum(axis=1) / Nobs_i
        Muv = V / (Nobs_i + V / Vmu)
        th = 1.0 / (1.0 + V / Nobs_i / Vmu)
        Mu_old = Mu
        Mu = th * (Mu + dMu)
        dMu_actual = Mu - Mu_old
        Xc = Xc - dMu_actual[:, None] * M

        # ---- update S ----
        # W_A[i] = A_i A_i' + Av[i]
        W_A = np.einsum('ia,ib->iab', A, A) + Av          # (n1,k,k)
        Psi = np.einsum('ji,iab->jab', M_T, W_A) + V * I_k  # (n2,k,k)
        AXT = np.einsum('ji,ji,ia->ja', M_T, Xc_T, A)       # (n2,k)
        S = np.linalg.solve(Psi, AXT[:, :, None])[:, :, 0].T  # (k,n2)
        invPsi = np.linalg.inv(Psi)
        Sv = V * invPsi

        # ---- rotate to PCA ----
        mS = S.mean(axis=1, keepdims=True)
        dMu_rot = A @ mS
        S = S - mS
        covS = S @ S.T + Sv.sum(axis=0)
        covS = covS / n2
        D, VS = np.linalg.eigh(covS)      # ascending
        # guard negative (numerical)
        D = np.maximum(D, 0)
        RA = VS @ np.diag(np.sqrt(D))
        A = A @ RA
        Av = np.einsum('ba,iac,cd->ibd', RA, Av, RA)   # Av_i <- RA' Av_i RA
        covA = A.T @ A + Av.sum(axis=0)
        covA = covA / n1
        DA, VA = np.linalg.eigh(covA)
        idx = np.argsort(-DA)
        DA = DA[idx]
        VA = VA[:, idx]
        A = A @ VA
        Av = np.einsum('ba,iac,cd->ibd', VA, Av, VA)
        R = VA.T @ np.diag(1.0 / np.sqrt(D)) @ VS.T
        S = R @ S
        Sv = np.einsum('ab,jbc,dc->jad', R, Sv, R)
        # bias from rotation
        if True:
            Xc = Xc - dMu_rot * M
            Mu = Mu + dMu_rot.ravel()

        # ---- update A ----
        W_S = np.einsum('ia,ib->iab', S.T, S.T) + Sv       # (n2,k,k)
        Phip = np.einsum('ij,jab->iab', M, W_S) + np.diag(V / Va)  # (n1,k,k)
        AXTA = np.einsum('ij,ij,ja->ia', M, Xc, S.T)         # (n1,k)
        A = np.linalg.solve(Phip, AXTA[:, :, None])[:, :, 0]  # (n1,k)
        invPhip = np.linalg.inv(Phip)
        Av = V * invPhip

        # ---- compute rms ----
        errMx = Xc - A @ S
        rms = np.sqrt((errMx ** 2).sum() / ndata)

        # ---- update V (efficient frobenius accumulation) ----
        # Term1 = sum_j <A_j'*A_j, Sv_j>
        A_ATA = np.einsum('ia,ib->iab', A, A)                 # (n1,k,k)
        # A_j'*A_j for column j = sum_{i obs j} A_i A_i'
        A_jAT = np.einsum('ji,iab->jab', M_T, A_ATA)          # (n2,k,k)
        Term1 = np.einsum('jab,jab->', A_jAT, Sv)
        # Term2 = sum_i <Av_i, S_i S_i'>
        S_SST = np.einsum('ia,ib->iab', S.T, S.T)             # (n2,k,k)  S_j S_j'
        S_iST = np.einsum('ij,jab->iab', M, S_SST)            # (n1,k,k)
        Term2 = np.einsum('iab,iab->', S_iST, Av)
        # Term3 = sum_i <Phip_i - S_iS_i', Av_i>
        Svsum_i = Phip - S_iST                                # sum_{j obs i} Sv_j
        Term3 = np.einsum('iab,iab->', Svsum_i, Av)
        sXv = Term1 + Term2 + Term3 + (Muv[:, None] * M).sum()
        sXv = sXv + (rms ** 2) * ndata
        V = (sXv + 2 * hp) / (ndata + 2 * hp)

    return {'A': A, 'S': S, 'Mu': Mu, 'V': V, 'Av': Av, 'Sv': Sv, 'Muv': Muv, 'Xc': Xc, 'rms': rms}
