#!/bin/sh
echo "Setting up and starting varnish"

set -x

pid=0
pid2=0

# SIGUSR1-handler
my_handler() {
  echo "my_handler"
}

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi

  if [ $pid2 -ne 0 ]; then
    kill -SIGTERM "$pid2"
    wait "$pid2"
  fi

  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

# Convert environment variables in the conf to fixed entries
# http://stackoverflow.com/questions/21056450/how-to-inject-environment-variables-in-varnish-configuration
for name in VARNISH_BACKEND_PORT VARNISH_BACKEND_IP
do
    eval value=\$$name
    sed -i "s|\${${name}}|${value}|g" /etc/varnish/default.vcl
done

# echo "varnishd -a 0.0.0.0:${VARNISH_PORT} -b ${VARNISH_BACKEND_IP}:${VARNISH_BACKEND_PORT}"
# varnishd -a 0.0.0.0:${VARNISH_PORT} -b ${VARNISH_BACKEND_IP}:${VARNISH_BACKEND_PORT}
sleep ${VARNISH_D_DELAY:=10}
echo "starting varnishd"
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:${VARNISH_PORT} &
pid="$!"

if [ ${VARNISH_LOG:=0} -eq 1 ]; then
  echo "Starting log to console"
  varnishlog &
  pid2="$!"
fi

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done
