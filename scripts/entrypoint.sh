#! /bin/sh

/usr/sbin/nginx && \
exec /usr/local/bin/webhook.py

