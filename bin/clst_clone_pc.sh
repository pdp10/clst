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

# install 1 or more packages on the cluster of computers specified in clst_list.txt


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
echo "Clone Kubuntu machine"
echo "#############################################"

echo -n "Server: ${hosts[0]}"; echo; echo;
echo -n "Enter cluster password: "; read -r -s PASS; echo; 
echo -n "Enter the hostname of the machine to add to the cluster: "; read -r new_host; echo; 

new_host="${admin}@${new_host}"


# Install automated ssh for avoiding inserting passwords
echo -n "Install automated ssh access? [y/n]"; read -r autossh; echo;
if [ "${autossh}" == "y" ]; then 
  ssh ${new_host} mkdir -p .ssh
  cat .ssh/id_rsa.pub | ssh ${new_host} 'cat >> .ssh/authorized_keys'
fi


# Clone list of packages from the server to the new host
echo -n "Clone packages? [y/n]"; read -r clone; echo;
if [ "${clone}" == "y" ]; then 
  echo; echo -n "Cloning ${new_host} from ${hosts[0]} (BE CAREFUL ON POTENTIAL ERRORS (e.g. kernel errors)) "; echo; echo;

  # Get the most update list of packages from the cluster
  ssh ${hosts[0]} "dpkg --get-selections > ~/clst_packages"
  # Copy the list of packages to the new machine
  scp ${hosts[0]}:~/clst_packages ${new_host}:~/clst_packages

  # clean old packages, deb files and old selections
  ssh -t -t -t ${new_host} "sudo -S apt-get autoremove << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S apt-get clean << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S apt-get autoclean << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S dpkg --clear-selections << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S dpkg --set-selections < clst_packages << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S apt-get dselect-upgrade << 'EOF'
$PASS
EOF
"
fi



# Copy the user and group lists
echo -n "Copy folders /etc/passw and /etc/group from server to new machine? [y/n]"; read -r users; echo;
if [ "${users}" == "y" ]; then
  scp ${hosts[0]}:/etc/passwd ${new_host}:~/
  scp ${hosts[0]}:/etc/group ${new_host}:~/
  ssh -t -t -t ${new_host} "sudo -S mv /etc/passwd /etc/passwd.backup << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S mv /etc/group /etc/group.backup << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S mv ~/passwd /etc/passwd << 'EOF'
$PASS
EOF
"
  ssh -t -t -t ${new_host} "sudo -S mv ~/group /etc/group << 'EOF'
$PASS
EOF
"
fi


