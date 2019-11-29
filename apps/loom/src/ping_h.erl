-module(ping_h).

-export([init/2]).

init(Req0=#{method := <<"GET">>}, Opts) ->
    Req = cowboy_req:reply(200, #{
      <<"content-type">> => <<"text/json; charset=utf-8">>
     }, <<"\"pong\"">>, Req0),
    {ok, Req, Opts};
init(Req, Opts) ->
    {ok, cowboy_req:reply(405, Req), Opts}.
