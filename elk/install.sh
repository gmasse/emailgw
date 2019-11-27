#!/bin/sh

ELK_DIR=~/docker-elk

git clone "https://github.com/deviantony/docker-elk.git" ${ELK_DIR}


### Logstash configuration

CONFIG_DIR=${ELK_DIR}/logstash/config
BEATS_PIPELINE_DIR=${ELK_DIR}/logstash/pipeline/beats

mkdir -p ${BEATS_PIPELINE_DIR}
mkdir -p ${BEATS_PIPELINE_DIR}/patterns




wget https://raw.githubusercontent.com/whyscream/postfix-grok-patterns/master/postfix.grok -O patterns/postfix.grok
wget https://raw.githubusercontent.com/tomav/docker-mailserver/master/elk/amavis.grok -O patterns/amavis.grok
wget https://raw.githubusercontent.com/ninech/logstash-patterns/master/patterns.d/dovecot.grok -O patterns/dovecot.grok
wget https://raw.githubusercontent.com/whyscream/postfix-grok-patterns/master/50-filter-postfix.conf -O 50-filter-postfix.conf
wget https://raw.githubusercontent.com/tomav/docker-mailserver/master/elk/16-amavis.conf -O 51-filter-amavis.conf
wget https://raw.githubusercontent.com/ninech/logstash-patterns/master/exmples/50-filter-dovecot.conf -O 52-filter-dovecot.conf

sed -i 's|/etc/logstash/patterns.d|/usr/share/logstash/pipeline/beats/patterns|' *.conf

