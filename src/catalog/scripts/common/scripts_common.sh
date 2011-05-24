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

function detect_and_init_distro
{
  if [ -z "$DISTRO" -o -z "$DISTRO_VERSION" ]; then
    if [ -f $DEST_DIR/etc/redhat-release ]; then
      DISTRO=rhel
      DISTRO_VERSION=`awk '{print $3}' $DEST_DIR/etc/redhat-release`
      DISTRO_PATH=$(dirname $0)/centos
    elif [ -f $DEST_DIR/etc/debian_version ]; then
      DISTRO=debian
      DISTRO_VERSION=`cat $DEST_DIR/etc/debian_version`
      DISTRO_PATH=$(dirname $0)/debian
    fi
  fi
  
  source $DISTRO_PATH/init
  init_distro
}

function to_disk
{
  IMAGE=$1
  IMAGE_SIZE=$(stat -c%s "$IMAGE")

  parted_cmd=`which parted`
  if [ $? != 0 ] ; then
    exit $?
  fi

  dd_cmd=`which dd`
  if [ $? != 0 ] ; then
    exit $?
  fi

  file_cmd=`which file`
  if [ $? != 0 ] ; then
    exit $?
  fi

  if file $IMAGE | grep -Eq '(Qcow|partition [0-9])'; then
    echo ${IMAGE}
    exit 0
  fi

  IMAGE_SIZE_MB=$(($IMAGE_SIZE/(1024*1000)))
  IMAGE_SIZE_SECTORS=$(($IMAGE_SIZE/512))
  FIRST_SECTOR=63
  LAST_SECTOR=$(($FIRST_SECTOR+$IMAGE_SIZE_SECTORS))

  $dd_cmd if=/dev/zero of=${IMAGE}.disk bs=1M seek=$IMAGE_SIZE_MB count=1 1>&2
  $parted_cmd --script ${IMAGE}.disk mklabel msdos 1>&2
  $parted_cmd --script ${IMAGE}.disk mkpart primary ext2 ${FIRST_SECTOR}s \
          ${LAST_SECTOR}s 1>&2
  $dd_cmd if=$IMAGE of=${IMAGE}.disk bs=512 seek=${FIRST_SECTOR} \
          conv=notrunc,fsync 1>&2
  
  echo ${IMAGE}.disk
}