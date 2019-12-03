-module(bridge_sup).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2]).

start_link(Args) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Args], []).

init(Port) ->
    Pid = ar_bridge:start([], [loom:node()], Port),
    ar_node:add_peers(loom:node(), Pid),
    erlang:register(http_bridge_node, Pid),
    error_logger:info_report([{bridge, Pid}]),
    {ok, {}}.

handle_call(_Msg, _From, State) -> {noreply, State}.
handle_cast(_Msg, State) -> {noreply, State}.
