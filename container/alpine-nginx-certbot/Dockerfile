ARG IMAGE=alpine:3.17

FROM $IMAGE AS builder
ENV NG_VER=1.23.2
ENV PATCH=proxy_connect_rewrite_102101.patch
RUN apk add --no-cache --update alpine-sdk pcre2-dev libzip-dev openssl-dev && \
	cd /tmp && \
	curl -LO http://nginx.org/download/nginx-$NG_VER.tar.gz && \
	tar -xf nginx-$NG_VER.tar.gz && \
	git clone https://github.com/chobits/ngx_http_proxy_connect_module.git && \
	cd nginx-$NG_VER && \
	patch -p1 < ../ngx_http_proxy_connect_module/patch/$PATCH && \
	./configure --prefix=/opt/nginx-$NG_VER --add-module=../ngx_http_proxy_connect_module --with-http_ssl_module --with-http_v2_module && \
	make && make install

FROM $IMAGE
ENV NG_VER=1.23.2
RUN apk add --no-cache --update certbot certbot-nginx sed pcre2 libzip openssl
COPY --from=builder /opt/nginx-$NG_VER /opt/nginx-$NG_VER
COPY ./files /opt/alpine_nginx_cerbot
RUN ln -s /opt/nginx-$NG_VER/sbin/nginx /usr/sbin/ && \
	chmod +x /opt/alpine_nginx_cerbot/cmd.sh 

CMD [ "/opt/alpine_nginx_cerbot/cmd.sh" ]
