-module(bridge_sup).
-behaviour(supervisor).

-export([start_link/1, init/1]).

start_link(Port) ->
    {ok, Sup} = supervisor:start_link(?MODULE, [Port]),
    Node = whereis(http_entrypoint_node),
    {ok, Pid} = supervisor:start_child(Sup,
        #{id => bridge,
          start => {ar_bridge, start_link, [[[], [Node], Port]]},
          restart => permanent,
          shutdown => 5000
         }
    ),
    erlang:register(http_bridge_node, Pid),
    {ok, Sup}.

init(_Args) ->
    {ok, {#{strategy => one_for_one, intensity => 1, period => 5}, []}}.
