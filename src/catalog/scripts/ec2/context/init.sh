#!/bin/bash
# --------------------------------------------------------------------------
# Copyright 2002-2011, OpenNebula Project Leads (OpenNebula.org)
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# --------------------------------------------------------------------------

echo "Starting EC2 Metadata Server"

SERVER_PATH=/var/ec2one
SERVER_IP=169.254.169.254

if [ -f /mnt/context.sh ]; then
  . /mnt/context.sh
  
  if [ -n "$EC2ONE" ]; then
    ifconfig lo:1 $SERVER_IP
    
    mkdir -p /var/ec2one/
    tar -C /var/ec2one/ -xvf /mnt/$EC2ONE
    
    if [ -n "$PUBLIC_KEY" ]; then
      cat /mnt/$PUBLIC_KEY > $SERVER_PATH/latest/meta-data/public-keys/0/openssh-key
    fi
    
    if [ -n "$USER_DATA" ]; then
      cat /mnt/$USER_DATA > $SERVER_PATH/latest/user-data
    fi
    
    if [ -n "$AMI_ID" ]; then
      echo $AMI_ID > $SERVER_PATH/latest/meta-data/ami-id
    fi
    
    cd /var/ec2one
    python -m SimpleHTTPServer 80 &
  fi
fi
 
umount /mnt




exit 0