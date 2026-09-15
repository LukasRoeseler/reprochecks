import requests, time, json, sys

HDR = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ReproAI-audit', 'Accept': 'application/json'}

def get_json(url, tries=40, wait=4):
    for i in range(tries):
        try:
            r = requests.get(url, headers=HDR, timeout=40)
            if r.status_code == 200:
                try:
                    return r.json()
                except Exception:
                    return r.text
        except Exception:
            pass
        time.sleep(wait)
    raise RuntimeError("unreachable: " + url)

if __name__ == '__main__':
    target = sys.argv[1]
    if target.startswith('http'):
        url = target
    elif target.isdigit():
        url = "https://api.osf.io/v2/licenses/{}/".format(target)
    elif len(target) == 5 and target.isalnum():
        url = "https://api.osf.io/v2/nodes/{}/".format(target)
    else:
        url = target
    d = get_json(url)
    if isinstance(d, str):
        print(d)
    else:
        print(json.dumps(d, indent=1))
