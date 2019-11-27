-module(loom_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all, intensity => 0, period => 1},
    ChildSpecs = [],
    {ok, {SupFlags, ChildSpecs}}.
