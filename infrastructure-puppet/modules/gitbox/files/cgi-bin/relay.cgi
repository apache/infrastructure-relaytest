#!/usr/bin/env python3

import requests
import yaml
import json
import os
import sys
import fnmatch
import time

YAML_PATH = "/x1/gitbox/conf/relay.yaml"
YML = yaml.load(open(YAML_PATH))

PAYLOAD = json.load(sys.stdin)
PAYLOAD_FORMDATA = {
    'payload': json.dumps(PAYLOAD)
}

GUID = os.environ.get('HTTP_X_GITHUB_DELIVERY',"")
EVENT = os.environ.get('HTTP_X_GITHUB_EVENT', "push")
DATE = int(time.time())

HEADERS = {
    'User-Agent': os.environ.get('HTTP_USER_AGENT', 'GitHub-Hookshot/abcd'),
    'X-GitHub-Delivery': GUID,
    'X-GitHub-Event': EVENT,
  }


def log_entry(key, msg):
    with open("/x1/gitbox/logs/relay-%s.log" % key, "a") as f:
        f.write(msg + "\n")
        f.close()

# determine what and where
repo = PAYLOAD['repository']['name']
what = 'commit'
if 'pull_request' in PAYLOAD:
    what = 'pr'
elif 'issue' in PAYLOAD:
    what = 'issue'

for key, entry in YML['relays'].items():
    if fnmatch.fnmatch(repo, entry['repos']): # If yaml entry glob-matches the repo, then...
        hook = entry.get('hook') # Hook URL to post to
        fmt = entry.get('format', 'formdata') # www-formdata or raw json expected by hook?
        wanted = entry.get('events', 'all') # Which events to trigger on; all, pr, issue, commit or a mix.
        enabled = entry.get('enabled', False) # Default to false, so we don't trigger bootstrap example
        try:
            if enabled and hook and (wanted == 'all' or what in wanted):
                if fmt == 'formdata':
                    rv = requests.post(hook, data = PAYLOAD_FORMDATA, headers = HEADERS)
                elif fmt == 'json':
                    rv = requests.post(hook, json = PAYLOAD, headers = HEADERS)
                log_entry(key, "%s [%s]: Delivered %s payload for %s to %s: %u\n" % (DATE, GUID, what, repo, hook, rv.status_code))
        except requests.exceptions.RequestException as e:
            log_entry(key, "%s [%s]: Could not deliver %s payload for %s: %s" % (DATE, GUID, what, hook, e))
            
print("Status: 204 Handled\r\n\r\n")
