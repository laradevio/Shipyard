#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# Instead of building PHP from the source, we are gonna use the same latest
# Alpine image we have been using in Warehouse, and download PHP from
# the official repository of Alpine, so all share the same version.

FROM alpine:latest

#
#--------------------------------------------------------------------------
# S6 Overlay
#--------------------------------------------------------------------------
#
# And add S6-overlay to take care of our processes and supervision instead
# of the old `supervisord` wich doesn't play too nice with Docker based
# containers. 

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.20.0.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# Let's set the locale and language to the default "en_US.utf-8", same with
# the environment variables for our PHP installation and our Timezone.

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8

ARG APP_TZ=UTC
ENV APP_TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$APP_TZ /etc/localtime && echo $APP_TZ > /etc/timezone

	

#
#--------------------------------------------------------------------------
# Repositories fix
#--------------------------------------------------------------------------
#
# Some of the packages we need have their latest version in the Community
# EDGE repository so we change this in APK Configuration. 

RUN printf '@edge_community http://dl-cdn.alpinelinux.org/alpine/edge/community\n' >> /etc/apk/repositories && \ 
    printf '@edge_main http://dl-cdn.alpinelinux.org/alpine/edge/main\n' >> /etc/apk/repositories && \ 
	apk update

#
#--------------------------------------------------------------------------
# PHP Installation
#--------------------------------------------------------------------------
#
# We use the latest stable version of PHP 7.1 from Alpine repositories.
# You can play with the latest PHP 7.1 by adding `@edge-community`
# on every of these package and some of the Base Tools before.

RUN apk add \
	php7 \
    	php7-fpm \
	php7-amqp \
	php7-bcmath \
	php7-bz2 \
	php7-curl \
	php7-ctype \
	php7-dom \
	php7-gd \
	php7-imagick \
	php7-gettext \
	php7-intl \
	php7-iconv \
	php7-json \
	php7-mailparse \
	php7-mbstring \
	php7-mcrypt \
	php7-openssl \
	php7-pcntl \
	php7-phar \
	php7-pdo \
	php7-pdo_mysql \
	php7-pdo_sqlite \
	php7-pdo_pgsql \
	php7-posix \
	php7-session \
	php7-tokenizer \
	php7-xml \
	php7-xmlwriter \
	php7-xmlreader \
	php7-zip \
	php7-zlib \
	php7-xdebug
	
# Once PHP 7.1.9 lands on Alpine stable , we will be able to install
# these new packages which includes better support for crpyot,
# uuid and images. Meanwhile, will leave it here.
# 
#	php7-gmagick
#	php7-libsodium
#	php7-uuid

#
#--------------------------------------------------------------------------
# PHP Optional Extensions
#--------------------------------------------------------------------------
#
# This part is focused on the PHP Extensions install. You are free to
# to add more, but remember also to update PHP and xDebug containers
# `Dockerfile` and rebuild as these values are shared with them.

# PHP_XDEBUG variable is not declared so it's not installed in this
# Container. You shouldn't use xDebug here for anything because
# Composer restarts PHP without xDebug enabled, and we have
# Warehouse for these tasks where you need CLI access.

ARG PHP_XDEBUG=false
ARG PHP_SOAP=false
ARG PHP_REDIS=false
ARG PHP_OPCACHE=false

RUN if [ ${PHP_XDEBUG} = true ]; then \
		apk add php7-xdebug \
	;fi && \
	if [ ${PHP_SOAP} = true ]; then \
		apk add php7-soap \
	;fi && \
	if [ ${PHP_REDIS} = true ]; then \
		apk add php7-redis \
	;fi  && \
	if [ ${PHP_OPCACHE} = true ]; then \
		apk add php7-opcache \
	;fi
	
#
#--------------------------------------------------------------------------
# Cleaning
#--------------------------------------------------------------------------
#
# We make some final adjustments to our image build, like cleaning the APK
# packages cache, exposing ports and leave S6 Overlay files ready to be
# read by `/init` when container starts.
 
RUN rm -rf /var/cache/apk/*

RUN addgroup -g 1000 www-data && \
    adduser -u 1000 -G www-data -s /bin/sh -g "" -D www-data && \
	echo "www-data:" | chpasswd

COPY rootfs /

EXPOSE 9000



#
#--------------------------------------------------------------------------
# Custom Start and S6 Overlay final call
#--------------------------------------------------------------------------
#
# Here we end the image telling that the container will instantiate using
# the `/custom-init` script and the subsequent commands will run under the
# `/var/www` path using our normal user `shipyard`.

ENTRYPOINT [ "/init" ]

WORKDIR /var/www
