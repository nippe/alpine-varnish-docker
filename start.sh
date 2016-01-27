#!/bin/sh
echo "Setting up and starting varnish"
# Convert environment variables in the conf to fixed entries
# http://stackoverflow.com/questions/21056450/how-to-inject-environment-variables-in-varnish-configuration
for name in VARNISH_BACKEND_PORT VARNISH_BACKEND_IP
do
    eval value=\$$name
    sed -i "s|\${${name}}|${value}|g" /etc/varnish/default.vcl
done

# echo "varnishd -a 0.0.0.0:${VARNISH_PORT} -b ${VARNISH_BACKEND_IP}:${VARNISH_BACKEND_PORT}"
# varnishd -a 0.0.0.0:${VARNISH_PORT} -b ${VARNISH_BACKEND_IP}:${VARNISH_BACKEND_PORT}
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:${VARNISH_PORT}
echo "Napping..."
sleep 10
echo "Starting log to console"
varnishlog
