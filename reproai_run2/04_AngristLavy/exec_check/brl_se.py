import numpy as np
from recompute_t2 import prep, quartiles

def isymroot(a):
    evals, evecs = np.linalg.eigh(a)
    return evecs @ np.diag(evals**(-0.5)) @ evecs.T

def brl_variance(X, beta, cluster, resid):
    """Implement calcbrl from brl.ado for OLS (aweight=1, pweight=1)."""
    n, p = X.shape
    clusts = np.unique(cluster)
    G = len(clusts)
    w_5 = np.ones(n)
    omega = np.linalg.inv(X.T @ X)          # luinv(omega)
    # gamma = X' (for each obs, x[z]' * w_5^2 * aweight)
    gamma = (X * w_5[:,None]**2).T          # p x n
    # build block rows phii for each cluster
    # map obs to cluster index
    ci = {g:i for i,g in enumerate(clusts)}
    idx_by_cl = [np.where(cluster==g)[0] for g in clusts]
    # phii list
    phis = []
    for i in range(G):
        idi = idx_by_cl[i]
        xi = X[idi]
        mi = len(idi)
        vi_5 = np.eye(mi)
        # phiij across j
        row = []
        for j in range(G):
            idj = idx_by_cl[j]
            xj = X[idj]
            vj_5 = np.eye(len(idj))
            if j == i:
                phiij = vj_5 - xi @ omega @ xj.T @ vj_5
            else:
                phiij = -xi @ omega @ xj.T @ vj_5
            row.append(phiij)
        phii = np.hstack(row)
        phis.append(phii)
    # xrrx2
    xrrx2 = np.zeros((p,p))
    for i in range(G):
        idi = idx_by_cl[i]
        xi = X[idi]
        ri = resid[idi]
        mi = len(idi)
        phii = phis[i]
        qi = phii @ phii.T
        ai = isymroot(qi)   # vi_5=I
        tmp2 = xi.T @ ai @ ri   # xi' wi_5 invvi wi_5 ai ri
        xrrx2 += np.outer(tmp2, tmp2)
    vc_brl = omega @ xrrx2 @ omega
    se_brl = np.sqrt(np.diag(vc_brl))
    return se_brl

def main():
    df = prep('01'); df['boy']=df['boy'].astype(int)
    sub = df[df['boy']==0].copy().reset_index(drop=True)
    for col,v in quartiles(sub).items(): sub[col]=v
    sub['ah4']=(sub['m_ahim']>=4).astype(int)
    Xvars=['treated','semarab','semrel','ls50','ls75','ls100','educav','educem','ah4','ole5']
    X = np.column_stack([np.ones(len(sub))]+[sub[v].values.astype(float) for v in Xvars])
    y = sub['zakaibag'].values.astype(float)
    beta,_,_,_=np.linalg.lstsq(X,y,rcond=None)
    resid = y - X@beta
    se_brl = brl_variance(X,beta,sub['school_id'].values,resid)
    print("Girls 2001 scqm OLS BRL SE for treated =", se_brl[Xvars.index('treated')+1])
    print("Paper BRL SE (focal) = 0.047")

if __name__=='__main__':
    main()
