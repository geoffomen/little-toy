#!/bin/sh

set -e

SED=`which sed`
CERT_DIR=/etc/letsencrypt


has_err=0
if [ -z "${DOMAIN}" ]; then
        echo "DOMAIN environment var is undefined"
        has_err=1
fi
if [ -z "${EMAIL}" ]; then
        echo "EMAIL environment var is undefined"
        has_err=1
fi
if [ ${has_err} -ne 0 ]; then
        exit 1;
fi


if [ ! -d /etc/nginx ]; then
        mkdir -p /etc/nginx
fi
if [ ! "$(ls -A /etc/nginx)" ]; then
        cp -rv /opt/nginx-1.23.2/conf/* /etc/nginx/
        cp -v /opt/alpine_nginx_cerbot/nginx/nginx.conf /etc/nginx/nginx.conf
        cp -rv /opt/alpine_nginx_cerbot/nginx/conf.d /etc/nginx/
	if [ ! -f /etc/nginx/conf.d/${DOMAIN}.conf ]; then 
		/bin/cp -v /etc/nginx/conf.d/example.conf.template /etc/nginx/conf.d/${DOMAIN}.conf
		${SED} -i "s/{{DOMAIN}}/${DOMAIN}/g" /etc/nginx/conf.d/${DOMAIN}.conf
	fi
fi
if [ ! -d /usr/share/nginx/html/ ]; then
        mkdir -p /usr/share/nginx/html/
fi
if [ ! "$(ls -A /usr/share/nginx/html)" ]; then
        cp -rv /opt/alpine_nginx_cerbot/nginx/html/* /usr/share/nginx/html/
fi
mkdir -p /var/log/nginx

if [ ! -f /etc/periodic/daily/cerbot_renew.bin ]; then
	cp -v /opt/alpine_nginx_cerbot/certbot/cerbot_renew.bin /etc/periodic/daily/
fi
for cf in $(cd /etc/nginx/conf.d/ && ls *.conf | grep -v default.conf); do
	d=$(echo ${cf} |sed -e 's/.conf$//'); 
	if [ ! -d ${CERT_DIR}/live/${d} ]; then
		/usr/bin/certbot certonly --standalone --preferred-challenges http \
			-n -d ${d} --email ${EMAIL} --agree-tos --expand
	fi
done


# Kick off cron
/usr/sbin/crond -f -d 8 &

# Start nginx
/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"

