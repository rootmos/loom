-module(wait_h).

-export([init/2]).

init(Req0=#{method := <<"GET">>, bindings := #{tx_id := RawTxId}}, Opts) ->
    TxId = ar_util:decode(RawTxId),
    case monitor:wait_for_tx(TxId) of
        {tx_filename, Fn} ->
            Req = cowboy_req:reply(200, #{
              <<"content-type">> => <<"text/json; charset=utf-8">>
             }, {sendfile, 0, filelib:file_size(Fn), Fn}, Req0),
            {ok, Req, Opts};
        {tx, TX} ->
            Body = ar_serialize:jsonify(ar_serialize:tx_to_json_struct(TX)),
            cowboy_req:reply(200, #{
              <<"content-type">> => <<"text/json; charset=utf-8">>
             }, Body, Req0)
    end;
init(Req=#{method := <<"GET">>}, Opts) ->
    {ok, cowboy_req:reply(400, Req), Opts};
init(Req, Opts) ->
    {ok, cowboy_req:reply(405, Req), Opts}.
