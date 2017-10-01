#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# We just need our latest PHP Container and add our `rootfs` folder with
# the services we want to run when the container inits. We will point
# out our `supervisord` process and "stop" php-fpm by deleting it.

FROM shipyard_php:latest

RUN rm -f -r /etc/services.d/php-fpm

#
#--------------------------------------------------------------------------
# Supervisor Install
#--------------------------------------------------------------------------
#
# We are downloading Supervisor from Alpine repositories.

# RUN apk --update add \
#	supervisor && \
#	rm -rf /var/cache/apk/*

#
#--------------------------------------------------------------------------
# S6 Final Call
#--------------------------------------------------------------------------
#
# Call S6 to call supervisord, and call our php processes. Don't know if
# calling Supervisor with S6 is redundant, S6 alone cannot daemonize a
# PHP script on its own so we are like "forced" to use this method.

COPY rootfs /