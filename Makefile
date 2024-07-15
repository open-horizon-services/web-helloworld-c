# A simple "Hello, world." web server container

DOCKER_HUB_ID ?= ibmosquito
NAME:=web-hello-c
VERSION:=1.0.0
PORT:=8000

export SERVICE_NAME ?= web-hello-c
PATTERN_NAME ?= pattern-web-helloworld-c
DEPLOYMENT_POLICY_NAME ?= deployment-policy-web-helloworld-c
NODE_POLICY_NAME ?= node-policy-web-helloworld-c
export SERVICE_VERSION ?= 1.0.0
export SERVICE_CONTAINER := $(DOCKER_HUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)
ARCH ?= amd64

# Detect Operating System running Make
OS := $(shell uname -s)

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS ?=

default: build run
	
build:
	docker build -t $(SERVICE_CONTAINER) .

dev: stop build
	docker run -it -v `pwd`:/outside \
          --name ${SERVICE_NAME} \
          -p 8000:8000 \
          $(SERVICE_CONTAINER) /bin/bash

publish: publish-service publish-service-policy publish-deployment-policy

remove: remove-deployment-policy remove-service-policy remove-service

publish-service:
	@echo "=================="
	@echo "PUBLISHING SERVICE"
	@echo "=================="
	@hzn exchange service publish -O $(CONTAINER_CREDS) --json-file=service.json --pull-image
	@echo ""

remove-service:
	@echo "=================="
	@echo "REMOVING SERVICE"
	@echo "=================="
	@hzn exchange service remove -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-service-policy:
	@echo "========================="
	@echo "PUBLISHING SERVICE POLICY"
	@echo "========================="
	@hzn exchange service addpolicy -f service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

remove-service-policy:
	@echo "======================="
	@echo "REMOVING SERVICE POLICY"
	@echo "======================="
	@hzn exchange service removepolicy -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""


publish-pattern:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        PATTERN_NAME="$(PATTERN_NAME)" \
	hzn exchange pattern publish -f pattern.json

publish-deployment-policy:
	@echo "============================"
	@echo "PUBLISHING DEPLOYMENT POLICY"
	@echo "============================"
	@hzn exchange deployment addpolicy -f deployment.policy.json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

remove-deployment-policy:
	@echo "=========================="
	@echo "REMOVING DEPLOYMENT POLICY"
	@echo "=========================="
	@hzn exchange deployment removepolicy -f $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""


agent-run:
	@echo "================"
	@echo "REGISTERING NODE"
	@echo "================"
	@hzn register --policy=node.policy.json
	@watch hzn agreement list

agent-run-pattern:
	@hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

run: stop
	docker run -d \
        --name ${SERVICE_NAME} \
        --restart unless-stopped \
        -p 8000:8000 \
        $(SERVICE_CONTAINER)
test:
	curl -sS localhost:$(PORT)/

push:
	docker push $(DOCKER_HUB_ID)/$(NAME):$(VERSION)

stop:
	@docker rm -f $(NAME) >/dev/null 2>&1 || :

clean: stop
	-docker rmi $(DOCKER_HUB_ID)/$(NAME):$(VERSION) 2>/dev/null || :

register-pattern:
	@hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	@hzn unregister -f

check:
	@echo "=================="
	@echo "SERVICE DEFINITION"
	@echo "=================="
	@cat service.json | envsubst
	@echo ""

deploy-check:
	@hzn deploycheck all -t device -B deployment.policy.json --service=service.json --service-pol=service.policy.json --node-pol=node.policy.json

log:
	@echo "========="
	@echo "EVENT LOG"
	@echo "========="
	@hzn eventlog list
	@echo ""
	@echo "==========="
	@echo "SERVICE LOG"
	@echo "==========="
	@hzn service log -f $(SERVICE_NAME)

.PHONY: default build dev publish remove publish-service remove-service publish-service-policy remove-service-policy publish-pattern publish-deployment-policy remove-deployment-policy agent-run agent-run-pattern run test push stop clean register-pattern agent-stop
