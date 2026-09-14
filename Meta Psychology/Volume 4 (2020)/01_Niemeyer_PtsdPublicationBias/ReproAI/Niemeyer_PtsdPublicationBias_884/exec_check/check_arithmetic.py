def pct(num, den, nd=1):
    return num/den*100 if den else None

checks = []
def add(label, num, den, paper):
    checks.append((label, pct(num, den), paper))

# C6 authors contacted / data obtained (denominator 83 MAs)
add('C6 36/83 contacted', 36, 83, 43.4)
add('C6 6/83 obtained', 6, 83, None)
add('C6b 6/36 of contacted', 6, 36, 16.7)
# C9 exclusion
checks.append(('C9 2017/2110 excluded', 2017/2110*100, 95.4))
checks.append(('C8 98/2110 included', 98/2110*100, 4.6))
# C21-C26 percentages of 83 MAs
for label, num, paper in [
    ('C21 58/83 mentioned PB', 58, 69.9),
    ('C21b 25/83 not', 25, 30.1),
    ('C22 35/83 search incl unpub', 35, 42.2),
    ('C22b 20/83 found unpub', 20, 24.1),
    ('C23 46/83 excluded unpub', 46, 55.4),
    ('C23b 2/83 unspecified', 2, 2.4),
    ('C24 47/83 assessed PB', 47, 56.6),
    ('C24b 36/83 did not', 36, 43.4),
    ('C25 5/83 rank', 5, 6.0),
    ('C25b 6/83 egger', 6, 7.2),
    ('C25c 9/83 trim&fill', 9, 10.8),
    ('C26 26/83 funnel', 26, 31.3),
    ('C26b 26/83 failsafe', 26, 31.3),
]:
    checks.append((label, pct(num, 83), paper))
# C27 effect size measure % of 98
for label, num, paper in [
    ('C27 g', 39, 39.8), ('C27 d', 29, 29.6), ('C27 SMD', 3, 3.1),
    ('C27 raw mean', 7, 7.1), ('C27 RR', 16, 16.3), ('C27 logOR', 2, 2.0), ('C27 Glass', 2, 2.0)]:
    checks.append((label, pct(num, 98), paper))
# C30 77/98
checks.append(('C30 77/98 >=1 sig', 77/98*100, 78.6))

print('%-30s | %8s | %7s | %s' % ('Label', 'computed%', 'paper%', 'verdict'))
for label, calc, paper in checks:
    if paper is None:
        print('%-30s | %8.2f | %7s | %s' % (label, calc, '(n/a)', 'info'))
    else:
        v = 'OK' if abs(calc-paper) < 0.15 else ('CLOSE' if abs(calc-paper) < 0.3 else 'MISMATCH')
        print('%-30s | %8.2f | %7.1f | %s' % (label, calc, paper, v))

# Flowchart sums
print()
print('Flowchart category sum (419):', 245+112+10+22+17+5+2+1+1+4)
print('Data-set exclusion category sum vs 2017:', 1510+309+141+6+5+16+25+28)
print('C7 exclusion items given:', [1510,309,141,6,5,16,25,28], 'sum=', sum([1510,309,141,6,5,16,25,28]))
# sum check: 1510+309=1819, +141=1960,+6=1966,+5=1971,+16=1987,+25=2012,+28=2040
