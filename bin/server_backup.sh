#!/bin/bash
#
# The MIT License (MIT)
# 
# Copyright (c) 2016 Piero Dalle Pezze
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# $Revision: 1.0 $
# $Author: Piero Dalle Pezze $
# $Date: 2013-04-20 12:14:32 $

# Script for full backup of the cluster server.


# Place in cron to execute it automatically (sudo crontab -e)
# # m h  dom mon dow   command
# 0 7 * * MON,THU sh /home/clst_server_cloning.sh

# references:
# (1) http://www.lullabot.com/blog/articles/simple-site-backups-rsync-ssh-and-sudo
# (2) https://gist.github.com/deviantintegral/0f1066650e3ea5c5ffc1
# This is executed on the backup machine ($DEST) (client)
# To allow backup, folders need permissions 755 


SERVER_ADDRESS="iah372.ncl.ac.uk"

SOURCE_HOME=/import/home/
DEST_HOME=/home/

SOURCE_OPT=/import/opt/
DEST_OPT=/opt/



echo ""
echo "#############################################"
echo "Server backup from $SERVER_ADDRESS"
echo "#############################################"


# Set the path to rsync on the remote server so it runs with sudo. NOTE 'single quotes' are required due to the space
RSYNC='/usr/bin/rsync'
 
# This is a list of files to ignore from backups.
EXCLUDES="/import/home/modellers/clst_admin/excludes"

# Retrieve the date_time
TODAY=$(date "+%y%m%d_%H%M")

# The path of the logs 
log_path="/home/modellers/clst_admin/logs/"



VAR=`ping -s 1 -c 1 $SERVER_ADDRESS > /dev/null; echo $?`
if [ $VAR -eq 0 ]; then


    echo ""
    echo "#############################################"
    echo "$SOURCE_HOME => $DEST_HOME"
    echo "#############################################"
    #--dry-run (n)       # test
    rsync -azAXv --exclude-from=$EXCLUDES --stats --progress --delete --numeric-ids --force --ignore-errors --log-file=${log_path}/backup_home__$TODAY.log $SOURCE_HOME $DEST_HOME

    echo ""
    echo "#############################################"
    echo "$SOURCE_OPT => $DEST_OPT"
    echo "#############################################"
    rsync -azAXv --exclude-from=$EXCLUDES --stats --progress --delete --numeric-ids --force --ignore-errors --log-file=${log_path}/backup_opt__$TODAY.log $SOURCE_OPT $DEST_OPT

    # changes the permissions so that only root can access these files
    chmod 600 ${log_path}/backup_opt__${TODAY}.log ${log_path}/backup_home__${TODAY}.log

else
    echo "Cannot connect to $SOURCE."
fi
