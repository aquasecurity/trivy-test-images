FROM tomcat:8.5.77-jdk11-openjdk-slim-bullseye AS builder

EXPOSE 8080

RUN apt-get -y update && apt-get -y install maven zip unzip

COPY pom.xml pom.properties /spring/
COPY src /spring/src/
WORKDIR /spring
RUN mvn clean package

# Put pom.properties for offline scanning
RUN unzip target/helloworld.war WEB-INF/lib/spring-beans-5.3.15.jar \
    && mkdir -p META-INF/maven/ \
    && mv pom.properties META-INF/maven/ \
    && zip -u WEB-INF/lib/spring-beans-5.3.15.jar META-INF/maven/pom.properties \
    && zip -f target/helloworld.war WEB-INF/lib/spring-beans-5.3.15.jar

FROM tomcat:8.5.77-jre11-openjdk-slim-bullseye AS jre11
COPY --from=builder /spring/target/helloworld.war /usr/local/tomcat/webapps/

FROM tomcat:8.5.77-jre8-openjdk-slim-bullseye AS jre8
COPY --from=builder /spring/target/helloworld.war /usr/local/tomcat/webapps/
