-module(mine_h).

-export([init/2]).

init(Req0=#{method := <<"POST">>}, Opts) ->
    ar_node:mine(whereis(http_entrypoint_node)),
    Block = monitor:next_block(),
    Body = ar_serialize:jsonify(ar_serialize:block_to_json_struct(Block)),
    {ok, cowboy_req:reply(200, #{
      <<"content-type">> => <<"text/json; charset=utf-8">>
     }, Body, Req0), Opts};
init(Req, Opts) ->
    {ok, cowboy_req:reply(405, Req), Opts}.
