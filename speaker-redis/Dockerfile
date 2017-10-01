#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#


FROM redis:alpine

VOLUME /data

# Adding "appendonly" will allow Redis to save inmediately our keys to our
# volume, so it makes it almost crash-safe.
CMD ["redis-server", "--appendonly", "yes"]
