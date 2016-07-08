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

# This script turn on a set of computers by sending magic messages on Lan.




#MY_DIR=`dirname $0`
. ${CLST_LIB}/io/clst_read_db.sh


# Retrieve the full list of hosts
db=`get_list_hosts "${CLST_DIR}/etc/db/clst_db_nodes"`
hosts=(`get_comp db[@] "hosts"`)
ips=(`get_comp db[@] "ips"`)
mac=(`get_comp db[@] "mac"`)


#echo "HOSTS: ${hosts[@]}"; echo;
#echo "IPS: ${ips[@]}"; echo;
#echo "MAC: ${mac[@]}"; echo;

# test
#hosts=( iah522.ncl.ac.uk iah372.ncl.ac.uk )
#ips=( 10.64.48.107 10.64.50.59 )
#mac=( d4:be:d9:a6:b2:6c 00:25:64:a2:15:7d )

port=9 # the discard port
status=()



# Does not execute commands on owner machines
echo; echo -n "HOSTS: ${hosts[@]}"; echo; echo;
echo -n "List the host names to be excluded (e.g. iah522.ncl.ac.uk): "; read -r excl_hosts; echo;
excl_hosts=(${excl_hosts});
for excl_host in ${excl_hosts[@]}
do
  declare -a hosts=( ${hosts[@]/"${admin}@${excl_host}"/} )
done



echo ""
echo -n "Ready for waking up the following computers:"; echo;
for (( i=0; i < ${#hosts[@]}; i++ ))
do
    printf " (${i}) ${hosts[i]} \t ${ips[i]} \t ${mac[i]}\n"; 
done



# Use the utility wakeonlan to wake up the computers. 
# A local version of wakeonlan is provided since it might be 
# that it is not installed in the current machine. 
# which returns the full path of the command 
wake=`which wakeonlan | xargs`


for (( i=0; i < ${#hosts[@]}; i++ ))
do
    echo;
    echo -n "Check current status for ${hosts[i]} (IP:${ips[i]}  MAC:${mac[i]}):"; echo; echo;
    # if the host answers ping
    eval ping -c 10 ${ips[i]}
    # if pings are not returned/forbidden, then check for individual services (e.g. ssh --> port 22) through nmap
    #eval nmap $host -p 22 --max-retries 10 | grep -q open
    if [ "$?" == "0" ]; then
	echo -n "=> ${hosts[i]} is already up!"; echo; 
	status+=("UP");
    else
	echo -n "=> ${hosts[i]} is currently down... wake up on lan in progress"; echo;
	
	${wake} -i ${ips[i]} -p ${port} ${mac[i]}
	# NOTE: 
	# if executed in the same network, the previous command does not work... bug? 
        # Therefore, the following direct command is run too.
	${wake} -p ${port} ${mac[i]}

	# Test if computer is online after waiting his booting
	sleep 45s
        eval ping -c 10 ${ips[i]}
        if [ "$?" == "0" ]; then
	    echo -n "=> ${hosts[i]} is now up!"; echo; 
  	    status+=("UP *woken up*");
        else
	    echo -n "=> WARNING! ${hosts[i]} does not wake up! Maybe, try later."; echo; 
            status+=("DOWN");
	fi
    fi
done


# Summary of the procedure
printf "\n\n\nSummary:\n\n";
for (( i=0; i < ${#hosts[@]}; i++ ))
do
    printf " (${i}) ${hosts[i]} \t ${ips[i]} \t ${mac[i]} \t........... ${status[i]}\n"; 
done



### See you below for the single commands:

### npdp2 s computers
### iah522
#echo -n "=> iah522.....up"; echo; 
#wakeonlan -i 10.64.48.107  d4:be:d9:a6:b2:6c
### iah372 
#echo -n "=> iah372.....up"; echo; 
#wakeonlan -i 10.64.50.59 00:25:64:a2:15:7d   


### Cluster
### iah526
#echo -n "=> iah526.....up"; echo; 
#wakeonlan -i 10.68.32.153  5c:f9:dd:6b:10:f9
###iah527
#echo -n "=> iah527.....up"; echo; 
#wakeonlan -i 10.68.32.154  5c:f9:dd:6b:07:db
###iah528
#echo -n "=> iah528.....up"; echo; 
#wakeonlan -i 10.68.32.155  5c:f9:dd:6b:1d:87
### iah529
#echo -n "=> iah529.....up"; echo; 
#wakeonlan -i 10.68.32.157  5c:f9:dd:6b:1d:bf
### iah-huygens: 
#echo -n "=> iah-huygens.....up"; echo; 
#wakeonlan -i 10.64.48.114  18:03:73:1b:0d:03



