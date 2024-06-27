# A simple "Hello, world." web server container

DOCKER_HUB_ID ?= adhishreekadam
NAME:=web-hello-c
VERSION:=1.0.0
PORT:=8000


default: build run

build:
	docker build --platform linux/amd64 -t $(DOCKER_HUB_ID)/$(NAME):$(VERSION) .

dev: build stop
	docker run -d --name $(NAME) -p $(PORT):$(PORT) $(DOCKER_HUB_ID)/$(NAME):$(VERSION)
	docker logs -f $(NAME)

run: stop
	docker run -d --name $(NAME) -p $(PORT):$(PORT) $(DOCKER_HUB_ID)/$(NAME):$(VERSION)

test:
	curl -sS localhost:$(PORT)/

push:
	docker push $(DOCKER_HUB_ID)/$(NAME):$(VERSION)

stop:
	-docker rm -f $(NAME) 2>/dev/null || :

clean: stop
	-docker rmi $(DOCKER_HUB_ID)/$(NAME):$(VERSION) 2>/dev/null || :

publish-service:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        SERVICE_CONTAINER="$(DOCKER_HUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)" \
        hzn exchange service publish -O $(CONTAINER_CREDS) -f service.json --pull-image

publish-pattern:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        PATTERN_NAME="$(PATTERN_NAME)" \
	hzn exchange pattern publish -f pattern.json

register-pattern:
	@hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	@hzn unregister -f

.PHONY: all build dev run test push stop clean publish-service publish-pattern register-pattern agent-stop
