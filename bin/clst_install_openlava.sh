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


# install openlava on the cluster of computers specified in clst_list.txt
# Make sure to have installed the following packages on the machines which 
# will compile openlava (use the script clst_install_packages.sh):
#
# gcc-multilib g++-multilib ncurses-dev build-essential bison byacc flex tcl-dev
#
#
# 
#


#MY_DIR=`dirname $0`
. ${CLST_LIB}/io/clst_read_db.sh


# # # Retrieve the admin name
admin=`get_admin "${CLST_DIR}/etc/db/admin"`

# Retrieve the full list of hosts
db=`get_list_hosts "${CLST_DIR}/etc/db/clst_db_nodes"`
hosts=(`get_comp db[@] "hosts"`)
ips=(`get_comp db[@] "ips"`)
mac=(`get_comp db[@] "mac"`)

## BUG THE COMMENTED COMMENTS DO NOT WORK ANYMORE..
# Exclude the following nodes
# clean_db=`exclude_hosts "${CLST_DIR}/etc/db/clst_excl_nodes" hosts[@] ips[@] mac[@]`
# hosts=(`get_comp clean_db[@] "hosts"`)
# ips=(`get_comp clean_db[@] "ips"`)
# mac=(`get_comp clean_db[@] "mac"`)


# Attach the admin name to each host.
#hosts=(`bind_user_host $admin hosts[@]`)
# echo $admin
# echo $hosts

hosts[0]="$admin@ariel"
echo $hosts


openlava="openlava-3.3"
openlava_version="3.3"
install_path="/opt"



echo ""
echo "#############################################"
echo "##########  INSTALLING OPENLAVA  ############"
echo "#############################################"

echo -n "HOSTS: ${hosts[@]}"; echo; echo;
echo -n "Enter cluster password: "; read -r -s PASS; echo; 



echo ""
echo "COMPILATION OF OPENLAVA ON THE MASTER NODE"


# Compile openlava on the nodes you require. 
for (( i=0; i < ${#hosts[@]}; i++ ))
do

  echo ""
  echo "#############################################"
  echo "Creating openlava files on node: ${hosts[i]}"
  echo "#############################################"

  eval ping -c 3 ${ips[i]}
  # if pings are not returned/forbidden, then check for individual services (e.g. ssh --> port 22) through nmap
  #eval nmap $host -p 22 --max-retries 10 | grep -q open
  if [ "$?" == "0" ]; then
    # for the master nodes only

    
    ssh ${hosts[i]} "rm -rf openlava*"
    # echo "Dowloading openlava..."
    ssh ${hosts[i]} "wget --output-document=${openlava}.tar.gz https://github.com/openlava/openlava/archive/${openlava_version}.tar.gz"
     
     
     echo "Compile  openlava on ${hosts[i]}"     
     ssh ${hosts[i]} "tar xvzf ${openlava}.tar.gz ; cd ${openlava} ; find * -print0 | xargs -0 touch -d 20160118 ; ./bootstrap.sh ; ./configure ; make clean ; make uninstall ; find * -print0 | xargs -0 touch -d 20160118 ; make ; cd ~/" 
##     ssh ${hosts[i]} "tar xvzf ${openlava}.tar.gz ; cd ${openlava} ; ./configure ; make ; cd ~/"     
    
    echo ""
    echo "Transfer lsf.cluster.openlava file on ${hosts[i]}"
    ssh ${hosts[i]} "mkdir -p ~/lsf_config"
    scp ${CLST_DIR}/etc/openlava/lsf_config/* ${hosts[i]}:~/lsf_config/
  else 
      echo "---- COULD NOT CONNECT TO ${hosts[i]} ----"
      if [ "$i" == "0" ]; then
       echo "Connection to cluster master node failed. This script is terminated."
       exit 1
      fi      
  fi    
done






# iterates on each element ${hosts[@]} except for the servers iah372 and iah372backup
for (( i=0; i < ${#hosts[@]}; i++ ))
do

    echo ""
    echo "#############################################"
    echo "Installing openlava on node: ${hosts[i]}"
    echo "#############################################"


    eval ping -c 3 ${ips[i]}
    # if pings are not returned/forbidden, then check for individual services (e.g. ssh --> port 22) through nmap
    #eval nmap $host -p 22 --max-retries 10 | grep -q open
    if [ "$?" == "0" ]; then
    
    
      echo "Stopping openlava service on ${hosts[i]} (if running)"


      ssh -t -t -t ${hosts[i]} "sudo -S service openlava stop <<'EOF'
$PASS
EOF
"         
      ssh -t -t -t ${hosts[i]} "sudo -S rm -rf ${install_path}/$openlava <<'EOF'
$PASS
EOF
"    
      ssh -t -t -t ${hosts[i]} "sudo -S rm -rf /etc/profile.d/openlava* <<'EOF'
$PASS
EOF
"  
      ssh -t -t -t ${hosts[i]} "sudo -S rm -rf /etc/init.d/openlava <<'EOF'
$PASS
EOF
"    
      ssh -t -t -t ${hosts[i]} "sudo -S rm -rf /etc/rc3.d/openlava <<'EOF'
$PASS
EOF
"    




      echo "Installation on ${hosts[i]}"
      ssh -t -t -t ${hosts[i]} "cd $openlava ; sudo -S make install <<'EOF'
$PASS
EOF
"

      echo "Transfer lsf.cluster.openlava file on ${hosts[i]}"
      ssh -t -t -t ${hosts[i]} "sudo -S cp ~/lsf_config/* ${install_path}/${openlava}/etc/ <<'EOF'
$PASS
EOF
"





      echo "Add permissions, copy links and start openlava service on ${hosts[i]}"
      ssh -t -t -t ${hosts[i]} "sudo -S chown -R root:root ${install_path}/${openlava}/etc/lsf* <<'EOF'
$PASS
EOF
"
      ssh -t -t -t ${hosts[i]} "sudo -S chmod u=rwx,g=rx,o=rx ${install_path}/${openlava}/etc/openlava* <<'EOF'
$PASS
EOF
"
      ssh -t -t -t ${hosts[i]} "sudo -S ln -fs ${install_path}/${openlava}/etc/openlava* /etc/profile.d/ <<'EOF'
$PASS
EOF
"    
      # this is crucial
      ssh -t -t -t ${hosts[i]} "sudo -S ln -fs ${install_path}/${openlava}/etc/openlava /etc/init.d/ <<'EOF'
$PASS
EOF
"    
      ssh -t -t -t ${hosts[i]} "sudo -S ln -fs /etc/init.d/openlava /etc/rc3.d/ <<'EOF'
$PASS
EOF
"   

# THIS REQUIRES EDITING OF /etc/environment  : =>> Add ${install_path}/bin folder to PATH
      ssh -t -t -t ${hosts[i]} "sudo -S ln -fs ${install_path}/$openlava/bin/* ${install_path}/bin <<'EOF'
$PASS
EOF
"    



      echo "Starting openlava service on ${hosts[i]}"
      ssh -t -t -t ${hosts[i]} "sudo -S sh /etc/profile.d/openlava stop <<'EOF'
$PASS
EOF
"  
      ssh -t -t -t ${hosts[i]} "sudo -S service openlava start <<'EOF'
$PASS
EOF
"



    #sleep 2m; # this helps the synchronisation of the home folder across each node.

    else
      echo "---- COULD NOT CONNECT TO ${hosts[i]} ----"
    fi

done
    
