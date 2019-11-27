REBAR ?= ./rebar3

release: | $(REBAR)
	$(REBAR) release

$(REBAR):
	wget -O"$@" https://s3.amazonaws.com/rebar3/rebar3
	chmod +x "$@"

clean:
	rm -rf _build

.PHONY: release clean
