#!/bin/sh

/usr/bin/certbot renew --nginx --force-renewal
/usr/sbin/nginx -s reload -c /etc/nginx/nginx.conf
