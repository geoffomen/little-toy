ARG IMAGE=alpine:3.17

FROM $IMAGE AS builder
ARG NGINX_VER
ENV NGINX_VER={NGINX_VER}
ENV PATCH=proxy_connect_rewrite_102101.patch
RUN apk add --no-cache --update alpine-sdk pcre2-dev libzip-dev openssl-dev && \
	cd /tmp && \
	curl -LO http://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
	tar -xf nginx-$NGINX_VER.tar.gz && \
	git clone https://github.com/chobits/ngx_http_proxy_connect_module.git && \
	cd nginx-$NGINX_VER && \
	patch -p1 < ../ngx_http_proxy_connect_module/patch/$PATCH && \
	./configure --prefix=/opt/nginx-$NGINX_VER --add-module=../ngx_http_proxy_connect_module --with-http_ssl_module --with-http_v2_module && \
	make && make install

FROM $IMAGE
RUN apk add --no-cache --update certbot certbot-nginx sed pcre2 libzip openssl rsync
ARG NGINX_VER
ENV NGINX_VER={NGINX_VER}
COPY --from=builder /opt/nginx-$NGINX_VER /opt/nginx-$NGINX_VER
COPY ./files /opt/alpine_nginx_cerbot
RUN ln -s /opt/nginx-$NGINX_VER/sbin/nginx /usr/sbin/ && \
	chmod +x /opt/alpine_nginx_cerbot/cmd.sh 

CMD [ "/opt/alpine_nginx_cerbot/cmd.sh" ]
