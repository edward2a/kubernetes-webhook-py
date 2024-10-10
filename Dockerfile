FROM alpine:3.15

RUN addgroup -S runtime && \
    adduser -G runtime -S -D runtime

RUN apk add --no-cache python3 py3-pip nginx

COPY requirements.txt /tmp

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

COPY --chmod=0755 source/webhook.py /usr/local/bin/webhook.py
COPY --chmod=0755 scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# default nginx config for non-root
RUN sed -i -e '/^user nginx;/d' /etc/nginx/nginx.conf &&\
    sed -i -e 's/listen 80/listen 8080/' /etc/nginx/http.d/default.conf &&\
    sed -i -e '/.*listen \[::\]:80 default_server;/d' /etc/nginx/http.d/default.conf &&\
    chown runtime /var/lib/nginx /var/lib/nginx/tmp /var/log/nginx /run/nginx

USER runtime

