REBAR ?= ./rebar3

run:
	_build/default/rel/loom/bin/loom foreground

release: | $(REBAR)
	$(REBAR) arweave compile
	$(REBAR) release

$(REBAR):
	wget -O"$@" https://s3.amazonaws.com/rebar3/rebar3
	chmod +x "$@"

clean:
	rm -rf _build

DOCKER ?= docker
DOCKER_COMPOSE ?= docker-compose
export DOCKER_IMAGE ?= rootmos/loom:$(shell git rev-parse HEAD | head -c7)

test-compose:
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up --detach --force-recreate loom
	$(DOCKER_COMPOSE) run tests

publish:
	$(DOCKER) push $(DOCKER_IMAGE)

.PHONY: run release clean
.PHONY: test-compose publish
