# Let's encrypt

## Quick-start

```
mkdir ~/letsencrypt 
cd ~/letsencrypt
sudo docker run --rm -ti -v $PWD/log/:/var/log/letsencrypt/ -v $PWD/etc/:/etc/letsencrypt/ -p 80:80 certbot/certbot certonly --standalone -d mail.server.tld
```

## Renew all:
```
cd ~/letsencrypt
sudo docker run --rm -ti -v $PWD/log/:/var/log/letsencrypt/ -v $PWD/etc/:/etc/letsencrypt/ -p 80:80 -p 443:443 certbot/certbot renew
```

TODO: test if certificates have been renewed (ex: `[[ $(( $(date +%s)-$(stat -c %Y etc/csr) )) -lt 5*60 ]]`)
```
cd ~/docker-mailserver
sudo docker-compose exec mail bash -c '[[ "$SMTP_ONLY" -ne 1 ]] && dovecot reload'
```

## Tips

Verify expiration date:
```
echo | openssl s_client -connect mail.server.tld:25 -starttls smtp 2>/dev/null | openssl x509 -noout -dates
echo | openssl s_client -connect mail.antipod.com:587 -starttls smtp 2>/dev/null | openssl x509 -noout -dates
echo | openssl s_client -connect mail.antipod.com:143 -starttls imap 2>/dev/null | openssl x509 -noout -dates
echo | openssl s_client -connect mail.antipod.com:993 2>/dev/null | openssl x509 -noout -dates
```
