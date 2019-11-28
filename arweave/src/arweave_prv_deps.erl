-module(arweave_prv_deps).

-export([init/1, do/1, format_error/1]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
            {name, install_deps},
            {namespace, arweave},
            {module, ?MODULE},
            {bare, true},
            {deps, []},
            {example, "rebar3 arweave get-deps"},
            {opts, []},
            {short_desc, "Fetch Arweave source"},
            {desc, "Fetch Arweave source"}
    ]),
    State1 = rebar_state:add_provider(State, Provider),
    {ok, State1}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    App = rebar_state:get(State, arweave_app),
    rebar_api:info("Fetching arweave (from ~p)", [rebar_app_info:source(App)]),
    Dir = rebar_app_info:dir(App),
    case (not filelib:is_dir(Dir))
        orelse rebar_resource_v2:needs_update(App, State) of
        true -> fetch(Dir, State, App);
        false -> {ok, State}
    end.

fetch(Dir, State, App) ->
    case rebar_resource_v2:download(Dir, App, State) of
        ok -> case rebar_utils:sh("make gitmodules", [{cd, Dir}, use_stdout]) of
                  {ok, _Output} -> write_app_file(App), {ok, State};
                  {error, Reason} -> {error, format_error(Reason)}
              end;
        {error, Reason} -> {error, format_error(Reason)}
    end.

write_app_file(App) ->
    AppFile = [{application, arweave,
                [{vsn, rebar_app_info:original_vsn(App)},
                 {description, "Arweave"},
                 {applications, [kernel, stdlib]}
                ]}],
    ok = file:write_file(rebar_app_info:app_file_src(App),
                         io_lib:format("~p.~n", AppFile)).

-spec format_error(any()) ->  iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).
