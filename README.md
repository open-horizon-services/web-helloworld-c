# web-helloworld-c
![](https://img.shields.io/github/license/open-horizon-services/web-helloworld-c)
![](https://img.shields.io/badge/architecture-arm32-green)
![](https://img.shields.io/github/contributors/open-horizon-services/web-helloworld-c)

Extremely simple HTTP server (written in C) that responds on port 8000 with a hello message. The docker container is built using the "multi-stage build process, with the second build stage being `FROM scratch` (a completely empty file system with no Linux distro). For details on how to do that, see the Dockerfile.

I think this will build on many hardware architectures. :-)  I tested in on a Raspberry Pi 3B (arm32v7) and the image size ended up being 0.4MB (see below). That's pretty tiny considering that the extremely tiny `alpine` Linux distro base container with no workload inside at all is about 10 times larger than this:

```
-rw-r--r-- 1 pi pi 4098560 Apr 27 20:03 alpine.tar
-rw-r--r-- 1 pi pi  419840 Apr 28 14:39 web-hello-c.tar
```
Begin by editing the variables at the top of the Makefile as desired. If you plan to push it to a Docker registery, make sure you give your docker ID. You may also want to create unique names for your **service** and **pattern** (necessary if you are sharing a tenancy with other users and you are all publishing this service).


To play with this outside of Open Horizon:

```sh
make build
make run
```

Test the service:
```sh
make test
```
Stop the running service
```sh
make stop
```

When you are ready to try it inside Open Horizon:
```sh
docker login
```

Create a cryptographic signing key pair. This enables you to sign services when publishing them to the exchange. This step only needs to be done once.
```sh
hzn key create **yourcompany** **youremail**
```
Build the service:
```sh
make build
make push
```

Publish your service definition and policy, deployment policy files to the Horizon Exchange
```sh
make publish
```

Once it is published, you can get the agent to deploy it:
```sh
make agent-run
```
Then you can watch the agreement form:

```sh
watch hzn agreement list
... (runs forever, so press Ctrl-C when you want to stop)
```
Test the service:
```sh
docker ps
make test
```

Then when you are done you can get the agent to stop running it:

```sh
make agent-stop
```
