#!/usr/bin/env python
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import json
import os
import sys
import time
import cgi
import requests
import base64
import subprocess
import re
import uuid
import sscommon

requser = os.environ['REMOTE_USER']

form = cgi.FieldStorage();

moinwiki = form.getvalue('moinwiki', None)
if not moinwiki or not re.match(r"^[-a-z0-9]+$", moinwiki):
    sscommon.buggo("Invalid Moin Wiki name!")

moinpath = '/usr/local/etc/moin-to-cwiki/universal-wiki-converter'
if not os.path.exists("%s/projects/%s" % (moinpath, moinwiki)):
    sscommon.buggo("This wiki does not seem to exist, please check and try again!")

space = form.getvalue('space', None)
if not space or not re.match(r"^[A-Z0-9]+$", space):
    sscommon.buggo("Invalid Confluence Space name!")

history = form.getvalue('history', 'false')
renametohome = form.getvalue('homepage', 'false')

moinscript = '%s/run_cmdline.sh' % moinpath
settingsconf = 'confluenceSettings.properties'
exporterconf = 'exporter.moinmoin.properties'
converterconf = 'converter.moinmoin.properties'

os.chdir(moinpath)

try:

    # copy settings files and append space name
    subprocess.check_output(['%s/populate-properties.sh %s %s %s' % (moinpath, moinwiki, space, history)],shell=True, stderr=subprocess.STDOUT)

    # Test auth to Confluence via uwc.
    subprocess.check_output(['%s -t conf/%s' % (moinscript, settingsconf)],shell=True, stderr=subprocess.STDOUT)

    ## Todo: At this point update the progress bar to a hard coded 5% for now and feedback that the auth test is complete.

    # Fetch Moin wiki data subdirs 'pages' and 'user' from moin-vm
    subprocess.check_output(['%s/sync-moin-project.sh %s' % (moinpath, moinwiki)],shell=True, stderr=subprocess.STDOUT)

    # rename FrontPage to Home only if checked
    if renametohome == 'true':
        subprocess.check_output(['%s/mv-FrontPage-to-Home.sh %s' % (moinpath, moinwiki)],shell=True, stderr=subprocess.STDOUT)

    # Export the moin pages to txt format before converting to Confluence format.
    # Save to a $moinwiki-pages-out directory for processing
    subprocess.check_output(['%s -e conf/%s' % (moinscript, exporterconf)],shell=True, stderr=subprocess.STDOUT)

    ## Todo: At this point update the progress bar to a hard codes 20% for now and inform that the initial export is complete.

    # Convert exported pages to Confluence format ..
    # .. and then import the pages to the Confluence space.
    subprocess.check_output(['%s -c conf/%s conf/%s %s/projects/%s/data/%s-pages-out' % (moinscript, settingsconf, converterconf, moinpath, moinwiki, moinwiki)],shell=True, stderr=subprocess.STDOUT)

    ## Todo: Somewhere here we could count total pages exported in the previous step and update the progress bar as a percentage of 80%/numpages left

    # All done!

    sscommon.sendemail("%s@apache.org" % requser, "Moin wiki %s successfully migrated to Confluence space %s" % (moinwiki, space),
"""
Hi there,
As requested by %s@apache.org, migration from moin wiki %s to Confluence space has been completed at:
https://cwiki.apache.org/confluence/display/%s

""" % (requser, moinwiki, space))

    sscommon.slack("Migration from Moin wiki %s to Confluence space, <https://cwiki.apache.org/confluence/display/%s>, has been completed as requested by %s@apache.org." % (moinwiki, space, requser))
    print("Status: 201 Created\r\n\r\n<h2>Moin to Confluence migration completed!</h2>Your moin wiki has been migrated to Confluence, and can be accessed at: <a href='https://cwiki.apache.org/confluence/display/%s'>https://cwiki.apache.org/confluence/display/%s</a>." % (space, space))

except subprocess.CalledProcessError as err:
    uid = uuid.uuid4()
    with open("/tmp/%s.log" % uid, "w") as f:
        f.write(err.output)
        f.close()

    sscommon.slack("A moin wiki (%s) to Confluence migration, <https://cwiki.apache.org/confluence/display/%s>, was attempted as requested by %s@apache.org, however one of more components of the setup failed. /tmp/%s.log may have more information" % (moinwiki, space, requser, uid))
    print("Status: 500 Creation failed\r\n\r\n<h2>Moin to Confluence migration failed!</h2><pre>Migration may have failed. Contact an administrator for more information.\nError ID: %s</pre>" % uid)
