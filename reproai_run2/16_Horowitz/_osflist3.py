import requests, json, sys

sys.setrecursionlimit(10000)

def list_folder(node, folder_id=''):
    url = 'https://files.us.osf.io/v1/resources/%s/providers/osfstorage/' % node
    if folder_id:
        url = url + folder_id + '/'
    try:
        r = requests.get(url, timeout=25)
    except Exception as e:
        print('ERR list', url, e); return []
    if r.status_code != 200:
        print('ERR status', r.status_code, url); return []
    try:
        return r.json().get('data', [])
    except Exception as e:
        print('ERR json', e, r.text[:200]); return []

visited = set()
def walk(node, folder_id='', prefix=''):
    key = (node, folder_id)
    if key in visited:
        return
    visited.add(key)
    items = list_folder(node, folder_id)
    for it in items:
        a = it['attributes']; k = a.get('kind'); nm = a.get('name')
        mp = a.get('materialized', a.get('materialized_path', ''))
        fid = it['id'].split('/')[-1]
        if k == 'folder':
            walk(node, fid, prefix + nm + '/')
        else:
            dl = 'https://files.us.osf.io/v1/resources/%s/providers/osfstorage/%s' % (node, fid)
            print(mp + '  [' + str(a.get('size', '')) + ']')
            print('    DL:', dl)
            sys.stdout.flush()

for nid in ['6ye5m', '7enwz', 'gxfwh', 'p2twq', 'an52t', 'stjpn', '32h4p']:
    print('=== COMPONENT', nid, '===')
    sys.stdout.flush()
    walk(nid)
