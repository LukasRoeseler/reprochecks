import urllib.request, json, sys

def get(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    return json.load(urllib.request.urlopen(req, timeout=60))

def walk(node, folder_id=None, prefix=''):
    if folder_id:
        url = 'https://api.osf.io/v2/nodes/%s/files/osfstorage/%s/' % (node, folder_id)
    else:
        url = 'https://api.osf.io/v2/nodes/%s/files/osfstorage/' % node
    d = get(url)
    for item in d['data']:
        kind = item['attributes'].get('kind') or item['attributes'].get('file_type')
        name = item['attributes']['name']
        path = item['attributes'].get('materialized_path', prefix + '/' + name)
        fid = item['id']
        print(kind, '|', path, '|', fid)
        if kind == 'folder':
            walk(node, fid, prefix)

for nid in sys.argv[1:]:
    print('===== NODE', nid, '=====')
    try:
        walk(nid)
    except Exception as e:
        print('ERR', e)
