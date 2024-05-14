#!/bin/bash

if [ ! -e ./cephrc ]
then
    echo "Can't find ./cephrc"
    exit
fi
source ./cephrc

echo " ###################################"
echo " # CREATING ceph_deploy VIRTUALENV #"
echo " ###################################"

OS_RELEASE=$(lsb_release -sr)

if [ ${OS_RELEASE} = "18.04" ] || [ ${CEPH_ANSIBLE_VERSION} = "stable-5.0" ]; then
    apt install -y python git
    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py -O /opt/ceph-toolkit/get-pip.py
    python /opt/ceph-toolkit/get-pip.py
    pip install virtualenv
    virtualenv ceph_deploy
else
    apt install -y python3 python-is-python3 python3-distutils git
    wget https://bootstrap.pypa.io/get-pip.py -O /opt/ceph-toolkit/get-pip.py
    python3 /opt/ceph-toolkit/get-pip.py
    python3 -m venv ceph_deploy
fi

source ceph_deploy/bin/activate

echo " ################################################"
echo " # DOWNLOADING ANSIBLE VERSION $ANSIBLE_VERSION #"
echo " ################################################"

if [ ${OS_RELEASE} = "18.04" -o ${OS_RELEASE} = "20.04" ]; then
  pip install --upgrade 'setuptools<45.0.0'
  pip install ansible==$ANSIBLE_VERSION
elif [ ${OS_RELEASE} = "22.04" ]; then
  pip install ansible-core==$ANSIBLE_VERSION
fi

pip install notario
pip install netaddr
pip install six

if [ ${OS_RELEASE} = "20.04" -o ${OS_RELEASE} = "22.04" ]; then
    ansible-galaxy collection install ansible.posix
    ansible-galaxy collection install ansible.utils
    ansible-galaxy collection install community.general
fi

if [ ! -d ${CEPH_ANSIBLE_DIR} ]
then
    echo "########################"
    echo "# CLONING CEPH-ANSIBLE #"
    echo "########################"

    git clone https://github.com/ceph/ceph-ansible.git ${CEPH_ANSIBLE_DIR}
fi

echo "###########################################################"
echo "# CHECKING OUT CEPH-ANSIBLE VERSION $CEPH_ANSIBLE_VERSION #"
echo "###########################################################"

cd ${CEPH_ANSIBLE_DIR} && git fetch && git checkout $CEPH_ANSIBLE_VERSION
    

echo "Environment prepared for automation" 
