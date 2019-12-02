-module(faucets).
-behaviour(gen_server).

-export([start_link/1]).
-export([list/0, new/1, send/2]).
-export([init/1, handle_call/3, handle_cast/2]).
-export([confirmed_transaction_callback/2]).

-include_lib("arweave/src/ar.hrl").

start_link(Faucets) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Faucets, []).

init(Faucets) -> {ok, Faucets}.

list() -> gen_server:call(?MODULE, list).
send(Beneficiary, Quantity) ->
    gen_server:call(?MODULE, {send, Beneficiary, Quantity}).

handle_call(list, _From, Faucets) ->
    As = [ A || #{address := A} <- Faucets],
    {reply, As, Faucets};
handle_call({send, Beneficiary, Quantity}, From, Faucets) ->
    #{private_key := Priv, public_key := Pub, address := A} = choose(Faucets),
    Reward = ar_tx:calculate_min_tx_cost(
               0,
               ar_node:get_current_diff(loom:node()),
               ar_node:get_height(loom:node()),
               ar_node:get_wallet_list(loom:node()),
               Beneficiary,
               erlang:timestamp()
              ),
    {ok, LastTx} = ar_node:get_last_tx(loom:node(), A),
    TX = ar_tx:new(Beneficiary, Reward, Quantity, LastTx),
    STX = ar_tx:sign(TX, Priv, Pub),
    ok = monitor:wait_for_tx(STX#tx.id, ?MODULE, From),
    ok = ar_node:add_tx(loom:node(), STX),
    {noreply, Faucets};
handle_call(_Msg, _From, State) -> {noreply, State}.

confirmed_transaction_callback(TX, From) ->
    gen_server:reply(From, TX#tx.id).

handle_cast(_Msg, State) -> {noreply, State}.

new(I) ->
    {Priv, Pub} = ar_wallet:new(),
    #{name => io_lib:format("faucet-~p", [I]),
      private_key => Priv,
      public_key => Pub,
      address => ar_wallet:to_address(Pub)}.

choose(Fs) ->
    case lists:sort([ {rand:uniform(), F} || F <- Fs ]) of
        [{_, F} | _] -> F
    end.
