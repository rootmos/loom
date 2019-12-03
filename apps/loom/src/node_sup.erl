-module(node_sup).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2]).

-include_lib("arweave/src/ar.hrl").

start_link(Args) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Args, []).

init(Faucets) ->
    DataDir = ar_meta_db:get(data_dir),
    ok = filelib:ensure_dir(filename:join(DataDir, "genesis_txs")),
    Diff = 1,
    GenesisWallets = [ {A, 1000*?WINSTON_PER_AR, <<>>} ||
                       #{address := A} <- Faucets ],
    [GenesisBlock] = ar_weave:init(GenesisWallets, Diff),
    ar_storage:write_block(GenesisBlock),
    BHL = [GenesisBlock#block.indep_hash | GenesisBlock#block.hash_list],
    NodeConfig = #{ peers => [],
                    block_hash_list => BHL,
                    mining_delay => 0,
                    reward_address => unclaimed,
                    auto_join => false,
                    diff => Diff,
                    last_retarget => os:system_time(seconds),
                    transaction_delay => no_delay
                  },
    {ok, Pid} = ar_node:start_with_config(NodeConfig),
    error_logger:info_report([{node, Pid}]),
    {ok, {}}.

handle_call(_Msg, _From, State) -> {noreply, State}.
handle_cast(_Msg, State) -> {noreply, State}.
