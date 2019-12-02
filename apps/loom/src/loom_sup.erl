-module(loom_sup).

-behaviour(supervisor).

-export([start_link/1, init/1]).

start_link(Config) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, Config).

init(#{port := Port, faucets := Faucets}) ->
    SupFlags = #{strategy => one_for_all, intensity => 0, period => 1},
    ChildSpecs = [
        #{id => controller,
          start => {controller, start_link, []},
          restart => permanent,
          shutdown => 5000
         },
        #{id => faucets,
          start => {faucets, start_link, [Faucets]},
          restart => permanent,
          shutdown => 5000
         },
        #{id => bridge_sup,
          start => {bridge_sup, start_link, [Port]},
          restart => permanent,
          shutdown => 5000
         },
        #{id => node_sup,
          start => {node_sup, start_link, [Faucets]},
          restart => permanent,
          shutdown => 5000,
          type => supervisor
         },
        #{id => monitor,
          start => {monitor, start_link, []},
          restart => permanent,
          shutdown => 5000,
          type => worker
         }
    ],
    {ok, {SupFlags, ChildSpecs}}.
