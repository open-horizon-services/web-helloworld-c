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
Set the ARCH variable to be the hardware you are running the service on.
```sh
export ARCH= <hardware architecture>
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

## Usage

To manually run the `web-helloworld-c` service locally as a test, enter `make`.  It will build a container and then run it locally.  This is the equivalent of running `make build` and then `make run`.  Once it successfully builds and runs, you can test it by running `make test` to see the HTML returned from the web server that the container runs.  Entering `docker ps` will show you the `web-helloworld-c` container is running locally.  When you are done and want to stop the container, enter `make stop`.  Entering `docker ps` again will show you that the container is no longer runniing.  Finally, entering `make clean` will remove the image that you built.

To create [the service definition](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/CreateService.md#build-publish-your-hw), publish it to the hub, and then form an agreement to download and run the service, enter `make publish`.  When installation is complete and an agreement has been formed, exit the watch command with Control-C.  You may then open the web page by entering `make test` or visiting [http://localhost:8000/](http://localhost:8000/) in a web browser.

### All Makefile targets

* `default` - executes the build, and then run targets
* `build` - performs a docker build of the container to create a local image
* `dev` - stops the container if it is running, builds, and then manually runs the container image locally while connectingto a terminal in the container.  Type "exit" to disconnect.
* `run` - stops the container if it is running, then manually runs the container locally
* `check` - populate the service definition with your current environment variables so you can confirm that the actual output matches your intended output
* `test` - request the web page from the web server to confirm that it is running and available
* `push` - Uploads your built container image to DockerHub (assumes you have performed a `docker login` and that your `DOCKER_HUB_ID` variable is set).
* `publish` - Publish the service definition and policy files, and the deployment policy file, to the hub in your organization
* `publish-service` - Publish the service definition file to the hub in your organization
* `remove-service` - Remove the service definition file from the hub in your organization
* `publish-service-policy` - Publish the [service policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#service-policy) file to the hub in your org
* `remove-service-policy` - Remove the service policy file from the hub in your org
* `publish-deployment-policy` - Publish a [deployment policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#deployment-policy) for the service to the hub in your org
* `remove-deployment-policy` - Remove a deployment policy for the service from the hub in your org
* `publish-pattern` - Publish the service pattern file to the hub in your organization.  Note: this is a legacy approach and cannot co-exist with any service deployments on the same host.
* `stop` - halt a locally-run container
* `clean` - remove the container image from the local cache
* `agent-run` - register your agent's [node policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#node-policy) with the hub
* `agent-run-pattern` - register your agent with the hub using the pattern
* `agent-stop` - unregister your agent with the hub, halting all agreements and stopping containers
* `deploy-check` - confirm that a registered agent is compatible with the service and deployment
* `log` - check the agent event logs
