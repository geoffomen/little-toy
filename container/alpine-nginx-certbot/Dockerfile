ARG IMAGE=alpine:3.17

FROM $IMAGE AS builder
ARG NGINX_VER
ENV NGINX_VER=${NGINX_VER}
ENV PATCH=proxy_connect_rewrite_102101.patch
#ENV https_proxy=https://example.com

RUN apk add --no-cache --update alpine-sdk pcre2-dev libzip-dev openssl-dev 
WORKDIR /tmp
RUN	git clone https://github.com/chobits/ngx_http_proxy_connect_module.git
RUN	git clone https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git
RUN	curl -LO http://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
	tar -xf nginx-$NGINX_VER.tar.gz && \
	cd nginx-$NGINX_VER && \
	patch -p1 < ../ngx_http_proxy_connect_module/patch/$PATCH && \
	./configure --prefix=/opt/nginx-$NGINX_VER \
		--add-module=../ngx_http_proxy_connect_module \
		--add-module=../nginx-rtmp-module \
		--with-compat \
		--with-threads \
		--with-http_addition_module \
		--with-http_auth_request_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_mp4_module \
		--with-http_random_index_module \
		--with-http_realip_module \
		--with-http_slice_module \
		--with-http_ssl_module \
		--with-http_sub_module \
		--with-http_stub_status_module \
		--with-http_v2_module \
		--with-http_secure_link_module \
		--with-stream \
		--with-stream_realip_module \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
	&& make && make install

FROM $IMAGE
RUN apk add --no-cache --update certbot certbot-nginx sed pcre2 libzip openssl rsync
ARG NGINX_VER
ENV NGINX_VER=${NGINX_VER}
COPY --from=builder /opt/nginx-$NGINX_VER /opt/nginx-$NGINX_VER
COPY ./files /opt/alpine_nginx_cerbot
RUN ln -s /opt/nginx-$NGINX_VER/sbin/nginx /usr/sbin/ && \
	chmod +x /opt/alpine_nginx_cerbot/cmd.sh 

CMD [ "/opt/alpine_nginx_cerbot/cmd.sh" ]
