#!/bin/sh

set -e

SED=`which sed`
CERT_DIR=/etc/letsencrypt


has_err=0
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
if [ ! "$(ls -A /etc/nginx | grep -v nginx.conf | grep -v conf.d)" ]; then
        rsync -av --exclude=nginx.conf --exclude=conf.d /opt/nginx-${NGINX_VER}/conf/* /etc/nginx/
        # below via mount
        #cp -rv /opt/nginx_cerbot_conf/nginx/nginx.conf /etc/nginx/nginx.conf
        #cp -rv /opt/nginx_cerbot_conf/nginx/conf.d /etc/nginx/

fi

if [ ! -d /usr/share/nginx/html/ ]; then
        mkdir -p /usr/share/nginx/html/
fi
if [ ! "$(ls -A /usr/share/nginx/html)" ]; then
        cp -rv /opt/alpine_nginx_cerbot/nginx/html/* /usr/share/nginx/html/
fi
if [ ! -d /var/log/nginx ]; then
        mkdir -p /var/log/nginx
fi

if [ ! -f /etc/periodic/daily/cerbot_renew.sh ]; then
	cp -v /opt/alpine_nginx_cerbot/certbot/cerbot_renew.sh /etc/periodic/weekly/
        chmod +x /etc/periodic/weekly/cerbot_renew.sh
fi
for cf in $(cd /etc/nginx/conf.d/ && ls *.conf | grep -v default.conf); do
	d=$(echo ${cf} |sed -e 's/.conf$//'); 
	if [ ! -d ${CERT_DIR}/live/${d} ]; then
		/usr/bin/certbot certonly --standalone --preferred-challenges http \
			-n -d ${d} --email ${EMAIL} --agree-tos --expand
	fi
done


# Kick off cron
/usr/sbin/crond -b -d 8 

# Start nginx
/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"

