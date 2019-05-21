#!/usr/bin/env python3
import sys
import os
import re
import time
import uuid
import json
import smtplib

def run_check():
    eml = sys.stdin.read()
    m = re.search(r"ID: (\S+) TIMESTAMP: (\d+)", eml)
    if m:
        id = m.group(1)
        ts = int(m.group(2))
        diff = time.time() - ts
        f = open("/tmp/probes.json", "r")
        js = json.load(f)
        f.close()
        if id in js:
            js[id]['delivered'] = time.time()
            js[id]['delay'] = diff
            with open("/tmp/probes.json.new", "w") as f:
                json.dump(js, f, indent = 2)
                f.close()
            os.replace('/tmp/probes.json.new', '/tmp/probes.json')
            os.chmod('/tmp/probes.json', 0o666)

def send_probe():
    server = smtplib.SMTP('mx1-lw-us.apache.org')
    emlid = "<%s@mbox-vm.apache.org>" % str(uuid.uuid4())
    msg = "From: probe@mbox-vm.apache.org\r\nMessage-ID: %s\r\nTo: roundtrip@apache.org\r\nSubject: Roundtrip Test\r\n\r\nID: %s TIMESTAMP: %u\r\n" % (emlid, emlid, time.time())
    server.sendmail('probe@mbox-vm.apache.org', ['roundtrip@apache.org'], msg)
    server.quit()
    try:
        f = open("/tmp/probes.json", "r")
        js = json.load(f)
        f.close()
    except:
        js = {}
    
    newjson = {}
    now = time.time()
    # Trim to only last 24 hours of responses
    for id, el in js.items():
        if el['timestamp'] >= (now - 86400):
            newjson[id] = el
    newjson[emlid] = {
        'timestamp': time.time(),
    }
    with open("/tmp/probes.json.new", "w") as f:
        json.dump(newjson, f, indent = 2)
        f.close()
    os.replace('/tmp/probes.json.new', '/tmp/probes.json')
    os.chmod('/tmp/probes.json', 0o666)

def www():
    bads = 0
    out = ""
    now = time.time()
    f = open("/tmp/probes.json", "r")
    js = json.load(f)
    f.close()
    x = 0
    y = 0
    for id, el in js.items():
        if el['timestamp'] > (now - 3600):
            # Average delivery speed over the past hour
            if 'delay' in el and el['delivered'] > (now - 3600):
                x += el['delay']
                y += 1
            if 'delay' not in el and el['timestamp'] < (now - 1200):
                bads += 1
                out += "Message %s was sent at %u (%u seconds ago) but hasn't been delivered yet!\n" % (id, el['timestamp'], now - el['timestamp'])
            elif 'delay' in el and el['delay'] > 900:
                bads += 1
                out += "Message %s was sent at %u, but took %u seconds to be delivered!\n" % (id, el['timestamp'], el['delay'])
    if not bads:
        print("Status: 200 Okay\r\nContent-Type: text/plain\r\n\r\n")
        print("Roundtrips for the past hour are all okay\r\n")
        if y > 0:
            print("Average delay:%u seconds" % (x/y))
    else:
        print("Status: 500 Roundtrip errors detected\r\nContent-Type: text/plain\r\n\r\n")
        print(out)

if len(sys.argv) > 1 and sys.argv[1] == 'check':
    run_check()
elif len(sys.argv) > 1 and sys.argv[1] == 'probe' :
    send_probe()
else:
    www()
