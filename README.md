# emailgw

## IMAP to Dovecot Migration

### Enable IMAP Master User on source server
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

### Sync from source server to new Dovecot server

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
