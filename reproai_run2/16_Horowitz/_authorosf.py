import requests, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

def list_folder(node, folder_id=''):
    url = 'https://files.us.osf.io/v1/resources/%s/providers/osfstorage/' % node
    if folder_id:
        url = url + folder_id + '/'
    try:
        r = requests.get(url, timeout=30)
    except Exception as e:
        print('ERR', e); return []
    if r.status_code != 200:
        print('ERR st', r.status_code); return []
    try:
        return r.json().get('data', [])
    except Exception:
        return []

visited = set()
def walk(node, folder_id='', prefix=''):
    key = (node, folder_id)
    if key in visited: return
    visited.add(key)
    for it in list_folder(node, folder_id):
        a = it['attributes']; k = a.get('kind'); nm = a.get('name')
        fid = it['id'].split('/')[-1]
        if k == 'folder':
            walk(node, fid, prefix + nm + '/')
        else:
            print(prefix + nm + ' [' + str(a.get('size', '')) + ']  dl=' + ('https://files.us.osf.io/v1/resources/%s/providers/osfstorage/%s' % (node, fid)))
            sys.stdout.flush()

walk('j26vm')
d = requests.get('https://api.osf.io/v2/nodes/j26vm/children/', timeout=30).json()
print('CHILDREN:', [(c['id'], c['attributes'].get('title')) for c in d.get('data', [])])
