import requests, json, sys

def jget(u):
    r = requests.get(u, timeout=40)
    return r.json() if r.status_code == 200 else {'err': r.status_code}

def walk_files(nid, prefix=''):
    base = 'https://api.osf.io/v2/nodes/%s/files/osfstorage/' % nid
    def walk_folder(furl, pre):
        d = jget(furl)
        nxt = d.get('links',{}).get('next')
        for it in d.get('data', []):
            a = it['attributes']; k = a.get('kind'); nm = a.get('name')
            links = it.get('links', {})
            if k == 'folder':
                sself = links.get('self')
                if isinstance(sself, dict):
                    sself = sself.get('href')
                walk_folder(sself, pre + nm + '/')
            else:
                print(pre + nm + '  [' + str(a.get('size','')) + ']')
                print('    DL:', links.get('download',''))
        if nxt:
            walk_folder(nxt, pre)
    walk_folder(base, prefix)

root = '6ye5m'
walk_files(root)
for cid in ['7enwz','gxfwh','p2twq','an52t','stjpn','32h4p']:
    print('=== COMPONENT', cid, '===')
    walk_files(cid)
