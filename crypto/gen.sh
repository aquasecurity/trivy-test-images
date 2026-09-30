#!/bin/sh
# Generates the cryptographic material the image is built from. Run it with `make gen-crypto`.
#
# Every run creates new keys, so update the Trivy golden files together with the result.
set -eu

cd "$(dirname "$0")"

validity="-not_before 20240101000000Z -not_after 20340101000000Z"

rm -rf rootfs
mkdir -p rootfs/etc/ssl/certs rootfs/etc/ssl/private rootfs/etc/ssl/public rootfs/opt/app
cd rootfs

# A certificate with every kind of SAN, and its key as PKCS#8 and PKIX files.
# All three share one public key.
openssl req -x509 -newkey rsa:2048 -sha256 -noenc -set_serial 1 $validity \
	-subj "/CN=rsa.trivy.test" \
	-addext "basicConstraints=critical,CA:FALSE" \
	-addext "keyUsage=critical,digitalSignature,keyEncipherment" \
	-addext "extendedKeyUsage=serverAuth,clientAuth" \
	-addext "subjectAltName=DNS:rsa.trivy.test,email:crypto@trivy.test,IP:127.0.0.1,URI:https://trivy.test/rsa" \
	-keyout etc/ssl/private/rsa.key -out etc/ssl/certs/rsa.pem
openssl pkey -in etc/ssl/private/rsa.key -pubout -out etc/ssl/public/rsa.pem

# The same certificate in another layer.
cp etc/ssl/certs/rsa.pem opt/app/rsa.pem

# An EC certificate in DER, and its key as SEC1.
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -sha256 -noenc -set_serial 2 $validity \
	-subj "/CN=ec.trivy.test" \
	-keyout /tmp/ec.key -out /tmp/ec.pem
openssl x509 -in /tmp/ec.pem -outform der -out etc/ssl/certs/ec.der
openssl pkey -in /tmp/ec.key -traditional -out etc/ssl/private/ec.key

# A PKCS#1 key that appears in no other file.
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 -out /tmp/pkcs1.key
openssl pkey -in /tmp/pkcs1.key -traditional -out etc/ssl/private/pkcs1.key

# Ed25519 uses one OID for the key and the signature. The certificate and its key share
# one file.
openssl req -x509 -newkey ed25519 -noenc -set_serial 3 $validity \
	-subj "/CN=ed25519.trivy.test" \
	-keyout /tmp/ed25519.key -out /tmp/ed25519.pem
cat /tmp/ed25519.pem /tmp/ed25519.key > etc/ssl/certs/ed25519.pem

# ML-DSA, with the parameter set in the OID.
openssl req -x509 -newkey ML-DSA-65 -noenc -set_serial 6 $validity \
	-subj "/CN=ml-dsa.trivy.test" \
	-keyout /tmp/ml-dsa.key -out etc/ssl/certs/ml-dsa.pem

# A CA with pathlen:0 and the certificate it issued, in one file.
openssl req -x509 -newkey rsa:2048 -sha256 -noenc -set_serial 4 $validity \
	-subj "/CN=Trivy Crypto Test CA" \
	-addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
	-addext "keyUsage=critical,keyCertSign,cRLSign" \
	-keyout /tmp/ca.key -out /tmp/ca.pem
openssl req -new -newkey rsa:2048 -noenc \
	-subj "/CN=leaf.trivy.test" \
	-keyout /tmp/leaf.key -out /tmp/leaf.csr
openssl x509 -req -in /tmp/leaf.csr -CA /tmp/ca.pem -CAkey /tmp/ca.key -sha256 -set_serial 5 $validity \
	-out /tmp/leaf.pem
cat /tmp/leaf.pem /tmp/ca.pem > etc/ssl/certs/bundle.pem

# An encrypted PKCS#8 key.
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 -out /tmp/encrypted.key
openssl pkcs8 -topk8 -v2 aes-256-cbc -passout pass:trivy \
	-in /tmp/encrypted.key -out etc/ssl/private/encrypted.key

# A legacy encrypted PEM key, with the Proc-Type and DEK-Info headers.
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 -out /tmp/legacy-encrypted.key
openssl pkey -in /tmp/legacy-encrypted.key -traditional -aes256 -passout pass:trivy \
	-out etc/ssl/private/legacy-encrypted.key

# A certificate request, which is not part of the inventory.
openssl req -new -newkey rsa:2048 -noenc \
	-subj "/CN=request.trivy.test" \
	-keyout /tmp/request.key -out etc/ssl/certs/request.pem

# A CERTIFICATE block that does not parse.
printf -- "-----BEGIN CERTIFICATE-----\nbm90IGEgY2VydGlmaWNhdGU=\n-----END CERTIFICATE-----\n" \
	> etc/ssl/certs/broken.pem
