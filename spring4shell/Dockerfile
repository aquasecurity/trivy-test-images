FROM tomcat:8.5.77-jdk11-openjdk-slim-bullseye AS builder

EXPOSE 8080

RUN apt-get -y update && apt-get -y install maven

COPY . /spring
WORKDIR /spring
RUN mvn clean package

FROM tomcat:8.5.77-jre11-openjdk-slim-bullseye AS jre11
COPY --from=builder /spring/target/helloworld.war /usr/local/tomcat/webapps/

FROM tomcat:8.5.77-jre8-openjdk-slim-bullseye AS jre8
COPY --from=builder /spring/target/helloworld.war /usr/local/tomcat/webapps/
