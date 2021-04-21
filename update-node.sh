#!/bin/sh
REDIS_NODES="/var/lib/redis/nodes.conf"
sed -i -e "/myself/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${MY_POD_IP}/" ${REDIS_NODES}
exec "$@"
