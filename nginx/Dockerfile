#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#

# For NGINX we can just ask the latest image based from Alpine. From here
# the configuration should be pretty straightforward: add the file to
# setup the main NGINX configuration, the sites, and done.

FROM nginx:alpine



#
#--------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------
#
# Here we add our special `nginx.conf` for our NGINX Container, with some
# useful load-and-forget configuration. Then we add some default config
# files for our site and that's all.

# We need Bash for our ENV-Replacement script, as it won't work with the
# default `sh` shell of Alpine. We clean the cache afterwards.
RUN apk add --update bash && rm -rf /var/cache/apk/*

COPY ./static/index.html /usr/share/nginx/html

# Amek some adjustaments when the container starts.
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#
#--------------------------------------------------------------------------
# `www-data` User
#--------------------------------------------------------------------------
#
# We need to add a proper user for NGINX to run and serve files, so we use
# the default `www-data` under PID=1000. It suffices for a development
# proyect, but on production you should use something more reliable.

RUN adduser -D -H -u 1000 -s /bin/sh www-data

#
#--------------------------------------------------------------------------
# End
#--------------------------------------------------------------------------
#
# We expose the ports for our normal traffic and xDebug at our `docker-
# compose.yml` file. 

ENTRYPOINT ["/entrypoint.sh"]
