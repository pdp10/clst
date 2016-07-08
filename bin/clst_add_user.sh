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


# Script to add a user to Linux system (only for a cluster of few computers).
# NOTE: NIS, NIS+ or LDAP should be employed for proper users management.

# ${def_home}/clst_admin/add_user.sh must be in the machine in which we want to 
# add the new user (this is easy done by putting in a shared NFS folder).



#MY_DIR=`dirname $0`
. ${CLST_LIB}/io/clst_read_db.sh


# # # Retrieve the admin name
admin=`get_admin "${CLST_DIR}/etc/db/admin"`

# Retrieve the full list of hosts
db=`get_list_hosts "${CLST_DIR}/etc/db/clst_db_nodes"`
hosts=(`get_comp db[@] "hosts"`)
ips=(`get_comp db[@] "ips"`)
mac=(`get_comp db[@] "mac"`)

# Exclude the following nodes
clean_db=`exclude_hosts "${CLST_DIR}/etc/db/clst_excl_nodes" hosts[@] ips[@] mac[@]`
hosts=(`get_comp clean_db[@] "hosts"`)
ips=(`get_comp clean_db[@] "ips"`)
mac=(`get_comp clean_db[@] "mac"`)

# Attach the admin name to the host.
hosts=(`bind_user_host $admin hosts[@]`)




echo ""
echo "#############################################"
echo "##########  Adding New User: ################"
echo "#############################################"



# Does not execute commands on owner machines
declare -a hosts=( ${hosts[@]/"${admin}@iah522.ncl.ac.uk"/} ) # piero's machine
declare -a hosts=( ${hosts[@]/"${admin}@iah502.ncl.ac.uk"/} ) # philip's machine


echo -n "HOSTS: ${hosts[@]}"; echo; echo;
echo -n "Enter cluster password: "; read -r -s PASS; echo; echo;


printf "Insert the details for the new user to add:\n"

read -p "Username    :  " username
read -p "Password    :  " password   # should be shadowed..
read -p "UID-GID     :  " uid
read -p "Full name   :  " fullname
#read -p "Home folder :  " def_home
#read -p "Shell       :  " def_shell

def_home="/home/modellers"
def_shell="/bin/bash"



# list of arguments to be passed to the command
args=" ${username} ${password} ${uid} '${fullname[@]}' ${def_home} ${def_shell} "




for (( i=0; i < ${#hosts[*]}; i++ ))
do

    eval ping -c 3 ${ips[i]}
    # if pings are not returned/forbidden, then check for individual services (e.g. ssh --> port 22) through nmap
    #eval nmap $host -p 22 --max-retries 10 | grep -q open
    if [ "$?" == "0" ]; then

      echo "#############################################"
      echo "...processing node: ${hosts[i]}"
      echo "#############################################"

      ssh -t -t -t ${hosts[i]} "sudo -S sh ${def_home}/clst_admin/add_user.sh ${args} << 'EOF'
$PASS
EOF
"
    else 
      echo "---- COULD NOT CONNECT TO ${hosts[i]} ----"
      if [ "$i" == "0" ]; then
       echo "Connection to cluster master node failed. This script is terminated."
       exit 1
      fi
    fi
done

