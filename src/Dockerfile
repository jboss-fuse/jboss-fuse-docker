# Use latest jboss/base-jdk:7 image as the base
FROM jboss/base-jdk:7

MAINTAINER Hiram Chirino <hchirino@redhat.com>

# Set the FUSE_VERSION env variable
ENV FUSE_VERSION @project.version@

#
# This is not ideal. ADD/RUN will create 2 UFS layers, but we have
# to since COPY adds files with root ownership, and UFS cant chown stuff.
COPY jboss-fuse.tgz /opt/jboss/jboss-fuse.tgz
RUN \
  cd /opt/jboss && tar -zxf /opt/jboss/jboss-fuse.tgz && \
  rm /opt/jboss/jboss-fuse.tgz && \
  chmod +x ${HOME}/jboss-fuse/bin/*

#
# The following directories can hold config/data, so lets suggest the user
# mount them as volumes.
VOLUME /opt/jboss/jboss-fuse/bin
VOLUME /opt/jboss/jboss-fuse/etc
VOLUME /opt/jboss/jboss-fuse/data
VOLUME /opt/jboss/jboss-fuse/deploy

# default values of environment variables supplied by default for child containers created by jboss-fuse
# which have sensible defaults for folks creating new fabrics but can be overloaded when using docker run

ENV DOCKER_HOST http://192.168.59.103:2375
ENV FABRIC8_RUNTIME_ID root
ENV FABRIC8_KARAF_NAME root
ENV FABRIC8_BINDADDRESS 0.0.0.0
ENV FABRIC8_HTTP_PORT 8181
ENV FABRIC8_HTTP_PROXY_PORT 8181
ENV FABRIC8_GLOBAL_RESOLVER localip

# If the container is launched with re-mapped ports, these ENV vars should
# be set to the remapped values.
ENV FUSE_PUBLIC_OPENWIRE_PORT 61616
ENV FUSE_PUBLIC_MQTT_PORT 1883
ENV FUSE_PUBLIC_AMQP_PORT 5672
ENV FUSE_PUBLIC_STOMP_PORT 61613
ENV FUSE_PUBLIC_OPENWIRE_SSL_PORT 61617
ENV FUSE_PUBLIC_MQTT_SSL_PORT 8883
ENV FUSE_PUBLIC_AMQP_SSL_PORT 5671
ENV FUSE_PUBLIC_STOMP_SSL_PORT 61614

EXPOSE 1099 2181 8101 8181 9300 9301 44444 61616 1883 5672 61613 61617 8883 5671 61614

# lets default to the jboss-fuse dir so folks can more easily navigate to the data/logs
WORKDIR /opt/jboss/jboss-fuse

CMD ${HOME}/jboss-fuse/bin/fuse server