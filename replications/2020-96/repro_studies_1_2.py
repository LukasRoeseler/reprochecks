import numpy as np
import pandas as pd
from scipy.spatial.distance import squareform, pdist
from scipy.stats import rankdata, pearsonr, spearmanr, ttest_1samp, ttest_ind
from itertools import combinations

def ci_pearsonr(r, n):
    return np.array([np.tanh(np.arctanh(r) - (1.96/np.sqrt(n-3))),
                     np.tanh(np.arctanh(r) + (1.96/np.sqrt(n-3)))])

def vec_rescale(vec, new_min, new_max):
    return (new_max-new_min)/(max(vec)-min(vec))*(vec-max(vec))+new_max

def run_study(path):
    conceptual_raw = pd.read_csv(path+'/conceptual_ratings.csv')
    conceptualSM = conceptual_raw.groupby('trait_pair')['similarity'].mean()

    valence_raw = pd.read_csv(path+'/valence_ratings.csv')[['Picture','Rating']]
    valence_mean = valence_raw.groupby(['Picture'])['Rating'].mean()
    valenceSM = np.array([abs(i[0]-i[1]) for i in combinations(valence_mean.values, 2)])*-1
    print("  valenceSM len", len(valenceSM), "has nan", np.isnan(valenceSM).any())

    labs = ['face','familiar','group']
    SMs = {}
    for l in labs:
        d = pd.pivot_table(pd.read_csv(path+'/'+l+'_ratings.csv'),
                           index='Picture', columns='Name', values='Rating', aggfunc=np.mean)
        SMs[l] = 1 - pdist(d.transpose(), metric='correlation')
        print(' ',l,'shape',d.shape,'pairs',len(SMs[l]),'nan',np.isnan(SMs[l]).any())

    # merge by trait_pair index alignment
    traitSMs = pd.DataFrame(index=conceptualSM.index)
    # face/familiar/group SM length should match conceptual length here
    traitSMs['ConceptualSM'] = conceptualSM.values
    traitSMs['FaceSM'] = SMs['face']
    traitSMs['FamiliarSM'] = SMs['familiar']
    traitSMs['GroupSM'] = SMs['group']
    print('  n pairs =', len(traitSMs))

    for col in ['FaceSM','FamiliarSM','GroupSM']:
        res = spearmanr(traitSMs['ConceptualSM'], traitSMs[col])
        c = ci_pearsonr(res[0], len(traitSMs))
        print('  Conceptual vs %s: rho(%d)=%.3f, p=%.3f, CI=[%.3f,%.3f]' %
              (col, len(traitSMs)-2, res[0], res[1], c[0], c[1]))

def run_study2(path):
    conceptual_raw = pd.read_csv(path+'/s1_conceptual_ratings.csv')
    conceptualSM = conceptual_raw.groupby('trait_pair')['similarity'].mean()
    valence_raw = pd.read_csv(path+'/s1_valence_ratings.csv')[['Picture','Rating']]
    valence_mean = valence_raw.groupby(['Picture'])['Rating'].mean()
    valenceSM = np.array([abs(i[0]-i[1]) for i in combinations(valence_mean.values,2)])*-1

    key = pd.read_csv(path+'/s2_traitNEOPIkey.csv')
    SMs = {}
    for l in ['face','familiar','group']:
        d = pd.read_csv(path+'/s2_'+l+'_ratings.csv').merge(key, on='Name')
        piv = pd.pivot_table(d, index='Picture', columns='trait', values='Rating', aggfunc=np.mean)
        for i,row in key.iterrows():
            if (row['Name'] in d.Name.unique()) & (row['keyed']=='negative'):
                piv[row['trait']] = (piv[row['trait']]-8)*-1
        SMs[l] = 1 - pdist(piv.transpose(), metric='correlation')
        print(' ',l,'shape',piv.shape,'pairs',len(SMs[l]))
    # order pairs by sorted trait names (same as conceptual trait_pair)
    labels = sorted(np.unique(key['trait']))
    trait_pair = [i[0]+'_'+i[1] for i in combinations(labels,2)]
    traitSMs = pd.DataFrame(index=conceptualSM.index)
    traitSMs['ConceptualSM'] = conceptualSM.values
    traitSMs['FaceSM'] = SMs['face']
    traitSMs['FamiliarSM'] = SMs['familiar']
    traitSMs['GroupSM'] = SMs['group']
    print('  n pairs =', len(traitSMs))
    for col in ['FaceSM','FamiliarSM','GroupSM']:
        res = spearmanr(traitSMs['ConceptualSM'], traitSMs[col])
        c = ci_pearsonr(res[0], len(traitSMs))
        print('  Conceptual vs %s: rho(%d)=%.3f, p=%.3f, CI=[%.3f,%.3f]' %
              (col, len(traitSMs)-2, res[0], res[1], c[0], c[1]))

print('================ STUDY 1 ================')
run_study('Study 1')
print('\n================ STUDY 2 ================')
run_study2('Study 2')
