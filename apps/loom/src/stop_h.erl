-module(stop_h).

-export([init/2]).

init(Req0=#{method := <<"POST">>}, Opts) ->
    Req = cowboy_req:reply(202, Req0),
    Pid = spawn(fun() -> receive _ -> erlang:halt() end end),
    erlang:send_after(200, Pid, {}),
    {ok, Req, Opts};
init(Req, Opts) ->
    {ok, cowboy_req:reply(405, Req), Opts}.
