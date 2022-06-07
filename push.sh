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

#########################################################
amazonlinux:2018.03.0.20190826 - Amazon Linux AMI 2018.03
#########################################################

EOS

crane copy amazonlinux@sha256:29bdb2208f371f33ef2eea91282e4df0b113cd495ce4f6368b1b6ddf5ca8121e ${TEST_IMAGE}:amazon-1

cat <<EOS

#########################################
amazonlinux:2.0.20190508 - Amazon Linux 2
#########################################

EOS

crane copy amazonlinux@sha256:730fae68c6a180e8006443b0f090e56419da5ceb5d11250d96e627660ffbc674 ${TEST_IMAGE}:amazon-2

cat <<EOS

########
centos:6
########

EOS

crane copy centos@sha256:a93df2e96e07f56ea48f215425c6f1673ab922927894595bb5c0ee4c5a955133 ${TEST_IMAGE}:centos-6

cat <<EOS

###############
centos:7.6.1810
###############

EOS

crane copy centos@sha256:62d9e1c2daa91166139b51577fe4f4f6b4cc41a3a2c7fc36bd895e2a17a3e4e6 ${TEST_IMAGE}:centos-7

cat <<EOS

######################
debian:buster-20190910
######################

EOS

crane copy debian@sha256:e25b64a9cf82c72080074d6b1bba7329cdd752d51574971fd37731ed164f3345 ${TEST_IMAGE}:debian-buster

cat <<EOS

#######################
debian:stretch-20190812
#######################

EOS

crane copy debian@sha256:94a5c04481bb50a4f34ebbb105e39388700202a6e34cb41b9b9afdaca854567c ${TEST_IMAGE}:debian-stretch

cat <<EOS

######################
gcr.io/distroless/base
######################

EOS

crane copy gcr.io/distroless/base@sha256:6bf7a69660340caf6d227c9dc4ff5ca2028beb5f9280c05d3e4fe57c308be6ea ${TEST_IMAGE}:distroless-base

cat <<EOS

###########################
gcr.io/distroless/python2.7
###########################

EOS

crane copy gcr.io/distroless/python2.7@sha256:c2218251f7e76f1d3f2ea63cf71f24c9805b0ba5eb8ff0aa8ea175b10ca8293b ${TEST_IMAGE}:distroless-python27

cat <<EOS

#########
fedora:35
#########

EOS

crane copy fedora@sha256:f1e3a29da8990568c1da6a460cf9658ee7e9b409aa39c2aded67f7ac1dfe7e8a ${TEST_IMAGE}:fedora35

cat <<EOS

############################################
cblmariner.azurecr.io/base/core:1.0.20220122
############################################

EOS

crane copy cblmariner.azurecr.io/base/core@sha256:aae34b1787c1dab3adcc72c45f730bf49483cdd04ed62a32080e6e82cfaf91bf ${TEST_IMAGE}:mariner-1.0

cat <<EOS

############################
docker.io/opensuse/leap:15.1
############################

EOS

crane copy opensuse/leap@sha256:66075abcd272f619a86aa115b3040735c42dd18fcab784754e0eb798b56de6f5 ${TEST_IMAGE}:opensuse-leap-151

cat <<EOS

###################
photon:3.0-20190823
###################

EOS

crane copy photon@sha256:9f6284dd3794e60f3d97a446b41a50bbaf3a2bf12f5f654a35d66c41306559ba ${TEST_IMAGE}:photon-30

cat <<EOS

##############
rockylinux:8.5
##############

EOS

crane copy rockylinux@sha256:5fed5497b568bcf7a90a00965987fc099edbcf44b1179a5ef6d4b47758281ca5 ${TEST_IMAGE}:rockylinux-8

cat <<EOS

###########
ubi:7.7-140
###########

EOS

crane copy registry.access.redhat.com/ubi7/ubi@sha256:ef06b1b4d4b8e1c4fc5cb8a01477d27c11ac2364b966ab6341257d6965ad0846 ${TEST_IMAGE}:ubi-7

cat <<EOS

##########################################################
ubuntu:xenial-20190720 - Ubuntu 16.04.6 LTS (Xenial Xerus)
##########################################################

EOS

crane copy ubuntu@sha256:97b54e5692c27072234ff958a7442dde4266af21e7b688e7fca5dc5acc8ed7d9 ${TEST_IMAGE}:ubuntu-1604

cat <<EOS

####################################################
ubuntu:bionic-20190807 - 18.04.3 LTS (Bionic Beaver)
####################################################

EOS

crane copy ubuntu@sha256:d1d454df0f579c6be4d8161d227462d69e163a8ff9d20a847533989cf0c94d90 ${TEST_IMAGE}:ubuntu-1804

cat <<EOS

#####################################
vulnimage - knqyf263/vuln-image:1.2.3
#####################################

EOS

crane copy knqyf263/vuln-image@sha256:1e8b199249d6d0ef3419ddc6eda2348d9fbdb10d350d3bb70aa98e87faa227c9 ${TEST_IMAGE}:vulnimage

cat <<EOS

###############
oraclelinux:8.0
###############

EOS

crane copy oraclelinux@sha256:157ec47eb5bfcb428432ca5365c6bf045189b68fbc62ffde7566dd66db1dca6d ${TEST_IMAGE}:oraclelinux-8

cat <<EOS

##################################
suse-15.3: suse/sle15:15.3.17.8.16
##################################

EOS

crane copy registry.suse.com/suse/sle15@sha256:3c0b843c0d669e7851a65cea416644b7eefba03ea5b279ae8a2b82c29c61cc4b ${TEST_IMAGE}:suse-15.3
