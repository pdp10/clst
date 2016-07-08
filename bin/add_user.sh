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


# Script to add a user to Linux system.
# NOTE: NIS, NIS+ or LDAP should be employed for proper users management.


# Input strings. Note: fullname must receive a 'list of strings' between single quotes.
username=$1
password=$2
uid=$3
fullname=$4
def_home=$5
def_shell=$6


echo "Adding new user: ${username}:x:${uid}:${uid}:${fullname}:${def_home}:${def_shell} to "; hostname; echo;


# Script to add a user to Linux system (only root can do this)
if [ $(id -u) -eq 0 ]; then

  egrep "^${username}" /etc/passwd >/dev/null
  if [ $? -eq 0 ]; then
    echo "${username} exists!"
    exit 1;
  fi

  egrep "^${uid}" /etc/passwd >/dev/null
  if [ $? -eq 0 ]; then
    echo "${uid} exists!"
    exit 2;
  fi

  pass=$(perl -e 'print crypt($ARGV[0], "password")' ${password})
  useradd -m -p ${pass} ${username}
  if [ $? -eq 0 ] ; then
    usermod -u ${uid} ${username}
    groupmod -g ${uid} ${username}
    #usermod -g ${uid} ${username}
    usermod -d ${def_home}/${username} ${username}
    usermod -s ${def_shell} ${username}
    mkdir -p ${def_home}/${username}
    chown ${username}:${username} ${def_home}/${username}
    chfn -f "${fullname}" ${username}
    # remove automatically created home folder
    rm -rf /home/${username}
    echo "User has been added to the system!"
  else
    echo "Failed to add a user!"
    exit 3
  fi

fi

