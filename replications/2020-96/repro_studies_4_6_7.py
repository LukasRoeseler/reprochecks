import numpy as np
import pandas as pd
from scipy.spatial.distance import pdist
from scipy.stats import spearmanr, pearsonr, zscore, ttest_ind
from itertools import combinations

def ci_pearsonr(r, n):
    return np.array([np.tanh(np.arctanh(r)-(1.96/np.sqrt(n-3))),
                     np.tanh(np.arctanh(r)+(1.96/np.sqrt(n-3)))])

simVote_r = {'If someone is a friendly person how likely are they to be a dishonest person?': 'dishonest_friendly','If someone is a dishonest person how likely are they to be a friendly person?': 'dishonest_friendly','If someone is a friendly person how likely are they to be a sociable person?': 'friendly_sociable','If someone is a sociable person how likely are they to be a friendly person?': 'friendly_sociable','If someone is a dishonest person how likely are they to be a sociable person?': 'dishonest_sociable','If someone is a sociable person how likely are they to be a dishonest person?': 'dishonest_sociable','If someone is a creative person how likely are they to be a friendly person?': 'creative_friendly','If someone is a friendly person how likely are they to be a creative person?': 'creative_friendly','If someone is a sociable person how likely are they to be a stubborn person?': 'sociable_stubborn','If someone is a stubborn person how likely are they to be a sociable person?': 'sociable_stubborn','If someone is a intelligent person how likely are they to be a stubborn person?': 'intelligent_stubborn','If someone is a stubborn person how likely are they to be a intelligent person?': 'intelligent_stubborn','If someone is a creative person how likely are they to be a stubborn person?': 'creative_stubborn','If someone is a stubborn person how likely are they to be a creative person?': 'creative_stubborn','If someone is a sociable person how likely are they to be a intelligent person?': 'intelligent_sociable','If someone is a intelligent person how likely are they to be a sociable person?': 'intelligent_sociable','If someone is a stubborn person how likely are they to be a dishonest person?': 'dishonest_stubborn','If someone is a dishonest person how likely are they to be a stubborn person?': 'dishonest_stubborn','If someone is a creative person how likely are they to be a sociable person?': 'creative_sociable','If someone is a sociable person how likely are they to be a creative person?': 'creative_sociable','If someone is a intelligent person how likely are they to be a creative person?': 'creative_intelligent','If someone is a creative person how likely are they to be a intelligent person?': 'creative_intelligent','If someone is a dishonest person how likely are they to be a creative person?': 'creative_dishonest','If someone is a creative person how likely are they to be a dishonest person?': 'creative_dishonest','If someone is a friendly person how likely are they to be a stubborn person?': 'friendly_stubborn','If someone is a stubborn person how likely are they to be a friendly person?': 'friendly_stubborn','If someone is a intelligent person how likely are they to be a dishonest person?': 'dishonest_intelligent','If someone is a dishonest person how likely are they to be a intelligent person?': 'dishonest_intelligent','If someone is a friendly person how likely are they to be a intelligent person?': 'friendly_intelligent','If someone is a intelligent person how likely are they to be a friendly person?': 'friendly_intelligent'}

def load_data_corr(ratings_csv, demos_csv):
    ratings = pd.read_csv(ratings_csv)
    demos = pd.read_csv(demos_csv)
    ratings['Picture'] = ratings['Picture'].map(simVote_r).fillna(ratings['Picture'])
    data_corr = pd.DataFrame(columns=['SubjID','trait_pair','concept_sim','target_corr'])
    for i,s in enumerate(np.unique(ratings['SubjID'])):
        t_ = pd.pivot_table(ratings[ratings['SubjID']==s], index='Picture', columns='Name',
                            values='Rating', aggfunc=np.mean)
        t_.reset_index(level=0, inplace=True)
        trait_pair = t_[t_.notnull()['simVote']]['Picture'].values[0]
        a, b = trait_pair.split("_")
        r = np.ma.corrcoef(np.ma.masked_invalid(t_[a].to_numpy(dtype=float)),
                           np.ma.masked_invalid(t_[b].to_numpy(dtype=float)))
        rv = float(r[0,1])
        data_corr.loc[i] = [s, trait_pair,
              np.mean(t_['simVote']),
              np.arctanh(rv)]
    data_corr['concept_sim'] = zscore(data_corr['concept_sim'])
    return data_corr.merge(demos, on='SubjID', how='left')

def study4(ratings_csv, demos_csv, label):
    data_corr = load_data_corr(ratings_csv, demos_csv)
    print('  original n', len(data_corr))
    data_corr = data_corr.dropna(axis=0, subset=['age'])
    print('  post-incomplete drop n', len(data_corr))
    data_corr = data_corr.dropna(axis=0)
    print('  post-repeated drop n', len(data_corr))
    res = spearmanr(data_corr['concept_sim'], data_corr['target_corr'])
    c = ci_pearsonr(res[0], len(data_corr))
    print('  %s: rho(%d)=%.3f, p=%.3f, CI=[%.3f,%.3f]' %
          (label, len(data_corr)-2, res[0], res[1], c[0], c[1]))

print('================ STUDY 4 ================')
for l in ['face','familiar','group']:
    study4('Study 4/s4_'+l+'_ratings.csv', 'Study 4/s4_'+l+'_demo.csv', l)

print('\n================ STUDY 6 ================')
data = pd.read_csv('Study 6/s6_ratings.csv').groupby(['SubjID','association_condition'], as_index=False).mean(numeric_only=True)
neg = data[data['association_condition']=='neg']['Rating']
pos = data[data['association_condition']=='pos']['Rating']
print('  n neg', len(neg), 'n pos', len(pos))
print('  ttest_ind:', ttest_ind(pos, neg))
print('  mean pos %.3f neg %.3f' % (pos.mean(), neg.mean()))

print('\n================ STUDY 7 ================')
path='Study 7'
neopi_raw = pd.read_csv(path+'/facets_Johnson2014_scored.csv', index_col='SubjID')
neopiSM = 1 - pdist(neopi_raw.transpose(), metric='correlation')
print('  neopi shape', neopi_raw.shape, 'pairs', len(neopiSM))
conceptual_raw = pd.read_csv(path+'/s1_conceptual_ratings.csv')
conceptualSM = conceptual_raw.groupby('trait_pair')['similarity'].mean()
labs=['face','familiar','group']
SMs={}
for l in labs:
    d = pd.pivot_table(pd.read_csv(path+'/s1_'+l+'_ratings.csv'),
                       index='Picture', columns='Name', values='Rating', aggfunc=np.mean)
    SMs[l] = 1 - pdist(d.transpose(), metric='correlation')
    print(' ',l,'shape',d.shape,'pairs',len(SMs[l]))
# align on conceptual index
traitSMs = pd.DataFrame(index=conceptualSM.index)
traitSMs['ConceptualSM'] = conceptualSM.values
traitSMs['NeopiSM'] = neopiSM
traitSMs['FaceSM'] = SMs['face']
traitSMs['FamiliarSM'] = SMs['familiar']
traitSMs['GroupSM'] = SMs['group']
print('  n pairs', len(traitSMs))
for col in ['ConceptualSM','FaceSM','FamiliarSM','GroupSM']:
    res = spearmanr(traitSMs['NeopiSM'], traitSMs[col])
    c = ci_pearsonr(res[0], len(traitSMs))
    print('  Neopi vs %s: rho(%d)=%.3f, p=%.3f, CI=[%.3f,%.3f]' %
          (col, len(traitSMs)-2, res[0], res[1], c[0], c[1]))
