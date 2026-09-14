import csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

for year in ['2019', '2020']:
    csv_path = os.path.join(BASE, f"VOLUME_{year}_REPROAI_SUMMARY.csv")
    with open(csv_path, encoding='utf-8') as f:
        findings = list(csv.DictReader(f))
    
    # Count by severity
    p1 = sum(1 for f in findings if f['severity'] == 'P1')
    p2 = sum(1 for f in findings if f['severity'] == 'P2')
    p3 = sum(1 for f in findings if f['severity'] == 'P3')
    
    # Pie chart
    fig, ax = plt.subplots(figsize=(8, 8))
    sizes = [p1, p2, p3]
    labels = [f'P1 Critical\n({p1})', f'P2 Moderate\n({p2})', f'P3 Minor\n({p3})']
    colors = ['#e74c3c', '#f39c12', '#27ae60']
    
    ax.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%', textprops={'fontsize': 12})
    ax.set_title(f'NHB Volume {year} - Findings by Severity\n(150 empirical papers audited)', fontsize=14)
    
    output_path = os.path.join(BASE, f"VOLUME_{year}_FINDINGS_PLOT.png")
    plt.tight_layout()
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Generated: {output_path}")
