import requests, os, sys, json, time, shutil

def get_json(url, timeout=45, tries=3):
    for a in range(tries):
        try:
            r = requests.get(url, timeout=timeout)
            if r.status_code == 200:
                return r.json()
        except Exception as e:
            time.sleep(2)
    return None

def download_file(dlurl, fpath):
    if os.path.exists(fpath) and os.path.getsize(fpath) > 1024:
        return "cached"
    try:
        with requests.get(dlurl, timeout=90, stream=True) as r:
            if r.status_code != 200:
                return f"http{r.status_code}"
            with open(fpath, "wb") as fh:
                for chunk in r.iter_content(65536):
                    fh.write(chunk)
        return f"ok{os.path.getsize(fpath)}" if os.path.getsize(fpath)>0 else "empty"
    except Exception as e:
        return f"err{type(e).__name__}"

def walk(item_json, node_id, cur_path, base_dir, stats):
    for it in item_json.get("data", []):
        att = it.get("attributes", {})
        name = att.get("name", "?")
        kind = att.get("kind", "file")
        if kind == "folder":
            sub = os.path.join(cur_path, name)
            # list folder contents via the folder's hex-id path (works with files.us.osf.io)
            fpath_id = att.get("path") or ""
            folder_url = f"https://files.osf.io/v1/resources/{node_id}/providers/osfstorage{fpath_id}?format=json"
            fj = get_json(folder_url)
            if fj:
                walk(fj, node_id, sub, base_dir, stats)
            else:
                print("   !! cannot list folder", name)
        else:
            fpath = os.path.join(cur_path, name)
            os.makedirs(os.path.dirname(fpath), exist_ok=True)
            dl = (it.get("links") or {}).get("download")
            if dl:
                st = download_file(dl, fpath)
                stats[st] = stats.get(st, 0) + 1
                print("   ", name, "->", st)

def fetch_node(node_id, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    url = f"https://files.osf.io/v1/resources/{node_id}/providers/osfstorage/?format=json"
    j = get_json(url)
    if j is None:
        print("NO ACCESS", node_id); return None
    stats = {}
    walk(j, node_id, out_dir, out_dir, stats)
    return stats

if __name__ == "__main__":
    node = sys.argv[1]; out = sys.argv[2]
    st = fetch_node(node, out)
    print("SUMMARY", node, st)
