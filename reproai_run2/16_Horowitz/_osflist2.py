import requests, json, sys

def jget(u):
    r = requests.get(u, timeout=40)
    return r.json() if r.status_code == 200 else {'err': r.status_code, 'txt': r.text[:200]}

def walk_node(nid, mpath=''):
    url = 'https://api.osf.io/v2/nodes/%s/files/osfstorage/?path=%s' % (nid, mpath)
    d = jget(url)
    for it in d.get('data', []):
        a = it['attributes']; k = a.get('kind'); nm = a.get('name')
        mp = a.get('materialized_path', '')
        if k == 'folder':
            walk_node(nid, mp)
        else:
            dl = it.get('links', {}).get('download', '')
            print(mp + '  [' + str(a.get('size', '')) + ']')
            print('    DL:', dl)

for nid in ['6ye5m', '7enwz', 'gxfwh', 'p2twq', 'an52t', 'stjpn', '32h4p']:
    print('=== COMPONENT', nid, '===')
    walk_node(nid)
