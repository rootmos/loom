-module(node_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() -> supervisor:start_link(node_sup, []).

init(_Args) ->
    DataDir = ar_meta_db:get(data_dir),
    ok = filelib:ensure_dir(filename:join(DataDir, "genesis_txs")),
    Diff = 1,
    NodeArgs = [[], ar_weave:init([], Diff), 0, unclaimed, false,
               Diff, os:system_time(seconds)],
    SupFlags = #{strategy => one_for_one, intensity => 1, period => 5},
    ChildSpecs = [#{id => ar_node,
                    start => {ar_node, start_link, [NodeArgs]},
                    restart => permanent,
                    shutdown => brutal_kill,
                    type => worker}],
    {ok, {SupFlags, ChildSpecs}}.
