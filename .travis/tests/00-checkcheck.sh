#!/bin/bash -xv

# conf files
conf_files="share/etc/sysctl.d/bridge-nf-call.conf
share/etc/oned.conf
share/pkgs/CentOS7/opennebula.conf
share/pkgs/CentOS7/opennebula-node.conf
src/authm_mad/remotes/ldap/ldap_auth.conf
src/authm_mad/remotes/server_x509/server_x509_auth.conf
src/authm_mad/remotes/x509/x509_auth.conf
src/sunstone/etc/sunstone-server.conf
src/sunstone/public/app/tabs/vms-tab/panels/conf
src/sunstone/public/app/tabs/vms-tab/form-panels/updateconf
src/sunstone/public/node_modules/extsprintf/jsl.node.conf
src/sunstone/public/node_modules/faye-websocket/examples/haproxy.conf
src/sunstone/public/node_modules/node-sass/src/libsass/Makefile.conf
src/onegate/etc/onegate-server.conf
src/datastore_mad/remotes/ceph/ceph.conf
src/datastore_mad/remotes/fs/fs.conf
src/im_mad/remotes/lxd-probes.d/pci.conf
src/im_mad/remotes/kvm-probes.d/pci.conf
src/im_mad/remotes/node-probes.d/pci.conf
src/scheduler/etc/sched.conf
src/vnm_mad/remotes/OpenNebulaNetwork.conf
src/vmm_mad/remotes/az/az_driver.conf
src/vmm_mad/remotes/ec2/ec2_driver.conf
src/vmm_mad/exec/vmm_exec_kvm.conf
src/vmm_mad/exec/vmm_exec_vcenter.conf
src/cloud/ec2/etc/econe.conf
src/onedb/test/oned_sqlite.conf
src/onedb/test/oned_mysql.conf
src/market_mad/remotes/http/http.conf
src/tm_mad/fs_lvm/fs_lvm.conf
src/flow/etc/oneflow-server.conf"

SAVEIFS=$IFS  
IFS=$'\n'      
conf_files=($conf_files) # split to array $names
IFS=$SAVEIFS   # Restore IFS

echo "Branch:"$TRAVIS_BRANCH

if [[ $TRAVIS_BRANCH =~ (^one-) ]]; then
    echo "Checking difference in configuration files"
    export PREVIOUS_ONE=~/previous.one
    export CURRENT_ONE=$PWD
    git clone https://github.com/tinova/one $PREVIOUS_ONE
    (cd $PREVIOUS_ONE ; git checkout $TRAVIS_BRANCH ; git checkout HEAD^)
    # oned.conf
    
    for (( i=0; i<${#conf_files[@]}; i++ ))
    do
        diff $PREVIOUS_ONE/${conf_files[$i]} $CURRENT_ONE/${conf_files[$i]}
        [[ $? -ne 0 ]] && "OpenNebula configuration file changed: "${conf_files[$i]}
    done
fi
