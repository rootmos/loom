-module(arweave_prv_compile).

-export([init/1, do/1, format_error/1]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
            {name, compile},
            {namespace, arweave},
            {module, ?MODULE},
            {bare, true},
            {deps, [{arweave, install_deps}]},
            {example, "rebar3 arweave compile"},
            {opts, []},
            {short_desc, "Compile Arweave source"},
            {desc, "Compile Arweave source"}
    ]),
    State1 = rebar_state:add_provider(State, Provider),
    {ok, State1}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    App0 = rebar_state:get(State, arweave_app),
    AppDir = rebar_app_info:dir(App0),
    rebar_api:info("Compiling arweave (~s)", [rebar_app_info:original_vsn(App0)]),
    rebar_utils:sh("make compile_prod build_arweave",
                   [{cd, AppDir}, abort_on_error, use_stdout]),
    {ok, State}.

-spec format_error(any()) ->  iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).
