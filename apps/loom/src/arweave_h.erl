-module(arweave_h).

-export([init/2]).

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Rsp = case ar_http_iface_server:split_path(cowboy_req:path(Req0)) of
        [<<"arweave">> | SplitPath] ->
            Req1 = Req0#{path => SplitPath},
            {ok, RawBody, Req2} = cowboy_req:read_body(Req1),
            Req3 = ar_http_body_middleware:with_body_req_field(Req2, RawBody),
            case ar_http_iface_middleware:handle(Method, SplitPath, Req3) of
                {Status, Hdrs, Body, HandledReq} ->
                    cowboy_req:reply(Status, Hdrs, Body, HandledReq);
                {Status, Body, HandledReq} ->
                    cowboy_req:reply(Status, #{}, Body, HandledReq)
            end
    end,
    {ok, Rsp, Opts}.

