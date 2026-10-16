#!/bin/sh
# Generates the cryptographic material the image is built from. Run it with `make gen-crypto`.
#
# Every run creates new keys, so update the Trivy golden files together with the result.
set -eu

cd "$(dirname "$0")"

validity="-not_before 20240101000000Z -not_after 20340101000000Z"
# Trivy integration tests run with the time fixed at 2021-08-25, so this validity ends before it.
expired="-not_before 20190101000000Z -not_after 20200101000000Z"

rm -rf rootfs
mkdir -p rootfs/etc/ssl/certs rootfs/etc/ssl/private rootfs/etc/ssl/public rootfs/opt/app \
	rootfs/opt/java/jdk-21/lib/security
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

# A PUBLIC KEY block that names RSA but holds no valid RSA key.
cat > /tmp/broken-rsa.cnf <<EOF
asn1=SEQUENCE:spki
[spki]
algorithm=SEQUENCE:algorithm
key=FORMAT:HEX,BITSTRING:00
[algorithm]
oid=OID:rsaEncryption
params=NULL
EOF
openssl asn1parse -genconf /tmp/broken-rsa.cnf -noout -out /tmp/broken-rsa.der
{
	echo "-----BEGIN PUBLIC KEY-----"
	openssl base64 -in /tmp/broken-rsa.der
	echo "-----END PUBLIC KEY-----"
} > etc/ssl/public/broken.pem

# A self-signed certificate signed with SHA-1, expired and carrying an RSA-1024 key. The file
# also holds the key as a PUBLIC KEY block, and the private key is a PKCS#8 file.
openssl req -x509 -newkey rsa:1024 -sha1 -noenc -set_serial 7 $expired \
	-subj "/CN=weak.trivy.test" \
	-keyout etc/ssl/private/weak.key -out /tmp/weak.pem
openssl pkey -in etc/ssl/private/weak.key -pubout -out /tmp/weak.pub
cat /tmp/weak.pem /tmp/weak.pub > etc/ssl/certs/weak.pem

# The same weak certificate in another file.
cp /tmp/weak.pem opt/app/weak.pem

# DSA and ECDSA certificates signed with SHA-1.
openssl genpkey -genparam -algorithm DSA -pkeyopt dsa_paramgen_bits:2048 -out /tmp/dsa.params
openssl req -x509 -newkey dsa:/tmp/dsa.params -sha1 -noenc -set_serial 8 $validity \
	-subj "/CN=dsa-sha1.trivy.test" \
	-keyout /tmp/dsa-sha1.key -out etc/ssl/certs/dsa-sha1.pem
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -sha1 -noenc -set_serial 9 $validity \
	-subj "/CN=ecdsa-sha1.trivy.test" \
	-keyout /tmp/ecdsa-sha1.key -out etc/ssl/certs/ecdsa-sha1.pem

# RSA-PSS with SHA-1. SHA-1 and a 20-byte salt are the RSASSA-PSS-params defaults,
# so the parameters are an empty SEQUENCE and the hash is implicit.
openssl req -x509 -newkey rsa:2048 -sha1 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:20 \
	-noenc -set_serial 10 $validity \
	-subj "/CN=rsa-pss-sha1.trivy.test" \
	-keyout /tmp/rsa-pss-sha1.key -out etc/ssl/certs/rsa-pss-sha1.pem

# RSA-PSS with SHA-256, where the hash is written in the signature parameters.
openssl req -x509 -newkey rsa:2048 -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:32 \
	-noenc -set_serial 14 $validity \
	-subj "/CN=rsa-pss-sha256.trivy.test" \
	-keyout /tmp/rsa-pss-sha256.key -out etc/ssl/certs/rsa-pss-sha256.pem

# P-192, which crypto/x509 does not support, as a certificate, a PKIX key and a SEC1 key.
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-192 -sha256 -noenc -set_serial 11 $validity \
	-subj "/CN=p192.trivy.test" \
	-keyout /tmp/p192.key -out etc/ssl/certs/p192.pem
openssl pkey -in /tmp/p192.key -pubout -out etc/ssl/public/p192.pem
openssl pkey -in /tmp/p192.key -traditional -out etc/ssl/private/p192.key

# Ed448, which crypto/x509 does not decode, as a certificate and a PKIX key.
openssl req -x509 -newkey ed448 -noenc -set_serial 12 $validity \
	-subj "/CN=ed448.trivy.test" \
	-keyout /tmp/ed448.key -out etc/ssl/certs/ed448.pem
openssl pkey -in /tmp/ed448.key -pubout -out etc/ssl/public/ed448.pem

# X448 cannot sign, so its certificate is issued by the Ed448 certificate.
openssl genpkey -algorithm X448 -out etc/ssl/private/x448.key
openssl pkey -in etc/ssl/private/x448.key -pubout -out etc/ssl/public/x448.pem
openssl x509 -new -subj "/CN=x448.trivy.test" -force_pubkey etc/ssl/public/x448.pem \
	-CA etc/ssl/certs/ed448.pem -CAkey /tmp/ed448.key -set_serial 13 $validity \
	-out etc/ssl/certs/x448.pem

# A standalone X25519 key, which crypto/x509 decodes into a type Trivy does not support.
openssl genpkey -algorithm X25519 -out etc/ssl/private/x25519.key
openssl pkey -in etc/ssl/private/x25519.key -pubout -out etc/ssl/public/x25519.pem

# A PKCS#12 trust store without a password, with its certificate stored without encryption.
openssl pkcs12 -export -nokeys -in etc/ssl/certs/rsa.pem -certpbe NONE -nomac -passout pass: \
	-out opt/app/truststore.p12

# A PKCS#12 file with a password, which encrypts its certificates by default.
openssl pkcs12 -export -in /tmp/ec.pem -inkey /tmp/ec.key -passout pass:trivy \
	-out opt/app/protected.p12

# A PKCS#12 file with its certificate stored without encryption and an encrypted private key.
openssl pkcs12 -export -in etc/ssl/certs/rsa.pem -inkey etc/ssl/private/rsa.key -certpbe NONE \
	-passout pass:trivy -out opt/app/app.pfx

# cacerts of JDK 18 and later, a PKCS#12 file without a password whose certificates are
# marked as trusted.
cat /tmp/ca.pem /tmp/ec.pem > /tmp/cacerts.pem
openssl pkcs12 -export -nokeys -in /tmp/cacerts.pem -certpbe NONE -nomac -passout pass: \
	-jdktrust anyExtendedKeyUsage -out opt/java/jdk-21/lib/security/cacerts
