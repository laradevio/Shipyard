#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# We are just gonna run a default alpine with S6 Overlay and install the
# beanstalkd. Nothing more fancy

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

#
#--------------------------------------------------------------------------
# Beanstalkd Installation
#--------------------------------------------------------------------------
#
# Just pull it out from the Alpine repo.

RUN apk --update add beanstalkd && \
	rm -rf /var/cache/apk/*

#
#--------------------------------------------------------------------------
# S6 Overlay final call
#--------------------------------------------------------------------------
#
# Here we end the image telling that the container will instantiate using
# the `/custom-init` script.

VOLUME /var/lib/beanstalkd/data

COPY rootfs /

ENTRYPOINT [ "/init" ]