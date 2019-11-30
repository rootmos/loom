-module(mine_h).

-export([init/2]).

init(Req0=#{method := <<"POST">>}, Opts) ->
    Req = cowboy_req:reply(202, Req0),
    ar_node:mine(whereis(http_entrypoint_node)),
    {ok, Req, Opts};
init(Req, Opts) ->
    {ok, cowboy_req:reply(405, Req), Opts}.

