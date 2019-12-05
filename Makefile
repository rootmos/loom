REBAR ?= ./rebar3

run:
	_build/default/rel/loom/bin/loom foreground

release: | $(REBAR)
	$(REBAR) release

$(REBAR):
	wget -O"$@" https://s3.amazonaws.com/rebar3/rebar3
	chmod +x "$@"

test:
	$(MAKE) --keep-going -C tests wait test stop

clean:
	rm -rf _build

DOCKER ?= docker
DOCKER_COMPOSE ?= docker-compose
DOCKER_REPO ?= rootmos/loom
ifneq ($(wildcard .git),)
export DOCKER_IMAGE ?= $(DOCKER_REPO):$(shell git rev-parse HEAD | head -c7)
else
export DOCKER_IMAGE ?= $(DOCKER_REPO):latest
endif

test-compose:
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up --detach --force-recreate loom
	$(DOCKER_COMPOSE) run tests

publish:
	$(DOCKER) push $(DOCKER_IMAGE)
ifeq ($(TRAVIS_BRANCH),master)
	$(DOCKER) tag $(DOCKER_IMAGE) $(DOCKER_REPO):latest
	$(DOCKER) push $(DOCKER_REPO):latest
endif

.PHONY: run release clean test
.PHONY: test-compose publish
