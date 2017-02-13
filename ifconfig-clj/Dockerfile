FROM openjdk:8-jre
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# To build and run:
#   lein ring uberjar && docker build -t ifconfig-clj . && docker run -it -p 3000:3000 ifconfig-clj

ADD target/ifconfig-clj-0.0.1-SNAPSHOT-standalone.jar ifconfig-clj.jar
ENTRYPOINT ["java", "-jar", "ifconfig-clj.jar"]

