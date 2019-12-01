-module(faucet_h).

-export([init/2]).

init(Req0=#{method := <<"GET">>}, Opts) ->
    Body = ar_serialize:jsonify([ar_util:encode(A) || A <- faucets:list()]),
    Req = cowboy_req:reply(200, #{
      <<"content-type">> => <<"text/json; charset=utf-8">>
     }, Body, Req0),
    {ok, Req, Opts};
init(Req0=#{method := <<"POST">>}, Opts) ->
    {ok, RawBody, Req1} = cowboy_req:read_body(Req0),
    {ok, #{<<"beneficiary">> := B, <<"quantity">> := Q}} =
        ar_serialize:json_decode(RawBody, [return_maps]),
    TxId = faucets:send(ar_util:decode(B), Q),
    Body = ar_serialize:jsonify(#{tx_id => ar_util:encode(TxId)}),
    Req = cowboy_req:reply(200, #{
      <<"content-type">> => <<"text/json; charset=utf-8">>
     }, Body, Req1),
    {ok, Req, Opts};
init(Req, Opts) ->
    {ok, cowboy_req:reply(405, Req), Opts}.
