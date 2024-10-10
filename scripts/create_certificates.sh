#! /usr/bin/env bash

BASE_DIR="$(dirname $(readlink -f $0))"
OUTPUT_DIR=${OUTPUT_DIR:-${BASE_DIR}/../temp}
[ -d "${OUTPUT_DIR}" ] || mkdir "${OUTPUT_DIR}"
WEBHOOK_URL="${WEBHOOK_URL:-k8s-webhook-py.k8s-webhook-py.svc}"

# CA
openssl genrsa -out "${OUTPUT_DIR}/ca_key.pem" 2048
openssl req -x509 -new -nodes -key "${OUTPUT_DIR}/ca_key.pem" -days 36500 -out "${OUTPUT_DIR}/ca_cert.pem" -subj '/CN=webhook-ca'

# OpenSSL conf
cat > "${OUTPUT_DIR}/openssl_server.cnf" <<EOF
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${WEBHOOK_URL}
EOF

cat > "${OUTPUT_DIR}/openssl_client.cnf" <<EOF
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF

# Server certs
openssl genrsa -out "${OUTPUT_DIR}/server_key.pem" 2048
openssl req -new -key "${OUTPUT_DIR}/server_key.pem" -out "${OUTPUT_DIR}/server_csr.pem" -subj "/CN=${WEBHOOK_URL}" -config "${OUTPUT_DIR}/openssl_server.cnf"
openssl x509 -req -in "${OUTPUT_DIR}/server_csr.pem" -CA "${OUTPUT_DIR}/ca_cert.pem" -CAkey "${OUTPUT_DIR}/ca_key.pem" -CAcreateserial -out "${OUTPUT_DIR}/server_cert.pem" -days 3650 -extensions v3_req -extfile "${OUTPUT_DIR}/openssl_server.cnf"

# Client certs
openssl genrsa -out "${OUTPUT_DIR}/client_key.pem" 2048
openssl req -new -key "${OUTPUT_DIR}/client_key.pem" -out "${OUTPUT_DIR}/client_csr.pem" -subj "/CN=kubernetes" -config "${OUTPUT_DIR}/openssl_client.cnf"
openssl x509 -req -in "${OUTPUT_DIR}/client_csr.pem" -CA "${OUTPUT_DIR}/ca_cert.pem" -CAkey "${OUTPUT_DIR}/ca_key.pem" -CAcreateserial -out "${OUTPUT_DIR}/client_cert.pem" -days 3650
