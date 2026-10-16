#!/bin/sh
# Generates the JKS files. It imports certificates created by gen.sh and must run after it,
# because gen.sh recreates rootfs. Run it with `make gen-crypto`.
set -eu

cd "$(dirname "$0")/rootfs"

mkdir -p opt/java/jdk-8/jre/lib/security

# A JKS keystore with a private key entry, encrypted with the key password, and a trusted
# certificate.
keytool -genkeypair -storetype JKS -keystore opt/app/app.jks -storepass changeit -keypass changeit \
	-alias app -keyalg RSA -keysize 2048 -sigalg SHA256withRSA -dname "CN=jks.trivy.test" \
	-startdate 2024/01/01 -validity 3653
keytool -importcert -noprompt -storetype JKS -keystore opt/app/app.jks -storepass changeit \
	-alias rsa -file etc/ssl/certs/rsa.pem

# A JKS trust store with the .keystore extension.
keytool -importcert -noprompt -storetype JKS -keystore opt/app/truststore.keystore -storepass changeit \
	-alias ec -file etc/ssl/certs/ec.der

# cacerts of JDK 17 and earlier, a JKS trust store with the default password.
for cert in rsa.pem ec.der; do
	keytool -importcert -noprompt -storetype JKS -keystore opt/java/jdk-8/jre/lib/security/cacerts \
		-storepass changeit -alias "${cert%.*}" -file "etc/ssl/certs/$cert"
done
