#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

""" WSGI handler for github -> gitbox sync API.
    Managed through puppet as a gunicorn service. """
import json
import netaddr
import traceback
import yaml
import sys
import requests
import time

# pages
import github_sync

try:
    META = requests.get('https://api.github.com/meta').json()
    CONFIG = yaml.load(open('gitbox-syncer.yaml'))
    assert('hooks' in META)
    assert('database' in CONFIG)
except:
    #asfpy.mail(recipient = 'team@infra.apache.org', subject = 'GitBox syncer could not fetch GitHub META!', message = "I was rate limited by GitHub :(")
    raise Exception("Rate-limited by GitHub!!")

# Add in yaml-defined allowed networks to the GitHub ranges for local/remote testing
for CIDR in CONFIG.get('allownetworks', []):
    META['hooks'].append(CIDR)


# Define paths for web API:
PATHS = {
    'sync': github_sync.run
}


def took(now):
    return (int( (time.time() - now) * 1000000.0) / 1000000.0)

def application(environ, start_response):
    status = '200 Okay'
    now = time.time()
    
    # IP Origin check against GitHub's META directory
    ip = netaddr.IPAddress(environ.get('REMOTE_ADDR', '127.0.0.1'))
    allowed = False
    for CIDR in META['hooks']:
        net = netaddr.IPNetwork(CIDR)
        if ip in net:
            allowed = True
            break
    
    if not allowed:
        status = '403 Forbidden'        
        response = {'okay': False, 'ip': str(ip), 'message': "IP Address not allowed by META"}
    
    # We're good to go, this is GitHub (or us)...
    else:
        # Get request body
        try:
            request_body_size = int(environ.get('CONTENT_LENGTH', 0))
        except (ValueError):
            request_body_size = 0
        request_body = environ['wsgi.input'].read(request_body_size)
        if request_body:
            js = json.loads(request_body)
        else:
            js = {}
        js['environ'] = environ
        
        # Get URI
        uri = environ.get('RAW_URI', '').strip('/')
        
        # Run generator or fail and blurt out failure to client
        try:
            if uri in PATHS:
                response = PATHS[uri](CONFIG, js)
                assert(type(response) is dict)
            else:
                status = '404 Not Found'
                response = {'took': took(now), 'okay': False, 'ip': str(ip), 'message': "Unknown end-point " + uri}
        except:
            err_type, err_value, tb = sys.exc_info()
            traceback_output = ['API traceback:']
            traceback_output += traceback.format_tb(tb)
            traceback_output.append('%s: %s' % (err_type.__name__, err_value))
            status = '500 Internal Server Error'
            response = {
                "took": took(now),
                "code": "500",
                "reason": '\n'.join(traceback_output)
            }
    
    # Format response
    response['took'] = took(now)
    response['okay'] = True
    out = json.dumps(response).encode('utf-8')
    
    # Send response
    response_headers = [
        ('Content-Type', 'application/json'),
        ('Content-Length', str(len(out))),
    ]
    
    start_response(status, response_headers)
    yield out
