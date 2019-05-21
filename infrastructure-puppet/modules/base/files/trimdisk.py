#!/usr/bin/env python3
"""
trimdisk.py - disk space trimmer.
usage: trimdisk.py [-h] -p PATH -m MAX [-d]
 
required arguments:
  -p PATH, --path PATH  Path to trim usage of (e.g. /x1)
  -m MAX, --max MAX     Max percentage of disk space to have in use
 
optional arguments:
  -e, --exclude         List of paths/dirs to exclude
  -q, --quiet           Quiet mode, do not print actons taken
  -h, --help            show this help message and exit
  -d, --debug           Debug mode, no files deleted
 
  
example:
  python3 trimdisk.py --path /x1 --max 70 --exclude .git .svn
 
"""
import os
import time
import argparse
 
# Parse args
parser = argparse.ArgumentParser()
parser.add_argument('-p','--path', type = str, help='Path to trim usage of (e.g. /x1)', required=True)
parser.add_argument('-m','--max', type = int, help='Max percentage of disk space to have in use', required=True)
parser.add_argument('-e','--exclude', nargs='+', help='List of paths/dirs to exclude', required=False)
parser.add_argument('-d','--debug', action='store_true', help='Debug mode, no files deleted', required=False)
parser.add_argument('-q','--quiet', action='store_true', help='Quiet mode, do not print actions taken', required=False)
args = parser.parse_args()
 
 
def get_used(path):
    """ Get used disk space, df style """
    disk = os.statvfs(path)
    # total non-root disk, df-style: blocks - diff between free and available
    disk_size = disk.f_frsize * (disk.f_blocks - (disk.f_bfree - disk.f_bavail))
    disk_free = disk.f_frsize * disk.f_bavail
    disk_used = (disk_size - disk_free)
    disk_pct_used = 100 - (100*disk_free/disk_size)
    return disk_pct_used, disk_size, disk_used
 
 
def get_stats(path, excludes, files):
    """ Get stats for all elements in a directory """
    for el in os.listdir(path):
        if el not in excludes:
            fp = os.path.join(path, el) # concat path and filename into full path
            if os.path.isdir(fp): # If dir, traverse it
                get_stats(fp, excludes, files)
            else: # If file, stat it (don't follow symlinks) and append to list
                vinfo = os.lstat(fp)
                files.append([vinfo.st_mtime, vinfo.st_size, fp])
            
 
def main():
    used, total, bused = get_used(args.path)
    print("%s is using %.1f%% of available disk space" % (args.path, used))
    
    # Figure out how much space we need to clear up
    space_freed = 0
    space_needed = (used - args.max) * total / 100
    
    # Do we need to clean up?
    if space_needed > 0:
        if space_needed > (1024**3):
            print("Need to free at least %.2f GB of space" % (space_needed/1024**3))
        else:
            print("Need to free at least %.2f MB of space" % (space_needed/1024**2))
        
        # Get all files and their info
        files = []
        get_stats(args.path, args.exclude if args.exclude else ['.git', '.svn'], files)
        
        # Sort by age
        files.sort(key = lambda x: x[0])
        
        print("Found %u files" % len(files))
        if (args.debug):
            print("Debug mode, not going to remove files")
        
        fd = 0
        for el in files:
            fp = el[2]
            bs = el[1]
            if not args.quiet:
                print("Removing %s (%u bytes)" % (fp, bs))
            if not args.debug:
                os.unlink(fp)
            space_freed += bs
            fd += 1
            if space_freed >= space_needed:
                print("We freed enough space, quitting.")
                break
        
        used, total, bused = get_used(args.path)
        print()
        print("Summary for %s:" % args.path)
        print("-----------------------------------")
        print("Files deleted: %20u" % fd)
        print("Bytes freed:   %20u" % space_freed)
        print("New disk usage percentage: %7.2f%%" % used)
        print("------------------------------------")
    else:
        print()
        print("Summary for %s:" % args.path)
        print("-----------------------------------")
        print("No files needed to be removed.")
        print("-----------------------------------")
    
 
if __name__ == '__main__':
    main()
