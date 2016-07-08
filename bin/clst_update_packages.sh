#!/bin/bash
# This file is part of sb_pipe.
#
# sb_pipe is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# sb_pipe is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with sb_pipe.  If not, see <http://www.gnu.org/licenses/>.
#
#
# $Revision: 1.0 $
# $Author: Piero Dalle Pezze $
# $Date: 2013-04-20 12:14:32 $


# update cluster of computers specified in clst_list.txt



#note that 
# <<EOF
#$PASS
#EOF
#"
# MUST NOT HAVE ANY CHARACTER at the end of EACH STRING. NEWLINE IS MANDATORY



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



# iah-huygens was intentionally discarded due to issue related to the previosu ATI graphic card
# which were solved after taking and installing iah372 nvidia graphic card.
#declare -a hosts=( ${hosts[@]/"${admin}@iah-huygens.ncl.ac.uk"/} )




echo ""
echo "#############################################"
echo "##############  UPDATE CLUSTER  #############"
echo "#############################################"

echo -n "HOSTS: ${hosts[@]}"; echo; echo;
echo -n "Enter cluster password: "; read -r -s PASS; echo; 


for (( i=0; i < ${#hosts[@]}; i++ ))
do

    echo "#############################################"
    echo "...processing node: ${hosts[i]}"
    echo "#############################################"

    eval ping -c 3 ${ips[i]}
    # if pings are not returned/forbidden, then check for individual services (e.g. ssh --> port 22) through nmap
    #eval nmap ${hosts[i]} -p 22 --max-retries 10 | grep -q open
    if [ "$?" == "0" ]; then

      ssh -t -t -t ${hosts[i]} "sudo -S apt-get update << 'EOF'
$PASS
EOF
"
      ssh -t -t -t ${hosts[i]} "sudo -S apt-get -y upgrade << 'EOF'
$PASS
EOF
"

    else
      echo "---- COULD NOT CONNECT TO ${hosts[i]} ----"
    fi
done