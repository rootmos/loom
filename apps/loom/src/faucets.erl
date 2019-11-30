-module(faucets).
-behaviour(gen_server).

-export([start_link/1]).
-export([list/0, new/1]).
-export([init/1, handle_call/3, handle_cast/2]).

start_link(Faucets) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Faucets, []).

init(Faucets) -> {ok, Faucets}.

list() -> gen_server:call(?MODULE, list).

handle_call(list, _From, Faucets) ->
    As = [ A || #{address := A} <- Faucets],
    {reply, As, Faucets};
handle_call(_Msg, _From, State) -> {noreply, State}.

handle_cast(_Msg, State) -> {noreply, State}.

new(I) ->
    {{Priv, _}, Pub} = ar_wallet:new(),
    #{name => io_lib:format("faucet-~p", [I]),
      private_key => Priv,
      public_key => Pub,
      address => ar_wallet:to_address(Pub)}.
