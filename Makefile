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
	helm install k8s-webhook-py deploy/helm-chart
