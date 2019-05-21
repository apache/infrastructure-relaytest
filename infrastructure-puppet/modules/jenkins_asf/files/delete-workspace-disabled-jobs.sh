#!/usr/local/bin/bash

############################################################################
# Licensed to the Apache Software Foundation (ASF) under one or more       #
# contributor license agreements.  See the NOTICE file distributed with    #
# this work for additional information regarding copyright ownership.      #
# The ASF licenses this file to you under the Apache License, Version 2.0  #
# (the "License"); you may not use this file except in compliance with     #
# the License.  You may obtain a copy of the License at                    #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
############################################################################

###############################################################
# This script checks jenkins config for any disabled jobs.    #
# It then checks the jenkins config for a list of nodes.      #
# It then sends a text file list of disabled jobs to all      #
# those nodes. Then it SSH as the jenkins user to each node   #
# in turn , iterating through the text file looking for       #
# matching directories. If any are found, it grabs the size   #
# of the directory for logging purposes and then goes ahead   #
# and deletes that directory and its contents.                #
# Finally, it sends a log file back to jenkins master         #
# detailing what it did, before then moving to the next node. #
###############################################################

RUN_AS_USER=jenkins
NODES_DIR=/x1/jenkins/jenkins-home/nodes/
JOBS_DIR=/x1/jenkins/jenkins-home/jobs/
DISABLED_JOBS_LIST='/tmp/disabled-jobs-list.txt'
NODES_LIST='/tmp/nodeslist.txt'
LOGS_DIR='/x1/jenkins/logs'
MASTER_HOSTNAME='jenkins01.apache.org'
HOSTNAME=`/bin/hostname -f`

# Only makes sense to run this on jenkins master.
if [ "$HOSTNAME" = "$MASTER_HOSTNAME" ]; then

# run this script as the jenkins user
if [[ `whoami` != $RUN_AS_USER ]];then
  echo "Please run this script as the $RUN_AS_USER user only."
  exit 1
fi

# Below grep is disabled as it finds offline nodes we cant get to.
# So uses a static list until we maybe use a json file to get an
# upto date accurate live list.

# cd $NODES_DIR
# grep -ir host\> */config.xml | cut -d \> -f2 | cut -d \< -f1 > $NODES_LIST

cd $JOBS_DIR
grep -ir disabled\>true */config.xml | cut -d / -f1 > $DISABLED_JOBS_LIST

if [[ -f "$NODES_LIST" ]]
  then
  while read -r node
  do
   echo "Transfering disabled jobs list to $node"
   rsync -avz $DISABLED_JOBS_LIST $node:$DISABLED_JOBS_LIST 
    echo "Logging in to node $node"
ssh -o BatchMode=yes -o ConnectionAttempts=1 -Ti $HOME/.ssh/id_rsa $node <<EOT
echo "Date: `date`" > /tmp/node-found-dirs.txt
echo "Results" >> /tmp/node-found-dirs.txt
echo "-------" >> /tmp/node-found-dirs.txt
while read -r disabledlist
 do
  echo "checking for existance of /home/jenkins/jenkins-slave/\$disabledlist"
  if [[ -d "/home/jenkins/jenkins-slave/workspace/\$disabledlist" ]]
  then 
    du -sh /home/jenkins/jenkins-slave/workspace/\$disabledlist >> /tmp/node-found-dirs.txt
    echo "Removing directory"
    rm -rf /home/jenkins/jenkins-slave/workspace/\$disabledlist
    echo "Directory /home/jenkins/jenkins-slave/workspace/\$disabledlist removed" >> /tmp/node-found-dirs.txt
  else
    echo "no results for /home/jenkins/jenkins-slave/\$disabledlist" >> /tmp/node-found-dirs.txt
  fi
 done < /tmp/disabled-jobs-list.txt # end of ssh and delete

EOT
  echo "copying node-found-dirs.txt to jenkins-master"
  rsync $node:/tmp/node-found-dirs.txt $LOGS_DIR/$node-`date`.txt
  done < $NODES_LIST # end of iterating all nodes
fi
else
echo "Please run this script on the Jenkins master only."
  exit 1
fi
