%%%-------------------------------------------------------------------
%% @doc template_application public API
%% @end
%%%-------------------------------------------------------------------

-module(add_test_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    add_test_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
