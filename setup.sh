#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $RALPM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $RALPM_TMP_DIR/cpython-3.9.13.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/cpython-3.9.13.tar.gz

  wget https://github.com/CANToolz/CANToolz/archive/82d330b835b90598f7289cdfe083f7f66309f915.tar.gz -O $RALPM_TMP_DIR/CANToolz.tar.gz
  tar xf $RALPM_TMP_DIR/CANToolz.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/CANToolz.tar.gz
  mv $RALPM_PKG_INSTALL_DIR/CANToolz-82d330b835b90598f7289cdfe083f7f66309f915 $RALPM_PKG_INSTALL_DIR/CANToolz

  $RALPM_PKG_INSTALL_DIR/python/bin/pip3.9 install flask pyserial mido numpy bitstring
  (cd $RALPM_PKG_INSTALL_DIR/CANToolz && $RALPM_PKG_INSTALL_DIR/python/bin/python3.9 setup.py install)

  ln -s $RALPM_PKG_INSTALL_DIR/python/bin/cantoolz $RALPM_PKG_BIN_DIR/
  echo "This package adds the command cantoolz"
}

uninstall() {
  rm -rf $RALPM_PKG_BIN_DIR/python
  rm -rf $RALPM_PKG_BIN_DIR/CANToolz
  rm $RALPM_PKG_BIN_DIR/cantoolz
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1