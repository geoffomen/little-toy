#!/bin/sh


CONTAINER_UTIL=/usr/bin/docker

# build image
${CONTAINER_UTIL} build -t alpine-nginx-certbot .
