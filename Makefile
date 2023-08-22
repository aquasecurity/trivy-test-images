build-busybox:
	docker build -t $(TEST_IMAGE):busybox-with-lockfile busybox-with-lockfile
	docker push $(TEST_IMAGE):busybox-with-lockfile
	docker rmi -f $(TEST_IMAGE):busybox-with-lockfile

build-containerd:
	docker build -t $(TEST_IMAGE)/containerd:latest containerd
	docker push $(TEST_IMAGE)/containerd:latest
	docker rmi -f $(TEST_IMAGE)/containerd:latest

build-spring4shell:
	docker build --target jre11 -t $(TEST_IMAGE):spring4shell-jre11 spring4shell
	docker push $(TEST_IMAGE):spring4shell-jre11
	docker rmi -f $(TEST_IMAGE):spring4shell-jre11
	docker build --target jre8 -t $(TEST_IMAGE):spring4shell-jre8 spring4shell
	docker push $(TEST_IMAGE):spring4shell-jre8
	docker rmi -f $(TEST_IMAGE):spring4shell-jre8

push-crane-images:
	./push-crane-images.sh