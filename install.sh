#!/bin/bash
#
# We configure the distro, here before it gets imported into docker
# to reduce the number of UFS layers that are needed for the Docker container.
#

# Adjust the following env vars if needed.
FUSE_ARTIFACT_ID=jboss-fuse-karaf-full
FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${FUSE_VERSION}/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip

# Lets fail fast if any command in this script does succeed.
set -e

#
# Lets switch to the /opt/jboss dir
#
cd /opt/jboss

# Download and extract the distro
curl -O ${FUSE_DISTRO_URL}
jar -xvf ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
rm ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
mv jboss-fuse-${FUSE_VERSION} jboss-fuse
chmod a+x jboss-fuse/bin/*
rm jboss-fuse/bin/*.bat jboss-fuse/bin/start jboss-fuse/bin/stop jboss-fuse/bin/status


# Lets remove some bits of the distro which just add extra weight in a docker image.
rm -rf jboss-fuse/extras
rm -rf jboss-fuse/quickstarts

#
# Let the karaf container name/id come from setting the FUSE_KARAF_NAME && FUSE_RUNTIME_ID env vars
# default to using the container hostname.
sed -i -e 's/environment.prefix=FABRIC8_/environment.prefix=FUSE_/' jboss-fuse/etc/system.properties
sed -i -e '/karaf.name=root/d' jboss-fuse/etc/system.properties
sed -i -e '/runtime.id=/d' jboss-fuse/etc/system.properties
echo '
if [ -z "$FUSE_KARAF_NAME" ]; then 
  export FUSE_KARAF_NAME="$HOSTNAME"
fi
if [ -z "$FUSE_RUNTIME_ID" ]; then 
  export FUSE_RUNTIME_ID="$FUSE_KARAF_NAME"
fi

export KARAF_OPTS="-Dkaraf.name=${FUSE_KARAF_NAME} -Druntime.id=${FUSE_RUNTIME_ID}"
'>> jboss-fuse/bin/setenv

# lets remove the karaf.delay.console=true to disable the progress bar
sed -i -e 's/karaf.delay.console=true/karaf.delay.console=false/' jboss-fuse/etc/config.properties 
sed -i -e 's/log4j.rootLogger=INFO, out, osgi:*/log4j.rootLogger=INFO, stdout, osgi:*/' jboss-fuse/etc/org.ops4j.pax.logging.cfg

echo '
bind.address=0.0.0.0
'>> jboss-fuse/etc/system.properties
echo '' >> jboss-fuse/etc/users.properties

rm /opt/jboss/install.sh