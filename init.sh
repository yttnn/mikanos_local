#!/bin/bash

DEVENV_DIR=${HOME}/osbook/devenv
EDK2_DIR=${HOME}/edk2
WORK_DIR=${HOME}/workspace/osbook/mikanos_local

cd ${EDK2_DIR}
source edksetup.sh
cd ${WORK_DIR}

source ${DEVENV_DIR}/buildenv.sh
