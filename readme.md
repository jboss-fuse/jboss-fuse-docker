# FUSE Docker image

This project builds a Docker image for [JBoss Fuse](http://www.jboss.org/products/fuse/overview/).

## Usage

You can then run a Fuse server with the following command:

    docker run -it -P jboss/jboss-fuse-full bin/fuse

Note that the web console will not be accessible since we have not yet defined users that can log into it
and have not exposed the web console port on the docker host.

## Extending the image

To be able to create a management user to access the administration console create a Dockerfile with the
following content:

    FROM jboss/jboss-fuse-full
    COPY users.properties /opt/jboss/jboss-fuse/etc/
    
Then create a `users.properties` file that contains your users, passwords, and roles.  For example:

    admin=password,Operator, Maintainer, Deployer, Auditor, Administrator, SuperUser
    dev=password,Operator, Maintainer, Deployer

Then you can build the image:

    docker build --tag=jboss/jboss-fuse-full-admin .

Run it:

    docker run -it -p 8181:8181 jboss/jboss-fuse-full-admin

The administration console should be available at http://localhost:8181.

## Image internals [updated Oct 14, 2014]

This image extends the [`jboss/base-jdk:7`](https://github.com/JBoss-Dockerfiles/base-jdk/tree/jdk7) image which adds the OpenJDK distribution on top of the [`jboss/base`](https://github.com/JBoss-Dockerfiles/base) image. Please refer to the README.md for selected images for more info.

The server is run as the `jboss` user which has the uid/gid set to `1000`.

Fuse is installed in the `/opt/jboss/jboss-fuse` directory.

## Source

The source is [available on GitHub](https://github.com/fuse/fuse-docker).

## Issues

Please report any issues or file RFEs on [GitHub](https://github.com/fuse/fuse-docker/issues).