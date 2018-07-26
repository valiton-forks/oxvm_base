#!/usr/bin/env bash

# THEDIR=$(dirname "$0")
# pushd "$THEDIR"

if [ -e /vagrant/base_vm/ansible/provision_pre.sh ]; then
  if [ -z "$2" ]; then
    /vagrant/base_vm/ansible/provision_pre.sh "$1"
  else
    /vagrant/base_vm/ansible/provision_pre.sh "$1" "$2"
  fi
fi

if [ -e /vagrant/base_vm/ansible/oxvm_provision.sh ] && [ "$2" != "bds_provision_pre" ]; then
  if [ -z "$2" ]; then
    /vagrant/base_vm/ansible/oxvm_provision.sh "$1"
  else
    /vagrant/base_vm/ansible/oxvm_provision.sh "$1" "$2"
  fi
fi

if [ -e /vagrant/base_vm/ansible/provision_post.sh ] && [ "$2" != "bds_provision_pre" ]; then
  if [ -z "$2" ]; then
    /vagrant/base_vm/ansible/provision_post.sh "$1"
  else
    /vagrant/base_vm/ansible/provision_post.sh "$1" "$2"
  fi
fi

# popd
