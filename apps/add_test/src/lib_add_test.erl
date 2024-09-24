%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2024, c50
%%% @doc
%%%
%%% @end
%%% Created : 23 Sep 2024 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(lib_add_test).

%% API
-export([
	 add/2,
	 divi/2,
	 divi_safe/2
	]).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
add(A,B)->
    {ok,A+B}.

add_timeout(A,B)->
    timer:sleep(200),
  {ok,A+B}.
divi(A,B)->
    case rpc:call(node(),lib2,divi,[A,B],5000) of
	{ok,R}->
	    {ok,R};
	Error ->
	   io:format("Error ~p~n",[Error]),
	    init:stop(),
	    timer:sleep(3000),
	    {error,#{
		     event=>Error,
		     reason=>glurk,
		     stacktrace=>glurk,
		     calling_module=>?MODULE,
		     calling_function=>?FUNCTION_NAME,
		     calling_line=>?LINE,
		     calling_args=>[A,B]}}
    end.
		
divi_safe(A,0)->
    {error,[#{event=>badarith,
	      reason=>'division with zero',
	      module=>?MODULE,
	      function=>?FUNCTION_NAME,
	      args=>[A,0],
	      line=>?LINE}
	   ]};
divi_safe(A,B) ->
    divi(A,B).
%%%===================================================================
%%% Internal functions
%%%===================================================================
