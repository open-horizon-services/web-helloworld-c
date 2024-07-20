# web-helloworld-c
![](https://img.shields.io/github/license/open-horizon-services/web-helloworld-c)
![](https://img.shields.io/badge/architecture-arm32-green)
![](https://img.shields.io/github/contributors/open-horizon-services/web-helloworld-c)

Extremely simple HTTP server (written in C) that responds on port 8000 with a hello message. The docker container is built using the "multi-stage build process, with the second build stage being `FROM scratch` (a completely empty file system with no Linux distro). For details on how to do that, see the Dockerfile.

## Prerequisites

NOTE: If you plan to build a new image, a DockerHub login is required and `export DOCKER_HUB_ID=[your DockerHub ID]` before running installation and Makefile targets.

NOTE: Export the "ARCH" environment variable to set a non-default value for the build process.

To ensure the successful installation and operation of the Open Horizon service, the following prerequisites must be met:

**Open Horizon Management Hub:** To publish this service and register your edge node, you must either [install the Open Horizon Management Hub](https://open-horizon.github.io/quick-start) or have access to an existing hub. You may also choose a downstream commercial distribution like IBM's Edge Application Manager. If you'd like to use the Open Horizon community hub, you may [apply for a temporary account](https://wiki.lfedge.org/display/LE/Open+Horizon+Management+Hub+Developer+Instance) at the Open Horizon community hub, where credentials will be provided.

**Edge Node:**You will need an x86 computer running Linux or macOS, or an ARM64 device such as a Raspberry Pi running Raspberry Pi OS or Ubuntu. The `anax` agent software must be installed on your edge node. This software facilitates communication with the Management Hub and manages the deployment of services.

**Optional Utilities:** Depending on your operating system, you may use:
  - `brew` on macOS
  - `apt-get` on Ubuntu or Raspberry Pi OS
  - `yum` on Fedora
  
These commands can install `gcc`, `make`, `git`, `jq`, `curl`, and `net-tools`. These utilities are not strictly required but are highly recommended for successful deployment and troubleshooting.

## Installation

1. **Clone the repository:**
    Clone the `web-helloworld-c` GitHub repo from a terminal prompt on the edge node and enter the folder where the artifacts were copied.

   ```shell
   git clone https://github.com/open-horizon-services/web-helloworld-c.git
   cd web-helloworld-c
    ```

2. **Edit Makefile:**
    Adjust the variables at the top of the Makefile as needed, including your Docker ID and unique names for your service and pattern.

    ```shell
    DOCKER_HUB_ID=your_docker_id
    ARCH=amd64
    ```
    You can also override these default values by exporting them in your terminal before running any make commands. This way, you don't have to edit the values directly in the Makefile.
   ```shell
   export DOCKER_HUB_ID=my_docker_id
   export ARCH=my_architecture
   ```
   
    Run `make clean` to confirm that the "make" utility is installed and working

    Confirm that you have the Open Horizon agent installed by using the CLI to check the version:

    ``` shell
     hzn version
     ```

    It should return values for both the CLI and the Agent (actual version numbers may vary from those shown):

    ``` text
    Horizon CLI version: 2.31.0-1540
    Horizon Agent version: 2.31.0-1540
    ```

    If it returns "Command not found", then the Open Horizon agent is not installed.

    If it returns a version for the CLI but not the agent, then the agent is installed but not running.  You may run it with `systemctl horizon start` on Linux or `horizon-container start` on macOS.

    Check that the agent is in an unconfigured state, and that it can communicate with a hub.  If you have the `jq` utility installed, run `hzn node list | jq '.configstate.state'` and check that the value returned is "unconfigured".  If not, running `make agent-stop` or `hzn unregister -f` will put the agent in an unconfigured state.  Run `hzn node list | jq '.configuration'` and check that the JSON returned shows values for the "exchange_version" property, as well as the "exchange_api" and "mms_api" properties showing URLs.  If those do not, then the agent is not configured to communicate with a hub.  If you do not have `jq` installed, run `hzn node list` and eyeball the sections mentioned above.

    NOTE: If "exchange_version" is showing an empty value, you will not be able to publish and run the service.  The only fix found to this condition thus far is to re-install the agent using these instructions:

    ```shell
    hzn unregister -f # to ensure that the node is unregistered
    systemctl horizon stop # for Linux, or "horizon-container stop" on macOS
    export HZN_ORG_ID=myorg   # or whatever you customized it to
    export HZN_EXCHANGE_USER_AUTH=admin:<admin-pw>   # use the pw deploy-mgmt-hub.sh displayed
    export HZN_FSS_CSSURL=http://<mgmt-hub-ip>:9443/
    curl -sSL https://github.com/open-horizon/anax/releases/latest/download/agent-install.sh | bash -s -- -i anax: -k css: -c css: -p IBM/pattern-ibm.helloworld -w '*' -T 120
    ```

### To play with this outside of Open Horizon:

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

### Try it inside Open Horizon:
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
```

Push it in your docker hub:
```sh
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

To manually run the `web-helloworld-c` service locally as a test, enter `make`.  It will build a container and then run it locally.  This is the equivalent of running `make build` and then `make run`.  Once it successfully builds and runs, you can test it by running `make test` to see the HTML returned from the web server that the container runs.  Entering `docker ps` will show you the `web-helloworld-c` container is running locally.  When you are done and want to stop the container, enter `make stop`.  Entering `docker ps` again will show you that the container is no longer running.  Finally, entering `make clean` will remove the image that you built.

To create [the service definition](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/CreateService.md#build-publish-your-hw), publish it to the hub, and then form an agreement to download and run the service, enter `make publish`.  When installation is complete and an agreement has been formed, exit the watch command with Control-C.  You may then open the web page by entering `make test` or visiting [http://localhost:8000/](http://localhost:8000/) in a web browser.

## Advanced Details

### Debugging

The Makefile includes several targets to assist you in inspecting what is happening to see if they match your expectations.  They include:

`make log` to see both the event logs and the service logs.

`make check` to see the values in your environment variables and how they are populated into the service definition file.

`make deploy-check` to see if the properties and constraints that you've configured match each other to potentially form an agreement.

`make test` to see if the web server is responding.

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

### Authors

* [John Walicki](https://github.com/johnwalicki)
* [Troy Fine](https://github.com/t-fine)

___

Enjoy!  Give us [feedback](https://github.com/open-horizon-services/web-helloworld-c/issues) if you have suggestions on how to improve this tutorial.
