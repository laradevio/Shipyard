#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# We just need to call our PHP Container again, and add Xdebug.ini from the
# `docker-compose.yml`.

FROM shipyard_php:latest

#
# This allows to some IDEs to pickup the Dockerfile image and locate xDebug
#
COPY xdebug.ini /etc/php7/conf.d/xdebug.ini
