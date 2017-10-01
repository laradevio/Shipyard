#!/usr/bin/with-contenv sh

#
# This script moves the services to another folder if they are
# in "false" state (in your .env file) so s6 doesn't start
# them. This runs every time the container starts.
#

if [ $STEWARD_SCHEDULER = "false" ]; then \
	mv -f /etc/services.d/scheduler /etc/services.d.inactive/ \
;else \
	mv -f /etc/services.d.inactive/scheduler /etc/services.d/ 2>/dev/null \
;fi

if [ $STEWARD_QUEUE = "false" ]; then \
	mv -f /etc/services.d/queue /etc/services.d.inactive/ \
;else \
	mv -f /etc/services.d.inactive/queue /etc/services.d/ 2>/dev/null \
;fi

if [ $STEWARD_HORIZON = "false" ]; then \
	mv -f /etc/services.d/horizon /etc/services.d.inactive/ \
;else \
	mv -f /etc/services.d.inactive/horizon /etc/services.d/ 2>/dev/null \
;fi
