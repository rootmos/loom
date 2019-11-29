-module(loom_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    initialize_ar_meta_db(),
    initialize_ar_storage(),
    SupFlags = #{strategy => one_for_all, intensity => 0, period => 1},
    ChildSpecs = [#{id => bridge,
                    start => {ar_bridge, start_link, [[[], [], 9000]]},
                    restart => permanent,
                    shutdown => 5000
                   }],
    {ok, {SupFlags, ChildSpecs}}.

initialize_ar_storage() ->
    ar_storage:start().

initialize_ar_meta_db() ->
	ar_meta_db:start(),
	ar_meta_db:put(transaction_blacklist_files, []),
	ar_meta_db:put(content_policy_files, []),
	ar_meta_db:put(data_dir, "data").
