-module(controller).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
    Salt = integer_to_binary(rand:uniform(16#ffffff), 16),
    {ok, CWD} = file:get_cwd(),
    Root = filename:join(CWD, io_lib:format("root-~s", [Salt])),
    error_logger:info_report([{root, Root}]),
    ok = filelib:ensure_dir(Root),
    initialize_ar_meta_db(Root),
    initialize_ar_storage(),
    initialize_randomx(),
    {ok, {}}.

handle_call(_Msg, _From, State) -> {noreply, State}.
handle_cast(_Msg, State) -> {noreply, State}.

initialize_ar_storage() ->
    ok = ar_storage:start().

initialize_ar_meta_db(Root) ->
    _Pid = ar_meta_db:start(),
    ar_meta_db:put(transaction_blacklist_files, []),
    ar_meta_db:put(content_policy_files, []),
    ar_meta_db:put(data_dir, filename:join(Root, "data")).

initialize_randomx() ->
    _Pid = ar_randomx_state:start().
