#!/usr/bin/env python
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

""" 

This script subs a recipient to all known apache.org lists.

TODO: 
- does not handle all restricted lists, e.g. fundraising-private (which is perhaps not supposed to be archived?)
- does not handle private lists
- does not allow for unarchived lists

"""
import re
import os
import sys
import subprocess

RECIPIENT = "archiver@mbox-vm.apache.org" # TO-DO: make a CLI arg??
HOMEDIR = "/home/apmail/lists"
EZCMD = "/usr/local/bin/ezmlm-sub" # Could be ezmlm-unsub for removing..
RESTRICTED = ['vp-brand', 'vp-fundraising']
RREC = "restricted@mbox-vm.apache.org"

def main():
    # Get all FQDNs
    # Should match *.apache.org and be a dir..
    fqdns = [x for x in os.listdir(HOMEDIR) if
             re.match(r"(?:.+\.)?apache\.org$", x) and
             os.path.isdir(os.path.join(HOMEDIR, x))
             ]
    print("Found %u matching FQDNs" % len(fqdns))
    lists = {}
    nolists = 0
    # For each list domain...
    for fqdn in fqdns:
        fqdnpath = os.path.join(HOMEDIR, fqdn)
        # Build list of lists, if is dir and has config file
        locallists = [x for x in os.listdir(fqdnpath) if
             os.path.isdir(os.path.join(fqdnpath, x)) and
             os.path.isfile(os.path.join(fqdnpath, x, 'config'))
             ]
        lists[fqdnpath] = locallists
        nolists += len(locallists)
    print("Found %u lists in total" % nolists)
    resp = raw_input("Sub %s to all %u lists? [y/n]" % (RECIPIENT, nolists))
    if resp.strip().lower() == "y":
        print("Subbing...")
        for path, listnames in lists.items():
            print(path)
            os.chdir(path)
            for l in listnames:
                print("- %s..." % l)
                try:
                    rec = RECIPIENT
                    if l in RESTRICTED:
                        rec = RREC
                    subprocess.check_output([EZCMD, l, rec], stderr=subprocess.STDOUT)
                except subprocess.CalledProcessError as err:
                    print("subscribing to %s failed: %s" % (l, err.output))
                    resp = raw_input("Continue with remaining lists? [y/n]")
                    if resp.strip().lower() != "y":
                        print("Aborting!")
                        sys.exit(-1)
    else:
        print("Aborting then..!")


if __name__ == '__main__':
    main()
