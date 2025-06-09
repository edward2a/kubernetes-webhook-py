FROM alpine:3.15

RUN addgroup -S runtime && \
    adduser -G runtime -S -D runtime

RUN apk add --no-cache python3 py3-pip

COPY requirements.txt /tmp

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

COPY --chmod=0755 source/webhook.py /usr/local/bin/webhook.py

ENTRYPOINT ["/usr/local/bin/webhook.py"]

USER runtime

