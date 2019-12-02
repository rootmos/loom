-module(monitor).
-behaviour(gen_server).

-export([start_link/0, next_block/0]).
-export([init/1, handle_call/3, handle_cast/2]).
-export([new_transaction/1, confirmed_transaction/1, new_block/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

next_block() -> gen_server:call(?MODULE, block).

init(_Args) ->
    Pid = adt_simple:start(?MODULE, []),
    Node = whereis(http_entrypoint_node),
    ar_node:add_peers(Node, Pid),
    link(Pid),
    {ok, #{node => Node, block_requesters => []}}.

handle_call(block, From, #{block_requesters := BRs} = State) ->
    {noreply, State#{block_requesters => [From | BRs] }};
handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast({block, Block}, #{block_requesters := BRs} = State) ->
    ok = lists:foreach(fun(BR) -> gen_server:reply(BR, Block) end, BRs),
    {noreply, State#{block_requesters => [] }};
handle_cast({tx, _TX}, #{node := Node} = State) ->
    ar_node:mine(Node),
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

new_transaction(TX) -> gen_server:cast(?MODULE, {tx, TX}).
confirmed_transaction(_TX) -> ok.
new_block(Block) -> gen_server:cast(?MODULE, {block, Block}).
