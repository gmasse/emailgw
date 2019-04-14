# emailgw

/usr/sbin/clamd -c /etc/clamav/clamd.conf --pid=/run/clamav/clamd.pid
/usr/sbin/opendkim -x /etc/opendkim.conf -u opendkim -P /var/run/opendkim/opendkim.pid -p inet:10026@l
/usr/bin/freshclam -d --quiet --config-file=/etc/clamav/freshclam.conf --pid=/run/clamav/freshclam.pid
/usr/bin/python /usr/bin/fail2ban-server -b -s /var/run/fail2ban/fail2ban.sock
/usr/sbin/dovecot -c /etc/dovecot/dovecot.conf
/usr/lib/postfix/master
/usr/sbin/spamd --create-prefs --max-children 5 --helper-home-dir -d --pidfile=/var/run/spamd.pid
/usr/sbin/amavisd-new (master)
