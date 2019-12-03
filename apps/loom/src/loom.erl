-module(loom).
-export([node/0, bridge/0]).

node() -> whereis(http_entrypoint_node).
bridge() -> whereis(http_bridge_node).
