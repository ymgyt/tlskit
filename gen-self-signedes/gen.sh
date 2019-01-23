#!/bin/bash

# see https://github.com/stozuka/grpc-go-course/blob/master/ssl/instructions.sh

SERVER_CN=localhost
PASS="gopher"
OUT="./out"
DAYS=3650

if ! which openssl > /dev/null; then
    echo "oepssl required"
    exit 1
fi

# Output files
# ca.key: certificate authority private key. (should not be shared)
# ca.crt: certificate authority trust certificate. (should be shared with users)
# server.key: server private key. (should not be shared)
# server.csr: server certificate signing request (should be shared with the ca)
# server.crt: server certificate signed by the ca (should be sent back by the ca)
# server.pem: conversion of server.key into format gRPC likes (should no be shared)


# generate trust certiciate (ca.crt)
openssl genrsa -passout pass:${PASS} -des3 -out ${OUT}/ca.key 4096
openssl req -passin pass:${PASS} -new -x509 -days ${DAYS} -key ${OUT}/ca.key -out ${OUT}/ca.crt -subj "/CN=${SERVER_CN}"

# generate server private key (server.key)
openssl genrsa -passout pass:${PASS} -des3 -out ${OUT}/server.key 4096

# get certiciate signed request
openssl req -passin pass:${PASS} -new -key ${OUT}/server.key -out ${OUT}/server.csr -subj "/CN=${SERVER_CN}"

# sign the certificate with the CA we created (server.crt)
openssl x509 -req -passin pass:${PASS} -days ${DAYS} -in ${OUT}/server.csr -CA ${OUT}/ca.crt -CAkey ${OUT}/ca.key -set_serial 01 -out ${OUT}/server.crt

# convert the server certificate to .pem format (server.pem)
openssl pkcs8 -topk8 -nocrypt -passin pass:${PASS} -in ${OUT}/server.key -out ${OUT}/server.pem