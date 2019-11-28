#!/bin/sh

if [ $(id -u) -ne 0 ]
  then echo "Please run as root"
  exit
fi

set -x
set -e

DEFAULT_USER=ubuntu

USER_DIR=$(runuser -l ubuntu -c "sh -c 'echo \$HOME'")
SRC_DIR=${USER_DIR}/emailgw/elk
ELK_DIR=${USER_DIR}/docker-elk


### Global configuration

cp -f ${SRC_DIR}/etc/iptables/* /etc/iptables/
# TODO: update rules.v4 to match your needs


### ELK installation

runuser -l ${DEFAULT_USER} -c "sh -c 'git clone \"https://github.com/deviantony/docker-elk.git\" ${ELK_DIR}'"


### Logstash configuration

runuser -l ${DEFAULT_USER} -c "sh -c 'mkdir -p ${ELK_DIR}/logstash/config'"
runuser -l ${DEFAULT_USER} -c "sh -c 'mkdir -p ${ELK_DIR}/logstash/pipeline/beats'"
runuser -l ${DEFAULT_USER} -c "sh -c 'cp -Rf ${SRC_DIR}/logstash ${ELK_DIR}/logstash'"

runuser -l ${DEFAULT_USER} -c "sh -c 'cp -f ${SRC_DIR}/docker-compose.yml ${ELK_DIR}/'"
