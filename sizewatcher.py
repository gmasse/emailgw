import json
import subprocess
import os.path
import http.client, urllib

PUSHOVER_TOKEN = None
PUSHOVER_USER = None

# --------------------------------------------------------------------------- #
# retrieve config from diematic.yaml
# --------------------------------------------------------------------------- #
main_base = os.path.dirname(__file__)
config_file = os.path.join(main_base, "sizewatcher.json")
if os.path.exists(config_file):
    with open(config_file) as f:
        # use safe_load instead load
        cfg = json.load(f)
        if 'pushover' in cfg:
            if isinstance(cfg['pushover']['token'], str):
                PUSHOVER_TOKEN = cfg['pushover']['token']
            if isinstance(cfg['pushover']['user'], str):
                PUSHOVER_USER = cfg['pushover']['user']
else:
    raise FileNotFoundError("Configuration file not found")

data_percent = None
metadata_percent = None

result = subprocess.run(
        [ 'lvs', 'vg-mail/thinpool', '--options=lv_size,lv_metadata_size,data_percent,metadata_percent', '--reportformat=json', '--units=g' ],
        stdout=subprocess.PIPE)
data = json.loads(result.stdout)

if 'report' in data:
    if len(data['report']) == 1:
        if 'lv' in data['report'][0]:
            if len(data['report'][0]['lv']) == 1:
                data_percent = float(data['report'][0]['lv'][0]['data_percent'])
                metadata_percent = float(data['report'][0]['lv'][0]['metadata_percent'])

if data_percent is None or metadata_percent is None:
    # Cannot retrieve value!
    print('Cannot retrieve value!')
else:
    message = ''
    if data_percent > 80:
        message = message + 'data: {}% '.format(data_percent)
    if metadata_percent > 80:
        message = message + 'meta: {}% '.format(data_percent)

    if len(message) > 0:
        message = 'ALERT ' + message
        conn = http.client.HTTPSConnection("api.pushover.net:443")
        conn.request("POST", "/1/messages.json",
          urllib.parse.urlencode({
            "token": PUSHOVER_TOKEN,
            "user": PUSHOVER_USER,
            "message": message,
          }), { "Content-type": "application/x-www-form-urlencoded" })
        conn.getresponse()
    else:
        print('Everything is good!')
