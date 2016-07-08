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

# exec a command in cluster of computers specified in clst_list.txt
#note that 
# <<'EOF'
#$PASS
#EOF
#"
# MUST NOT HAVE ANY CHARACTER at the end of EACH STRING. NEWLINE IS MANDATORY


# This script allows the administrator to send a sudo command to each node of the cluster


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




# Does not execute commands on owner machines
echo; echo -n "HOSTS: ${hosts[@]}"; echo; echo;
echo -n "List the host names to be excluded (e.g. iah522.ncl.ac.uk): "; read -r excl_hosts; echo;
excl_hosts=(${excl_hosts});
for excl_host in ${excl_hosts[@]}
do
  declare -a hosts=( ${hosts[@]/"${admin}@${excl_host}"/} )
done


echo; echo -n "HOSTS: ${hosts[@]}"; echo; echo;
echo -n "Enter the sudo command to execute: "; read -r EXEC; echo; 
echo -n "Do you want to inform every logged users [yY/nN]: "; read -r WALL; echo;
echo -n "Enter cluster password: "; read -r -s PASS; echo; 



# send 3 warning messages to all logged users.
# 2>&- is required for avoiding "cannot get tty name: Invalid argument linux"
if [ ${WALL} = "y" -o ${WALL} = "Y" ]; then

  for ((i=${#hosts[*]}-1 ; $i >=0 ; i-- )); 
  do
      eval ping -c 3 ${ips[i]}
      if [ "$?" == "0" ]; then
	ssh ${hosts[$i]} "wall <<< ' This machine will shut down within 5 minute! 
Please, save your data and logout! ' "
      fi
  done

  
  sleep 4m

  
  
  for ((i=${#hosts[*]}-1 ; $i >=0 ; i-- )); 
  do
      eval ping -c 3 ${ips[i]}
      if [ "$?" == "0" ]; then
	ssh ${hosts[$i]} "wall <<< 'Last call!!!!!!
This machine is shutting down within 1 minute!!!!
Please, save your data and logout!!!!!!'  "
      fi
  done
  
  
  sleep 55s

  
  
  for ((i=${#hosts[*]}-1 ; $i >=0 ; i-- )); 
  do
      eval ping -c 3 ${ips[i]}
      if [ "$?" == "0" ]; then
	ssh ${hosts[$i]} "wall <<< 'By-ye !!! :-)' "
      fi
  done
  
  
  sleep 5s

  
fi




# apply the command: first the clients, then the server. 
for ((i=${#hosts[*]}-1 ; $i >=0 ; i-- )); 
do 
    eval ping -c 3 ${ips[i]}
    if [ "$?" == "0" ]; then
      echo;
      echo -n "${hosts[$i]}";echo;
      ssh -t -t -t ${hosts[$i]} "sudo -S $EXEC << 'EOF'
$PASS
EOF
"
    else
      echo "---- COULD NOT CONNECT TO ${hosts[$i]} ----"
    fi
done


