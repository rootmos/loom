-module(arweave_h).

-export([init/2]).

init(Req, Opts) ->
    Method = cowboy_req:method(Req),
    case ar_http_iface_server:split_path(cowboy_req:path(Req)) of
        [<<"arweave">> | SplitPath] ->
            case ar_http_iface_middleware:handle(Method, SplitPath, Req) of
                {Status, Hdrs, Body, HandledReq} ->
                    cowboy_req:reply(Status, Hdrs, Body, HandledReq);
		        {Status, Body, HandledReq} ->
                    cowboy_req:reply(Status, #{}, Body, HandledReq)
            end
    end.
