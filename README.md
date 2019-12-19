# A stateless e-mail service based on docker-mailserver

[Step-by-step guide](https://gmasse.github.io/blog/2019/11/08/Take-control-of-your-e-mail/)

### Further information

#### (Optional) Log and Metrics management
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install filebeat
sudo vi /etc/filebeat/filebeat.yml
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

#### Maintenance

##### Backup
Snapshot the volume:
```
openstack volume snapshot create --force --volume email_storage email_storage_snap01
```

#### IMAP to Dovecot Migration

##### Enable IMAP Master User on SOURCE server
Create a Master password file `passwd.masterusers`
```
echo 'master:'`doveadm pw -s sha512-crypt` > /etc/dovecot/passwd.masterusers
```


To add in `dovecot.conf` before your passdb configuration:
```
auth_master_user_separator = *
passdb {
  driver = passwd-file
  args = /etc/dovecot/passwd.masterusers
  master = yes
#  result_success = continue
}
```

Reload dovecot: `doveadm reload`.

You can now connect to any IMAP account with master user/password: `myuser@mydomain.com*master`

([Reference](https://doc.dovecot.org/configuration_manual/authentication/master_users/))

##### Sync from source server to NEW Dovecot server

Add the follwing configuration to your target Dovecot server. `local.conf` is a good choice:
```
imapc_host = imap.example.com

# Authenticate as masteruser / masteruser-secret, but use a separate login user.
# If you don't have a master user, remove the imapc_master_user setting.
imapc_user = %u
imapc_master_user = masteruser
imapc_password = masteruser-secret

imapc_features = rfc822.size
# If you have Dovecot v2.2.8+ you may get a significant performance improvement with fetch-headers:
# imapc_features = $imapc_features fetch-headers
# Read multiple mails in parallel, improves performance
mail_prefetch_count = 20

# If the old IMAP server uses INBOX. namespace prefix, set:
#imapc_list_prefix = INBOX

# for SSL:
imapc_port = 993
imapc_ssl = imaps
```

doveadm -o mail_fsync=never sync -1 -R -u user@domain imapc:


https://wiki2.dovecot.org/Migration/Dsync

#### Tips

Retreiving and spam testing of an e-mail:
```
doveadm fetch -u user@domain.com text HEADER Message-Id '1234@abcd' MAILBOX Inbox | su --login amavis -c 'spamassassin -d -t'
```
