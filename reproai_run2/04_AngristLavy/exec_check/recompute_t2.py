import pandas as pd, numpy as np

BASE = r"data/unzipped/AngristLavy_AERdata/data"

def prep(y='01'):
    df = pd.read_stata(f"{BASE}/base{y}.dta")
    if 'school_id' not in df:
        df = df.rename(columns={'semelmos':'school_id'})
    return df

def quartiles(df, col='lagscore'):
    q = df[col].quantile([0.25,0.50,0.75])
    p25,p50,p75 = q[0.25],q[0.50],q[0.75]
    ls = {}
    ls['ls25']=(df[col]<p25).astype(int)
    ls['ls50']=(((df[col]<p50))&(~ls['ls25'].astype(bool))).astype(int)
    ls['ls75']=(((df[col]<p75))&(~(ls['ls25'].astype(bool)|ls['ls50'].astype(bool)))).astype(int)
    ls['ls100']=(~(ls['ls25'].astype(bool)|ls['ls50'].astype(bool)|ls['ls75'].astype(bool))).astype(int)
    return pd.DataFrame(ls,index=df.index)

def ols_cluster(df, yvar, Xvars, cluster_col):
    y = df[yvar].values.astype(float)
    X = np.column_stack([np.ones(len(df))]+[df[v].values.astype(float) for v in Xvars])
    names = ['_cons']+Xvars
    beta, _, _, _ = np.linalg.lstsq(X,y,rcond=None)
    resid = y - X@beta
    n,k = X.shape
    cl = df[cluster_col].values
    u = X*(resid[:,None])
    meat = np.zeros((k,k))
    for g in np.unique(cl):
        s = u[cl==g].sum(axis=0)
        meat += np.outer(s,s)
    G = len(np.unique(cl))
    V0 = np.linalg.inv(X.T@X) @ meat @ np.linalg.inv(X.T@X)
    se_hc1 = np.sqrt(np.diag(V0))*np.sqrt((G/(G-1))*((n-1)/(n-k)))
    return beta, resid, names, se_hc1, G

def run_gender(y, gend, ctrl, verbose=True):
    df = prep(y)
    df['boy']=df['boy'].astype(int)
    df = df[df['boy']==gend].copy()
    df = df.reset_index(drop=True)
    # quartiles
    for col,v in quartiles(df).items():
        df[col]=v
    df['ah4']=(df['m_ahim']>=4).astype(int)
    if ctrl=='sc':
        Xvars=['treated','semarab','semrel']
    elif ctrl=='scqm':
        Xvars=['treated','semarab','semrel','ls50','ls75','ls100','educav','educem','ah4','ole5']
    beta,resid,names,se_hc1,G = ols_cluster(df,'zakaibag',Xvars,'school_id')
    td = list(Xvars).index('treated')
    if verbose:
        print(f"YEAR{y} gend={gend}({'boy' if gend else 'girl'}) ctrl={ctrl} N={len(df)} G={G}")
        print(f"  treated OLS coef = {beta[1+td]:.6f}")
        print(f"  cluster(HC1) SE  = {se_hc1[1+td]:.6f}")
        print(f"  dep mean         = {df['zakaibag'].mean():.6f}")
    return dict(N=len(df), G=G, coef=beta[1+td], se_hc1=se_hc1[1+td], depmean=df['zakaibag'].mean())

if __name__=='__main__':
    for gend in [0,1]:
        for ctrl in ['sc','scqm']:
            run_gender('01',gend,ctrl)
