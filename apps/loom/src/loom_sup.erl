-module(loom_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all, intensity => 0, period => 1},
    ChildSpecs = [
        #{id => controller,
          start => {controller, start_link, []},
          restart => permanent,
          shutdown => 5000
         },
        #{id => bridge,
          start => {ar_bridge, start_link, [[[], [], 9000]]},
          restart => permanent,
          shutdown => 5000
         }
    ],
    {ok, {SupFlags, ChildSpecs}}.
