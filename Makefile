ifndef TEST_IMAGE
    export TEST_IMAGE=ghcr.io/aquasecurity/trivy-test-images
endif

build-busybox:
	docker build -t $(TEST_IMAGE):busybox-with-lockfile busybox-with-lockfile
	docker push $(TEST_IMAGE):busybox-with-lockfile
	docker rmi -f $(TEST_IMAGE):busybox-with-lockfile

build-containerd:
	docker build -t $(TEST_IMAGE)/containerd:latest containerd
	docker push $(TEST_IMAGE)/containerd:latest
	docker rmi -f $(TEST_IMAGE)/containerd:latest

# CI pushes the crypto image on every change under crypto/, and gen.sh creates new keys on
# every run. Trivy golden files depend on the keys of a published tag, so regenerated material
# needs a new tag.
CRYPTO_TAG := crypto-v2

build-crypto:
	docker build -t $(TEST_IMAGE):$(CRYPTO_TAG) crypto
	docker push $(TEST_IMAGE):$(CRYPTO_TAG)
	docker rmi -f $(TEST_IMAGE):$(CRYPTO_TAG)

gen-crypto:
	docker run --rm -v "$(CURDIR)/crypto:/work" -w /work --entrypoint sh alpine/openssl:3.5.4 gen.sh
	docker run --rm -v "$(CURDIR)/crypto:/work" -w /work --entrypoint sh eclipse-temurin:21.0.12.1_1-jre-alpine gen-jks.sh

build-spring4shell:
	docker build --target jre11 -t $(TEST_IMAGE):spring4shell-jre11 spring4shell
	docker push $(TEST_IMAGE):spring4shell-jre11
	docker rmi -f $(TEST_IMAGE):spring4shell-jre11
	docker build --target jre8 -t $(TEST_IMAGE):spring4shell-jre8 spring4shell
	docker push $(TEST_IMAGE):spring4shell-jre8
	docker rmi -f $(TEST_IMAGE):spring4shell-jre8

copy-images:
	./copy-images.sh