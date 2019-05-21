    #!/usr/bin/env python3
     
    import os
    import sys
    import subprocess
    import time
    import getpass
     
    GIT_ROOT = "/x1/repos/asf"
     
     
    def lock(l):
        """ Locks or unlocks all repos. If unlocking, also syncs with github first """
        repos = sorted([f for f in os.listdir(GIT_ROOT) if f.endswith('.git')])
        for repo in repos:
            lockfile = "%s/%s/nocommit" % (GIT_ROOT, repo)
            # lock?
            if l:
                print("Locking %s" % repo)
                open(lockfile, "w").write("nope!")
            # unlock?
            else:
                print("Syncing %s from GitHub" % repo)
                os.chdir(os.path.join(GIT_ROOT, repo))
                # Try up to five times to sync, github may sometimes bork it
                while i < 5 and rv:
                    i += 1
                    p = subprocess.Popen(["git", "fetch", "--prune"],
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE)
                    output,error = p.communicate()
                    rv = p.poll()
                if not rv:
                    print("Synced %s" % repo)
                    # If sync worked, it's not broken. If broken .txt exists, wipe it
                    try:
                        if os.path.exists("/x1/gitbox/broken/%s.txt" % reponame):
                            os.unlink("/x1/gitbox/broken/%s.txt" % reponame)
                    except:
                        pass # Fail silently, it's not that important
                else:
                    print("Sync borked, retrying...")
                    time.sleep(1)
     
                print("Unlocking %s" % repo)
                if os.path.exists(lockfile):
                    os.unlink(lockfile)
        print("All done here :-)")
     
    if __name__ == '__main__':
        # MUST be www-data here
        uid = getpass.getuser()
        if uid != 'www-data':
            print("This script must be run as www-data, you are %s!" % uid)
            sys.exit(-1)
     
        # Usage
        if len(sys.argv) < 2:
            print("Usage: gitlock.py (lock|unlock)")
            sys.exit(0)
        
        # Lock / Unlock cmd
        if sys.argv[1] == 'lock':
            setlock(True)
        elif sys.argv[1] == 'unlock':
            setlock(False)
        
