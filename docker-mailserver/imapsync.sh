#! /bin/sh

EMAIL_ACCOUNT_LIST=$@

if [ -z "$EMAIL_ACCOUNT_LIST" ]; then
    echo "ERROR/ Missing argument"
    echo "usage: $0 myemail@mydomain.com ..."
    exit 1
fi

if [ -z "$IMAGE_NAME" ]; then
    IMAGE_NAME=germainmasse/docker-mailserver:dev
fi


echo "INFO/ Checking if another container is running"
if [ `docker ps --filter "ancestor=$IMAGE_NAME" --format "{{.ID}}\t{{.Status}}" | grep -vi "paused" | wc -l` -ne '0' ]; then
    echo "Container is already running. You must stop or pause it before executing this script."
    exit 1
fi

echo "INFO/ Checking if local 'unsecure' DH parameters file exists"
if [ -f `pwd`/config.imapsync/dhparams.pem ]; then
    echo "INFO/ Re-using existing DH params file"
else
    echo "INFO/ Generating DH params file"
    openssl dhparam -out `pwd`/config.imapsync/dhparams.pem 2048
fi

echo "INFO/ Starting container"
docker run -d --rm --name mail.imapsync \
    -v "`pwd`/config":/tmp/docker-mailserver \
    -v "`pwd`/config.imapsync/dovecot.cf":/etc/dovecot/local.conf:ro \
    -v "`pwd`/config.imapsync/dhparams.pem":/etc/postfix/dhparams.pem:ro \
    -v /mnt/mail/maildata:/var/mail \
    --cap-add=SYS_PTRACE \
    -e DOVECOT_MAILBOX_FORMAT=mdbox \
    -e PERMIT_DOCKER=host \
    -e DMS_DEBUG=0 \
    -h mail.my-domain.com \
    -t $IMAGE_NAME

echo "INFO/ Waiting for container launch"
#TODO: waitfor unix socket /var/run/dovecot/auth-userdb
sleep 10

for email in "$@"; do
    echo "INFO/ Testing if local mailbox exists for $email"
    docker exec -ti mail.imapsync doveadm user $email | grep '^uid'
    if [ $? -eq 0 ]; then
        echo "INFO/ Migrating emails"
        docker exec -ti mail.imapsync doveadm -D -o mail_fsync=never sync -1 -R -u $email imapc:
    else
        echo "WARN/ Mailbox not found"

    fi
done


echo "INFO/ Deleting container"
docker rm -f mail.imapsync
