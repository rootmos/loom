-module(loom_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile(
        [{'_', [{"/loom/ping", ping_h, []},
                {"/loom/stop", stop_h, []},
                {"/loom/mine", mine_h, []},
                {"/loom/faucet", faucet_h, []},
                {"/arweave/[...]", arweave_h, []}]}]),
    Port = list_to_integer(os:getenv("PORT", "8000")),
    {ok, _} = cowboy:start_clear(http, [{port, Port}],
                                 #{env => #{dispatch => Dispatch}}),
    Faucets = [ faucets:new(I) || I <- lists:seq(1, 10)],
    loom_sup:start_link(#{port => Port, faucets => Faucets}).

stop(_State) ->
    ok = cowboy:stop_listener(http).
