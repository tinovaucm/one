#!/bin/bash -xv

# conf files
conf_files="share/etc/sysctl.d/bridge-nf-call.conf
share/etc/oned.conf
src/authm_mad/remotes/ldap/ldap_auth.conf
src/authm_mad/remotes/server_x509/server_x509_auth.conf
src/authm_mad/remotes/x509/x509_auth.conf
src/sunstone/etc/sunstone-server.conf
src/sunstone/public/app/tabs/vms-tab/panels/conf
src/sunstone/public/app/tabs/vms-tab/form-panels/updateconf
src/onegate/etc/onegate-server.conf
src/datastore_mad/remotes/ceph/ceph.conf
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
src/tm_mad/fs_lvm/fs_lvm.conf
src/flow/etc/oneflow-server.conf"

IFS=$'\n'      
conf_files=($conf_files)

if [[ $TRAVIS_BRANCH =~ (^one-) ]]; then
    echo "Checking difference in configuration files in branch "$TRAVIS_BRANCH
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

exit 0
