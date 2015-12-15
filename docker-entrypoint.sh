#!/bin/bash
set -e

if [ -z "$CONSUL_ADDR" ]; then
    export CONSUL_ADDR="127.0.0.1:8500"
fi
if [ -z "$CONSUL_SERVICES" ]; then
    export CONSUL_SERVICES="prom-node"
fi
sed -i "s/CONSUL_ADDR/$CONSUL_ADDR/g" /etc/prometheus/prometheus.yml
export CONSUL_SERVICES_Q=$(echo -n "$CONSUL_SERVICES" | awk -v q="'" -v RS=',' -v ORS=',' '{ print q $0 q }' | rev | cut -c 2- | rev)
sed 's@CONSUL_SERVICES@'"$CONSUL_SERVICES_Q"'@' -i /etc/prometheus/prometheus.yml
exec /bin/prometheus -config.file=/etc/prometheus/prometheus.yml \
     -storage.local.path=/prometheus \
     -web.console.libraries=/etc/prometheus/console_libraries \
     -web.console.templates=/etc/prometheus/consoles "$@"
