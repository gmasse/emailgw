# emailgw

## Creating the VM

```
(optional) openstack keypair create --public-key ~/.ssh/id_rsa.pub Macbook
nova boot --flavor s1-4 --image "Ubuntu 18.04" --key-name "Macbook" --user-data cloudinit email
SRV_ID=4e960a2d-b354-45cc-9c58-e0fb84ef2dbc

cinder type-list
cinder create --volume-type classic 10
VOL_ID=0e3a4591-a69b-41aa-b0c6-184d86f89ab4
nova volume-attach $SRV_ID $VOL_ID /dev/sdb
```

## Configuring the VM

```
echo "server:
    interface: 127.0.0.1
    interface: ::1
    interface: 172.17.0.1
    access-control: 172.16.0.0/12 allow
    outgoing-interface: 87.98.134.28" | sudo tee /etc/unbound/unbound.conf.d/docker.conf
```
```
echo "{
    'dns': [ '172.17.0.1' ]
}" | sudo tee /etc/docker/daemon.json
```

## (Optional) Log and Metrics management
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install filebeat
sudo vi /etc/filebeat/filebeat.yml
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

## IMAP to Dovecot Migration

### Enable IMAP Master User on SOURCE server
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

### Sync from source server to NEW Dovecot server

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
