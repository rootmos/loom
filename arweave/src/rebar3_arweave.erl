-module(rebar3_arweave).

-export([init/1]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State0) ->
    Dir = filename:join([rebar_dir:base_dir(State0), "lib", "arweave"]),
    Version = "N.1.9.0.0",
    RepoURL = "https://github.com/ArweaveTeam/arweave",
    {ok, App0} = rebar_app_info:new(arweave, Version, Dir),
    AppFileSrc = filename:join(Dir, "arweave.app.src"),
    App1 = rebar_app_info:app_file_src(App0, AppFileSrc),
    App2 = rebar_app_info:set(App1, src_dirs, ["_src"]),
    App = rebar_app_info:source(App2, {git, RepoURL, {tag, Version}}),

    State1 = rebar_state:set(State0, arweave_app, App),
    State2 = rebar_state:project_apps(State1, App),

    {ok, State3} = arweave_prv_compile:init(State2),
    {ok, State4} = arweave_prv_deps:init(State3),
    {ok, State4}.
