REBAR ?= ./rebar3

run: release
	_build/default/rel/loom/bin/loom foreground

release: | $(REBAR)
	$(REBAR) release

$(REBAR):
	wget -O"$@" https://s3.amazonaws.com/rebar3/rebar3
	chmod +x "$@"

clean:
	rm -rf _build

.PHONY: release clean
