#####################################################
# Script for finding diffs between mino and mbox-vm
# Usage:
# LIST DIRS WITH AN MBOX ENTRY THIS MONTH:
#   python compare-mbox-dirs.py listdirs > $foo.json
#
# COMPARE TWO LISTDIR JSONS:
#   python compare-mbox-dirs.py comparedirs $foo.json $bar.json
#
# GET NO. OF EMAILS THIS MONTH IN EACH DIR:
#   python compare-mbox-dirs.py getmonth $foo.json
#
#!/usr/bin/env python

import sys
import os
import mailbox
import email
import gzip
import re
import json
import sets
import time
import datetime

def unzip(filepath):
    try:
        with open(fullpath, "rb") as bf:
            bmd = bf.read()
            bf.close()
            bmd = gzip.decompress(bmd)
            tmpfile = tempfile.NamedTemporaryFile(mode='w+b', buffering=1, delete=False)
            tmpfile.write(bmd)
            tmpfile.flush()
            tmpfile.close()
            tmpname = tmpfile.name
            fullpath = tmpname
            return tmpfile.name
    except Exception as err:
        print("This wasn't a gzip file: %s" % err )
        return None
    

minopath = ["/home/apmail/public-arch", "/home/apmail/private-arch"]
mboxpath = ["/x1/archives", "/x1/private"]

# Figure out where we are
which = 'minotaur' if os.path.exists(minopath[0]) else 'mboxvm'
whichpaths = minopath if (which == 'minotaur') else mboxpath


def listdirs():
    mlpaths = {}
    for path in whichpaths:
        ll = [x for x in os.listdir(path) if
                 os.path.isdir(os.path.join(path, x))
            ]
        for l in ll:
            # Private and public on mino use different names,
            # figure it out anyway
            r = re.match(r"^(\S+)-(\S+)$", l)
            # Private on mino?
            if r:
                listname = "%s@%s.apache.org" % (r.group(2), r.group(1)) # ponymail-private -> private@ponymail.apache.org
                now = datetime.datetime.now()
                mboxfile = "%04s%02s" % (now.year, now.month)
                listpath = os.path.join(path, l)
                mboxpath = os.path.join(listpath, mboxfile)
                if which == 'mboxvm':
                    mboxpath = mboxpath + ".mbox"
                if os.path.exists(mboxpath) and os.path.getsize(mboxpath) > 0:
                    listname = listname.replace(".incubator", "")
                    mlpaths[listname] = listpath
            # Every other location?
            else:
                tlppath = os.path.join(path, l)
                lists = [x for x in os.listdir(tlppath) if
                     os.path.isdir(os.path.join(tlppath, x))
                ]
                for listpart in lists:
                    listname = "%s@%s" % (listpart, l) # ponymail.apache.org/dev/ -> dev@ponymail.a.o
                    now = datetime.datetime.now()
                    mboxfile = "%04s%02s" % (now.year, now.month)
                    listpath = os.path.join(tlppath, listpart)
                    mboxpath = os.path.join(listpath, mboxfile)
                    if which == 'mboxvm':
                        mboxpath = mboxpath + ".mbox"
                    if os.path.exists(mboxpath) and os.path.getsize(mboxpath) > 0:
                        listname = listname.replace(".incubator", "")
                        mlpaths[listname] = listpath

    print(json.dumps(mlpaths, indent = 2))

def getMonthData(djson):
    mlnums = {}
    for listname, listpath in djson.iteritems():
        sys.stderr.write("%s: ..." % listpath)
        num = 0
        now = datetime.datetime.now()
        mboxfile = "%04s%02s" % (now.year, now.month)
        mboxpath = os.path.join(listpath, mboxfile)
        if which == 'mboxvm':
            mboxpath = mboxpath + ".mbox"
        if os.path.exists(mboxpath):
            sys.stderr.write("Found!\n")
            sys.stderr.flush()
            messages = mailbox.mbox(mboxpath, create=False)
            num = len(messages)
        else:
            sys.stderr.write("NOT FOUND!\n")
            sys.stderr.flush()
        mlnums[listname] = num
    print(json.dumps(mlnums, indent = 2))
    
if sys.argv[1] == 'listdirs':
    listdirs()

if sys.argv[1] == 'getmonth':
    f1 = json.load(open(sys.argv[2]))
    getMonthData(f1)
    
if sys.argv[1] == 'comparemonth':
    f1 = json.load(open(sys.argv[2]))
    f2 = json.load(open(sys.argv[3]))
    

if sys.argv[1] == 'comparedirs':
    f1 = json.load(open(sys.argv[2]))
    f2 = json.load(open(sys.argv[3]))
    
    s1 = set(f1.keys())
    s2 = set(f2.keys())
    print("Set 1 has %u lists" % len(s1))
    print("Set 2 has %u lists" % len(s2))
    print("Diff is:")
    diff1 = list(s1 - s2)
    diff2 = list(s2 - s1)
    if diff1:
        print("%s has these, %s does not:" % (sys.argv[2], sys.argv[3]))
        print(diff1)
    if diff2:
        print("%s has these, %s does not:" % (sys.argv[3], sys.argv[2]))
        print(diff2)
    else:
        print("No diff found!")
