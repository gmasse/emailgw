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

conn = http.client.HTTPSConnection("api.pushover.net:443")
conn.request("POST", "/1/messages.json",
  urllib.parse.urlencode({
    "token": PUSHOVER_TOKEN,
    "user": PUSHOVER_USER,
    "message": "hello world",
  }), { "Content-type": "application/x-www-form-urlencoded" })
conn.getresponse()
