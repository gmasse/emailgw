# ELK-docker, parsing filebeats docker-mailserver logs

## Deploying ELK stack

https://github.com/deviantony/docker-elk


## WORK IN PROGRESS Configuring Logstash
```
wget https://raw.githubusercontent.com/whyscream/postfix-grok-patterns/master/postfix.grok -O patterns/postfix.grok
wget https://raw.githubusercontent.com/tomav/docker-mailserver/master/elk/amavis.grok -O patterns/amavis.grok
wget https://raw.githubusercontent.com/ninech/logstash-patterns/master/patterns.d/dovecot.grok -O patterns/dovecot.grok
wget https://raw.githubusercontent.com/whyscream/postfix-grok-patterns/master/50-filter-postfix.conf -O 50-filter-postfix.conf
wget https://raw.githubusercontent.com/tomav/docker-mailserver/master/elk/16-amavis.conf -O 51-filter-amavis.conf
wget https://raw.githubusercontent.com/ninech/logstash-patterns/master/exmples/50-filter-dovecot.conf -O 52-filter-dovecot.conf

sed -i 's|/etc/logstash/patterns.d|/usr/share/logstash/pipeline/beats/patterns|' *.conf
```
TODO: Logstash GeoIP plugin
