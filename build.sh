#!/bin/bash
#
# We configure the distro, here before it gets imported into docker
# to reduce the number of UFS layers that are needed for the Docker container.
#

# Adjust the following env vars if needed.
FUSE_VERSION=6.2.0.redhat-059
FUSE_DISTRO_URL=https://repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/jboss-fuse-full/${FUSE_VERSION}/jboss-fuse-full-${FUSE_VERSION}.zip
DOCKER_IMAGE_NAME=jboss/jboss-fuse-full
DOCKER_IMAGE_VERSION=latest

# Lets fail fast if any command in this script does succeed.
set -e

#
# Lets switch to the target dir
#
cd `dirname $0 2> /dev/null`
mkdir -p target

cp -R src/* target
cd target

# Download the distro if we have not yet..
if [ ! -f  jboss-fuse-full-${FUSE_VERSION}.zip ] ; then
  wget -O jboss-fuse-full-${FUSE_VERSION}.zip ${FUSE_DISTRO_URL}
fi

rm -rf jboss-fuse-${FUSE_VERSION} || true
jar -xvf jboss-fuse-full-${FUSE_VERSION}.zip

rm -rf jboss-fuse || true
mv jboss-fuse-${FUSE_VERSION} jboss-fuse
chmod a+x jboss-fuse/bin/*

# Lets remove some bits of the distro which just add extra weight in a docker image.
rm -rf jboss-fuse/extras
rm -rf jboss-fuse/quickstarts

# Lets add some docker specific profiles..
cp -R fabric jboss-fuse

# lets remove the karaf.name by default so we can default it from env vars
sed -i -e '/karaf.name=root/d' jboss-fuse/etc/system.properties
sed -i -e '/runtime.id=/d' jboss-fuse/etc/system.properties
# lets remove the karaf.delay.console=true to disable the progress bar
sed -i -e 's/karaf.delay.console=true/karaf.delay.console=false/' jboss-fuse/etc/config.properties 
# lets enable logging to standard out
sed -i -e 's/log4j.rootLogger=INFO, out, osgi:*/log4j.rootLogger=INFO, stdout, osgi:*/' jboss-fuse/etc/org.ops4j.pax.logging.cfg

echo '
bind.address=0.0.0.0
fabric.environment=docker
zookeeper.password.encode=true
'>> jboss-fuse/etc/system.properties
echo '' >> jboss-fuse/etc/users.properties

# Lets create a tgz
tar -zcf jboss-fuse.tgz jboss-fuse

docker rmi --force=true ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}
docker build --force-rm=true --rm=true -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
echo =========================================================================
echo Docker image is ready.  Try it out by running:
echo     docker run --rm -ti -P ${DOCKER_IMAGE_NAME}
echo =========================================================================