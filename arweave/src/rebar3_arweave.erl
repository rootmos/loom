-module(rebar3_arweave).

-export([init/1]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State0) ->
    Dir = filename:join([rebar_dir:base_dir(State0), "lib", "arweave"]),
    RepoOwner = "ArweaveTeam",
    Repo = "arweave",

    RepoURL = io_lib:format("https://api.github.com/repos/~s/~s",
                            [RepoOwner, Repo]),
    {ok, {{"HTTP/1.1", 200, "OK"}, _HD0, Body0}} =
        httpc:request(get, {RepoURL, [{"User-Agent", "rebar3_arweave"}]},
                      [], []),
    #{ <<"clone_url">> := CloneURL,
       <<"releases_url">> := ReleasesURLTemplate
     } = jiffy:decode(Body0, [return_maps]),

    ReleasesURL = string:replace(ReleasesURLTemplate, "{/id}", "/latest"),
    {ok, {{"HTTP/1.1", 200, "OK"}, _HD1, Body1}} =
        httpc:request(get, {ReleasesURL, [{"User-Agent", "rebar3_arweave"}]},
                      [], []),
    #{ <<"tag_name">> := LatestVersion } = jiffy:decode(Body1, [return_maps]),

    Version = case rebar_state:get(State0, arweave, none) of
                  none -> LatestVersion;
                  ArweaveOpts ->
                      proplists:get_value(version, ArweaveOpts, LatestVersion)
              end,
    if Version /= LatestVersion ->
       rebar_api:warn("Arweave out-of-date: configured=~s latest=~s",
                      [Version, LatestVersion]);
       true -> ok
    end,

    {ok, App0} = rebar_app_info:new(arweave, Version, Dir),
    AppFileSrc = filename:join(Dir, "arweave.app.src"),
    App1 = rebar_app_info:app_file_src(App0, AppFileSrc),
    App2 = rebar_app_info:set(App1, src_dirs, ["_src"]),
    App = rebar_app_info:source(App2, {git, CloneURL, {tag, Version}}),

    State1 = rebar_state:set(State0, arweave_app, App),
    State2 = rebar_state:project_apps(State1, App),

    {ok, State3} = arweave_prv_deps:init(State2),
    {ok, State4} = arweave_prv_compile:init(State3),
    {ok, State4}.
