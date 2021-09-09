# A simple "Hello, world." web server container

DOCKERHUB_ID:=ibmosquito
NAME:=web-hello-c
VERSION:=1.0.0
PORT:=8000

all: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(NAME):$(VERSION) .

dev: build stop
	docker run -it --name $(NAME) -p $(PORT):$(PORT) --volume `pwd`:/outside $(DOCKERHUB_ID)/$(NAME):$(VERSION) /bin/bash

run: stop
	docker run -d --name $(NAME) -p $(PORT):$(PORT) $(DOCKERHUB_ID)/$(NAME):$(VERSION)

test:
	curl -sS localhost:$(PORT)/

exec:
	docker exec -it $(NAME) /bin/bash

push:
	docker push $(DOCKERHUB_ID)/$(NAME):$(VERSION)

stop:
	-docker rm -f $(NAME) 2>/dev/null || :

clean: stop
	-docker rmi $(DOCKERHUB_ID)/$(NAME):$(VERSION) 2>/dev/null || :

.PHONY: all build dev run test exec push stop clean
