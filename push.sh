#!/bin/sh

# Install crane if missing
if !(type "crane" > /dev/null 2>&1); then
  go install github.com/google/go-containerregistry/cmd/crane@latest
fi

TEST_IMAGE=ghcr.io/aquasecurity/trivy-test-images


cat <<EOS

#############################
Spring4Shell (CVE-2022-22965)
#############################

EOS

docker build --target jre11 -t ${TEST_IMAGE}:spring4shell-jre11 spring4shell
docker push ${TEST_IMAGE}:spring4shell-jre11
docker rmi -f ${TEST_IMAGE}:spring4shell-jre11

docker build --target jre8 -t ${TEST_IMAGE}:spring4shell-jre8 spring4shell
docker push ${TEST_IMAGE}:spring4shell-jre8
docker rmi -f ${TEST_IMAGE}:spring4shell-jre8

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


cat <<EOS

############################################
quay.io/fluentd_elasticsearch/fluentd:v2.9.0
############################################

EOS

crane copy quay.io/fluentd_elasticsearch/fluentd@sha256:54716d825ec9791ffb403ac17a1e82159c98ac6161e02b2a054595ad01aa6726 ${TEST_IMAGE}:fluentd-multiple-lockfiles

cat <<EOS

########################################
amazonlinux:1 - Amazon Linux AMI 2018.03
########################################

EOS

crane copy amazonlinux@sha256:5ded99e84532e28bbcf5ad466aeddc54eca2622a21e6f393cc6469c6ca8b1d2b ${TEST_IMAGE}:amazon-1
