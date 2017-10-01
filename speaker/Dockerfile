#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# For Speaker to work with Redis we only need to replicate this Image with
# the one we already made for Redis in Shipyard.


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

ENV LANGUAGE=en_US.UTF-8 \
	LC_ALL=en_US.UTF-8 \ 
	LC_CTYPE=en_US.UTF-8 \
	LANG=en_US.UTF-8

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
	apk update && \
	apk upgrade

#--------------------------------------------------------------------------
# Node.js & Packages Installation
#--------------------------------------------------------------------------
#
# We will have to install Node.js.
#

RUN apk add \
	nodejs-current \
	nodejs-current-npm \
	yarn && \
	echo '' && \
	echo '########### DONT PANIC! ##########' && \
	echo '# We are gonna install Socket.io #' && \
	echo '#    and this takes a while to   #' && \
	echo '#      complete. Just wait ;)    #' && \
	echo '##################################' && \
	echo '' && \
	npm install -g socket.io express npm@latest

ENV NODE_PATH ".:/var/www/node_modules:/usr/lib/node_modules"

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

WORKDIR /var/www

ENTRYPOINT [ "/init" ]