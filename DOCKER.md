# Browbeat on Docker

## Install Docker

Follow the docker documentation to install: https://docs.docker.com/engine/installation/mac/

To start the docker daemon:

```
rake docker:enable
```

To add docker commands to your PATH:

```
eval "$(docker-machine env default)"
```

You may wish to add the above command to your `~/.profile`.

### Versions

This docker configuration was built on the following versions:

```
$ docker -v
=> Docker version 1.10.3, build 20f81dd

$ docker-compose -v
=> docker-compose version 1.6.2, build 4d72027

$ docker-machine -v
=> docker-machine version 0.6.0, build e27fb87
```

You may need to run `docker login` for access to pre-built images.

## Building and running Browbeat

Build and run cucumber production tests in a docker container:

```
rake docker:browbeat:check:production
```

### Bundler

Dockerfile configures bundler to install gems into a separate container "gembox" configured in docker-compose, based on a [blog post](https://medium.com/@fbzga/how-to-cache-bundle-install-with-docker-7bed453a5800#.bpd1rz5ya). This avoids having to reinstall all gems when the web container must be rebuilt.

#### Tests in parallel

Can we run tests in parallel with docker? http://palexander.posthaven.com/running-ruby-tests-in-parallel-using-rake-fork-and-docker
