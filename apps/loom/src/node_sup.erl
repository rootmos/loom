-module(node_sup).
-behaviour(supervisor).

-export([start_link/1, init/1]).

-include_lib("arweave/src/ar.hrl").

start_link(Faucets) -> supervisor:start_link(node_sup, Faucets).

init(Faucets) ->
    DataDir = ar_meta_db:get(data_dir),
    ok = filelib:ensure_dir(filename:join(DataDir, "genesis_txs")),
    Diff = 1,
    GenesisWallets = [ {A, 1000*?WINSTON_PER_AR, <<>>} ||
                       #{address := A} <- Faucets ],
    NodeArgs = [[], ar_weave:init(GenesisWallets, Diff), 0, unclaimed, false,
               Diff, os:system_time(seconds)],
    SupFlags = #{strategy => one_for_one, intensity => 1, period => 5},
    ChildSpecs = [#{id => ar_node,
                    start => {ar_node, start_link, [NodeArgs]},
                    restart => permanent,
                    shutdown => brutal_kill,
                    type => worker}],
    {ok, {SupFlags, ChildSpecs}}.
