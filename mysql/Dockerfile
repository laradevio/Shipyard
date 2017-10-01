#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# MySQL is not supported in Alpine it seems, as the only way to get this
# RDBMS is to download the latest image made for MySQL. There is not
# something wrong with this approach, but the image may be big.

FROM mysql:latest

#
#--------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------
#

# Let's set the locale and language to the default "en_US.utf-8", same with
# the environment variables for our PHP installation and our Timezone.

ARG APP_TZ=UTC
ENV APP_TZ ${APP_TZ}
RUN ln -snf /usr/share/zoneinfo/$APP_TZ /etc/localtime && echo $APP_TZ > /etc/timezone

CMD ["mysqld"]
