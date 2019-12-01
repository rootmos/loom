-module(loom).
-export([node/0]).

node() -> whereis(http_entrypoint_node).
