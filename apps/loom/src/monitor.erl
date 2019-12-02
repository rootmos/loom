-module(monitor).
-behaviour(gen_server).

-export([start_link/0, next_block/0, wait_for_tx/3]).
-export([init/1, handle_call/3, handle_cast/2]).
-export([new_transaction/1, confirmed_transaction/1, new_block/1]).

-include_lib("arweave/src/ar.hrl").

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

next_block() -> gen_server:call(?MODULE, block).
wait_for_tx(TxId, Mod, AppData) ->
    gen_server:call(?MODULE, {tx_id, TxId, Mod, AppData}).

init(_Args) ->
    Pid = adt_simple:start(?MODULE, []),
    Node = loom:node(),
    ar_node:add_peers(Node, Pid),
    link(Pid),
    {ok, #{node => Node, block_requesters => [], tx_requesters => #{}}}.

handle_call(block, From, #{block_requesters := BRs} = State) ->
    {noreply, State#{block_requesters => [From | BRs] }};
handle_call({tx_id, TxId, Mod, AppData}, _From, #{tx_requesters := M} = State) ->
    {reply, ok,
     State#{tx_requesters =>
            maps:update_with(TxId,
                             fun(TXRs) -> [{Mod, AppData} | TXRs] end,
                             [{Mod, AppData}],
                             M)}};
handle_call(Msg, _From, State) ->
    {noreply, State}.

handle_cast({block, Block}, #{block_requesters := BRs} = State) ->
    ok = lists:foreach(fun(BR) -> gen_server:reply(BR, Block) end, BRs),
    {noreply, State#{block_requesters => [] }};
handle_cast({tx, _TX}, #{node := Node} = State) ->
    ar_node:mine(Node),
    {noreply, State};
handle_cast({confirmed_tx, TX}, #{tx_requesters := TXRs} = State) ->
    ok = lists:foreach(fun({Mod, AppData}) ->
                               erlang:apply(Mod,
                                            confirmed_transaction_callback,
                                            [TX, AppData])
                       end,
                       maps:get(TX#tx.id, TXRs, [])),
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

new_transaction(TX) -> gen_server:cast(?MODULE, {tx, TX}).
confirmed_transaction(TX) -> gen_server:cast(?MODULE, {confirmed_tx, TX}).
new_block(Block) -> gen_server:cast(?MODULE, {block, Block}).
