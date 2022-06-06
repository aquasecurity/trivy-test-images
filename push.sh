#!/bin/sh

# Install crane if missing
if !(type "crane" > /dev/null 2>&1); then
  go install github.com/google/go-containerregistry/cmd/crane@latest
fi

TEST_IMAGE=ghcr.io/aquasecurity/trivy-test-images

cat <<EOS

######################
almalinux:8.5-20211112
######################

EOS

crane copy almalinux@sha256:08042694fffd61e6a0b3a22dadba207c8937977915ff6b1879ad744fd6638837 ${TEST_IMAGE}:almalinux-8

cat <<EOS

##########
alpine:3.9
##########

EOS

crane copy alpine@sha256:414e0518bb9228d35e4cd5165567fb91d26c6a214e9c95899e1e056fcd349011 ${TEST_IMAGE}:alpine-39
	
cat <<EOS

###########
alpine:3.10
###########

EOS

crane copy alpine@sha256:451eee8bedcb2f029756dc3e9d73bab0e7943c1ac55cff3a4861c52a0fdd3e98 ${TEST_IMAGE}:alpine-310

cat <<EOS

###############################
ghcr.io/distroless/git:20220412
###############################

EOS

crane copy ghcr.io/distroless/git@sha256:107c3bcf9a5d92c88e1085cb949d247ebe95cfbf6235d4a4307d129d2874de71 ${TEST_IMAGE}:alpine-distroless

cat <<EOS

####################
busybox + Cargo.lock
####################

EOS

docker build -t ${TEST_IMAGE}:busybox-with-lockfile busybox-with-lockfile
docker push ${TEST_IMAGE}:busybox-with-lockfile
docker rmi -f ${TEST_IMAGE}:busybox-with-lockfile
