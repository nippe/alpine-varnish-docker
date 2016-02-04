FROM ctjinx/alpine-varnish

RUN apk update
RUN apk add gcc
RUN apk add libc-dev
RUN apk curl

# Make our custom VCLs available on the container
ADD default.vcl /etc/varnish/default.vcl
ADD default.vcl /default.vcl

# ENV VARNISH_BACKEND_PORT 3000
# ENV VARNISH_BACKEND_IP 192.168.99.100
# ENV VARNISH_PORT 80

# Expose port 80
# EXPOSE 80

# Expose volumes to be able to use data containers
VOLUME ["/var/lib/varnish", "/etc/varnish"]

ADD start.sh /start.sh
CMD ["/start.sh"]
