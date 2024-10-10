SHELL = /bin/bash

help:
	@echo Nope!

clean:
	rm -rf ./temp

build:
	docker build -t edward2a/k8s-webhook-py .

push:
	docker push edward2a/k8s-webhook-py

certs:
	./scripts/create_certificates.sh

deploy: certs
	cp deploy/helm-chart/values.yaml temp/values.yaml
	grep -q '^caCertBundleB64:' temp/values.yaml || \
	  echo -e "caCertBundleB64: $$(base64 -w 0 temp/ca_cert.pem)" >> temp/values.yaml
	grep -q '^tlsServerCertB64:' temp/values.yaml || \
	  echo -e "tlsServerCertB64: $$(base64 -w 0 temp/server_cert.pem)" >> temp/values.yaml
	grep -q '^tlsServerKeyB64:' temp/values.yaml || \
	  echo -e "tlsServerKeyB64: $$(base64 -w 0 temp/server_key.pem)" >> temp/values.yaml
	helm install k8s-webhook-py -f temp/values.yaml deploy/helm-chart
