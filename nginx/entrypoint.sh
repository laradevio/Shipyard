#!/bin/bash

# Reference
# https://github.com/chadoe/docker-nginx/blob/master/start.sh
#
# NGINX isn't capable or reading environment variables and use them
# under their config files. So we need to take copy the "unparsed"
# files to our location, and replace the values at startup.

# Remove any file from the sites-available if there is any
rm -f /etc/nginx/conf.d/*
rm -f /etc/nginx/sites-available/*

# Now we force-copy our files to the NGINX configuration path
cp -afr /etc/nginx/conf.d-unparsed/. /etc/nginx/conf.d/
cp -afr /etc/nginx/sites-available-unparsed/. /etc/nginx/sites-available/

# Replace variables $ENV{"<environment varname>"}
function ReplaceEnvironmentVariable() {
    grep -rl "\$ENV{\"$1\"}" $3 | xargs -r sed -i "s|\\\$ENV{\"$1\"}|$2|g"
}

# Add a resolver for xDebug block on the NGINX file
RS=$( cat /etc/resolv.conf | grep "nameserver" | head -1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" )
export RESOLVER_SERVER=$RS

# Replace all variables on the copied files (not the originals)
for _curVar in `env | awk -F = '{print $1}'`;do
    ReplaceEnvironmentVariable ${_curVar} ${!_curVar} /etc/nginx/conf.d/*
    ReplaceEnvironmentVariable ${_curVar} ${!_curVar} /etc/nginx/sites-available/*
done

# Run nginx like always
exec /usr/sbin/nginx
