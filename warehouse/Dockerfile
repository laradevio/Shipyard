#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#

# We start this Warehouse image with the Latest and stable Alpine as base
# image, and adding manually the tools and software packages from the
# STABLE and EDGE repositories.

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
# Base Tools and Software Installation
#--------------------------------------------------------------------------
#
# We install some basic software for our Warehouse, like bash and and GCC.
# Before that, we add the "Edge" repositories to install the latest NPM
# after we are done with this. You are free to install more software.

RUN apk update && \
	apk upgrade && \
	apk add \ 
	libjpeg \
	libjpeg-turbo \
	libpq \
	libzip \
	libpng-dev \
	libcurl \
	libedit \
	libxml2 \
	libressl2.5-libssl \
	libsodium \
	libuuid \
	libtool \
	icu-libs \
	automake \
	autoconf \
	build-base \ 
	nasm \
	gcc \ 
	musl \
	musl-dev \
	rsync \
	sqlite \
	sqlite-libs \
	git \
	curl \
	grep \
	postgresql-libs \
	postgresql-client \
	mysql-client \
	bash \
	execline \
	openssh-server \
	openssh \
	openssh-sftp-server \
	openssl \
	zlib \
	xz \
	sed \
	xz-libs \
	ghostscript \
	ghostscript-fonts \
	gifsicle \
	optipng \
	tar 

		
	
#
#--------------------------------------------------------------------------
# Shipyard User
#--------------------------------------------------------------------------
#
# We create our "Shipyard" user that will handle files present on the Host
# but without `root` permission. While this runs using Busibox's `sh`,
# we assign him `bash` as shell for convenience at login.

ARG SHIPYARD_PASSWORD=secret

RUN addgroup -g 1000 shipyard && \
    adduser -u 1000 -G shipyard -s /bin/bash -g "" -D shipyard && \
	echo "shipyard:${SHIPYARD_USER_PASSWORD}" | chpasswd
	
#
#--------------------------------------------------------------------------
# `root` SSH
#--------------------------------------------------------------------------
#
# SSH needs keys to connect, so make these at build. We make a directory to
# share them with the Host and use them to connect SSH to the container.
# The rest is some useful commands for simple configuration of SSH.

ARG WAREHOUSE_ROOT_PASSWORD=secret

RUN echo "root:${WAREHOUSE_ROOT_PASSWORD}" | chpasswd && \
	printf "\\nClientAliveInterval 15\\nClientAliveCountMax 8" >> /etc/ssh/sshd_config && \
	sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config && \
	sed -i s/#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication\ no/ /etc/ssh/sshd_config && \
	sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config && \
	sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config && \
	sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config && \
	sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config && \
	sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config && \
	sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config && \
	ssh-keygen -A && \
	mkdir -p ~/.ssh/authorized_keys && \
	ssh-keygen -t rsa -C "root@warehouse" -b 4096 -P '' -f ~/.ssh/authorized_keys/id_rsa && \
	chown root:root /etc/ssh && \
	chmod 700 /etc/ssh/ && \
	mkdir -p ~/.ssh && \
	chmod 700 ~/.ssh/ 

VOLUME /secrets

#
#--------------------------------------------------------------------------
# Node.js & Packages Installation
#--------------------------------------------------------------------------
#
# Here we can force APK to install the latest Node.js and Yarn packages by
# using the `@edge` at the end of the package name. This should'n have
# problems with Alpine's stable libs, but if they have, remove them.


RUN apk add \
	nodejs-current \
	nodejs-current-npm \
	yarn && \
	echo '' && \
	echo '    ################ DONT PANIC! ################' && \
	echo '    # We are gonna install Vue-cli and Express  #' && \
	echo '    #    These may take a while to complete.    #' && \
	echo '    #                Just wait ;)               #' && \
	echo '    #############################################' && \
	echo '' && \
	npm install vue-cli express npm@latest -g && \
	cp -rf -a -p ~/.config /home/shipyard/.config 2>/dev/null || : && \
	chown -R shipyard:shipyard /home/shipyard/.config || : 

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
	php7-amqp \
	php7-bz2 \
	php7-bcmath \
	php7-curl \
	php7-ctype \
	php7-dom \
	php7-fileinfo \
	php7-gd \
	php7-gettext \
	php7-iconv \
	php7-imagick \
	php7-intl \
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
	php7-zlib
	
# Once PHP 7.1.9 lands on Alpine Stable, we will be able to install
# these new packages which includes better support for crypto,
# uuid and images. Meanwhile, we will leave them commented.
# 
#	php7-gmagick
#	php7-libsodium
#	php7-uuid


#
#--------------------------------------------------------------------------
# Composer Installation
#--------------------------------------------------------------------------
#
# We are gonna install the Composer globally inside Warehouse container for
# convenience. Additionally, we install Laravel Installer and Envoy for
# without the need to do it inside your appplication volume.

# Add an empty `composer.json` so Composer can initialize.

COPY ./composer.json /root/.composer/composer.json
RUN chown -R root:root ~/.composer

# Download composer, install and add packages, and add the resulting
# `composer.json` to our `shipyard` user.

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
	composer global install && \
	mkdir /home/shipyard/.composer && \
	cp ~/.composer/composer.json /home/shipyard/.composer/composer.json && \
	chown -R shipyard:shipyard /home/shipyard/.composer

# Install Laravel Envoy to our `shipyard` user.

USER shipyard
RUN composer global require laravel/envoy laravel/installer

# Install Spark Installer and initialize it

USER shipyard
RUN git clone https://github.com/laravel/spark-installer.git ~/spark-installer && \
	PATH=$PATH:~/spark-installer && \
	composer install --working-dir=/root/spark-installer

# Add composer binaries to PATH so we can execute them from everywhere
# using the `shipyard` user, or the `root` user.

USER root
ENV PATH="/home/shipyard/.composer/vendor/bin:${PATH}"

#
#--------------------------------------------------------------------------
# PHP Optional Extensions
#--------------------------------------------------------------------------
#
# This part is focused on the PHP Extensions install. You are free to
# to add more, but remember also to update PHP and xDebug containers
# `Dockerfile` and rebuild as these values are shared with them.

# PHP_XDEBUG variable is not declared so it's not installed in this
# Container. You shouldn't use xDebug here for anything even if
# Composer restarts PHP without xDebug enabled when used.

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


#
#--------------------------------------------------------------------------
# Custom Start and S6 Overlay final call
#--------------------------------------------------------------------------
#
# Here we end the image telling that the container will instantiate using
# the `/custom-init` script and the subsequent commands will run under the
# `/var/www` path using our normal user `shipyard`.

COPY rootfs /

ENTRYPOINT [ "/init" ]

WORKDIR /var/www


