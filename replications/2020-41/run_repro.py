import numpy as np
import repro_trudel as rt
from scipy.stats import ttest_1samp, t as tdist
import pandas as pd
from statsmodels.stats.anova import AnovaRM

def one_sample(betas):
    t, p = ttest_1samp(betas, 0)
    d = np.mean(betas) / np.std(betas, ddof=1)
    se = np.std(betas, ddof=1) / np.sqrt(len(betas))
    crit = tdist.ppf(0.975, len(betas) - 1)
    ci = (np.mean(betas) - crit * se, np.mean(betas) + crit * se)
    return np.mean(betas), np.std(betas, ddof=1), t, p, d, ci

def main():
    cond = rt.main()
    lines = []
    def log(s=''):
        print(s)
        lines.append(s)

    log('==== Trudel et al 2020 (NHB) reproduction ====')
    log('DOI 10.1038/s41562-020-0929-3, OpenAlex W3082827657, PMC7116777')
    log('N conditions: %d, N subjects: %d' % (len(cond), rt.NSUB))

    # GLM1
    glm1_betas = np.zeros((rt.NSUB, 6))
    for isub in range(rt.NSUB):
        for ci in range(len(cond)):
            glm1_betas[isub] += cond[ci]['subs'][isub]['allval'][1]['betas'] / len(cond)
    names1 = ['intercept', 'diff_acc', 'diff_unc', 'blocktime', 'diff_uncxblocktime', 'diff_accxblocktime']
    log('\n===== GLM1: decision phase, all trials (logistic) =====')
    for j in range(len(names1)):
        m, sd, t, p, d, ci = one_sample(glm1_betas[:, j])
        log('  %-20s beta=%8.4f t=%6.2f p=%.4f d=%6.2f CI=[%.3f %.3f]' % (names1[j], m, t, p, d, ci[0], ci[1]))

    # GLM2
    log('\n===== GLM2: decision phase, block halves (logistic) =====')
    for half in (1, 2):
        betas = np.zeros((rt.NSUB, 3))
        for isub in range(rt.NSUB):
            for ci in range(len(cond)):
                betas[isub] += cond[ci]['subs'][isub]['allval'][2]['betas'][half] / len(cond)
        for j, nm in enumerate(['intercept', 'diff_acc', 'diff_unc']):
            m, sd, t, p, d, ci_ = one_sample(betas[:, j])
            log('  half%d %-12s beta=%8.4f t=%6.2f p=%.4f d=%6.2f' % (half, nm, m, t, p, d))

    # GLM3 per-horizon t-stats + 3x2 ANOVA
    log('\n===== GLM3: first 15 trials per horizon (robust linear) =====')
    per_sub_hz = {h: np.zeros((rt.NSUB, 3)) for h in (1, 2, 3)}
    for hz in (1, 2, 3):
        for isub in range(rt.NSUB):
            for ci in range(len(cond)):
                per_sub_hz[hz][isub] += cond[ci]['subs'][isub]['allval'][3]['betas'][hz] / len(cond)
        for j, nm in enumerate(['intercept', 'diff_acc', 'diff_unc']):
            m, sd, t, p, d, ci_ = one_sample(per_sub_hz[hz][:, j])
            log('  horizon%d %-12s beta=%8.4f t=%6.2f p=%.4f d=%6.2f' % (hz, nm, m, t, p, d))

    # Build long df for 3x2 RM ANOVA (factor horizon x variable)
    rows = []
    for isub in range(rt.NSUB):
        for hz, hname in [(1, 'long'), (2, 'medium'), (3, 'short')]:
            rows.append({'sub': isub, 'horizon': hname, 'variable': 'accuracy', 'beta': per_sub_hz[hz][isub, 1]})
            rows.append({'sub': isub, 'horizon': hname, 'variable': 'uncertainty', 'beta': per_sub_hz[hz][isub, 2]})
    df = pd.DataFrame(rows)
    aov = AnovaRM(df, 'beta', 'sub', within=['horizon', 'variable']).fit()
    log('\n===== GLM3: 3x2 RM-ANOVA (horizon x variable) =====')
    log(str(aov.anova_table))

    # GLM4
    glm4_betas = np.zeros((rt.NSUB, 3))
    for isub in range(rt.NSUB):
        for ci in range(len(cond)):
            glm4_betas[isub] += cond[ci]['subs'][isub]['allval'][4]['betas'] / len(cond)
    log('\n===== GLM4: confidence phase (dependent = cisize/curstep, linear) =====')
    for j, nm in enumerate(['intercept', 'chosen_acc', 'chosen_unc']):
        m, sd, t, p, d, ci_ = one_sample(glm4_betas[:, j])
        log('  %-12s beta=%8.4f t=%6.2f p=%.4f d=%6.2f' % (nm, m, t, p, d))

    with open('repro_log.txt', 'w', encoding='ascii', errors='replace') as f:
        f.write('\n'.join(lines) + '\n')

if __name__ == '__main__':
    main()
