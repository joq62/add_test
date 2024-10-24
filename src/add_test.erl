%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2023, c50
%%% @doc
%%%
%%% @endX1
%%% Created : 27 Apr 2023 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(add_test).
  
-behaviour(gen_server). 
 
-include("log.api").
-include("add_test.rd").

%% API


-export([
	 add/2,
	 add_timeout/2,
	 divi/2,
	 divi_safe/2,
	 
	 get_cwd/0,
	 ping/0
	]).

-export([
	 start/0,
	 start_link/0,
	 stop/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3, format_status/2]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
start()->
    application:start(?MODULE).
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------

add_timeout(A,B) ->
    gen_server:call(?SERVER,{add_timeout,A,B},infinity).
add(A,B) ->
    gen_server:call(?SERVER,{add,A,B},infinity).
divi(A,B) ->
    gen_server:call(?SERVER,{divi,A,B},infinity).
divi_safe(A,B) ->
    gen_server:call(?SERVER,{divi_safe,A,B},infinity).

ping() ->
    gen_server:call(?SERVER,{ping},infinity).

get_cwd() ->
    gen_server:call(?SERVER,{get_cwd},infinity).

stop() ->
    gen_server:stop(?SERVER).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%% @end
%%--------------------------------------------------------------------
-spec start_link() -> {ok, Pid :: pid()} |
	  {error, Error :: {already_started, pid()}} |
	  {error, Error :: term()} |
	  ignore.
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).




%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%% @end
%%--------------------------------------------------------------------
init([]) ->

    process_flag(trap_exit, true),

    {ok, #state{},0}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%% @end
%%--------------------------------------------------------------------
handle_call({add,A,B}, _From, State) ->
    Result=try lib_add_test:add(A,B) of
	       {ok,R}->
		   R;
	      {error,Reason}->
		   {error,["M:F [A]) with reason",lib_add_test,add,[A,B],"Reason=", Reason]}
	   catch
	       Event:Reason:Stacktrace ->
		   {error,[#{event=>Event,
			     reason=>Reason,
			     module=>?MODULE,
			     function=>?FUNCTION_NAME,
			     line=>?LINE,
			     args=>[A,B],
			     stacktrace=>[Stacktrace]}]}
	   end,
    Reply=case Result of
	       {ok,Sum}->
		  Sum;
	      ErrorEvent->
		  ErrorEvent
	  end,
    {reply, Reply, State};


handle_call({add_timeout,A,B}, _From, State) ->
    Reply =rpc:call(node(),lib_add_test,add_timeout,[A,B],100),
    {reply, Reply, State};


handle_call({divi,A,B}, _From, State) ->
    Result=try lib_add_test:divi(A,B) of
	       {ok,R}->
		   R;
	       {error,Map}->
		   glurk
		   
	   catch
	       Event:Reason:Stacktrace ->
		   case Event of
		       error->
			   {error,#{
				    event=>error,
				    reason=>Reason,
				    stacktrace=>[{?MODULE,?FUNCTION_NAME,?LINE,[A,B]}|Stacktrace]
				   }
			   };
		       _ ->
			   {error,#{
				    event=>Event,
				    reason=>Reason,
				    stacktrace=>Stacktrace,
				    calling_module=>?MODULE,
				    calling_function=>?FUNCTION_NAME,
				    calling_line=>?LINE,
				    calling_args=>[A,B]}}
		   end
	   end,
    Reply=case Result of
	       {ok,Div}->
		  Div;
	      ErrorEvent->
		  ErrorEvent
	  end,
    {reply, Reply, State};

handle_call({divi_safe,A,B}, _From, State) ->
       Result=try lib_add_test:divi_safe(A,B) of
	       {ok,R}->
		   {ok,R};
	       {error,Reason}->
		      {error,[#{event=>failed_call,
				module=>?MODULE,
				function=>?FUNCTION_NAME,
				line=>?LINE,
				args=>[A,B],
				reason=>Reason}]}
		      
	      catch
		  Event:Reason:Stacktrace ->
		      case Event of
			  error->
			      {error,#{
				       event=>error,
				       reason=>Reason,
				       stacktrace=>Stacktrace,
				       calling_module=>?MODULE,
				       calling_function=>?FUNCTION_NAME,
				       calling_line=>?LINE,
				       calling_args=>[A,B]}};
			  _ ->
			      {error,#{
				       event=>Event,
				       reason=>Reason,
				       stacktrace=>Stacktrace,
				       calling_module=>?MODULE,
				       calling_function=>?FUNCTION_NAME,
				       calling_line=>?LINE,
				       calling_args=>[A,B]}}
		      end
	      end,
    Reply=case Result of
	       {ok,Div}->
		  Div;
	      ErrorEvent->
		  ErrorEvent
	  end,
    {reply, Reply, State};


handle_call({get_cwd}, _From, State) ->
    Reply = file:get_cwd(),
    {reply, Reply, State};

handle_call({ping}, _From, State) ->
    Reply =pong,
    {reply, Reply, State};

handle_call(Request, _From, State) ->
    Reply = {error,[unmatched_signal,Request]},
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%% @end
%%--------------------------------------------------------------------
-spec handle_cast(Request :: term(), State :: term()) ->
	  {noreply, NewState :: term()} |
	  {noreply, NewState :: term(), Timeout :: timeout()} |
	  {noreply, NewState :: term(), hibernate} |
	  {stop, Reason :: term(), NewState :: term()}.
handle_cast({stop}, State) ->
    {stop,normal,ok,State};

handle_cast(_Request, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%% @end
%%--------------------------------------------------------------------
-spec handle_info(Info :: timeout() | term(), State :: term()) ->
	  {noreply, NewState :: term()} |
	  {noreply, NewState :: term(), Timeout :: timeout()} |
	  {noreply, NewState :: term(), hibernate} |
	  {stop, Reason :: normal | term(), NewState :: term()}.

handle_info(timeout, State) ->
    %% Set up logdir 
    file:make_dir(?MainLogDir),
    [NodeName,_HostName]=string:tokens(atom_to_list(node()),"@"),
    NodeNodeLogDir=filename:join(?MainLogDir,NodeName),
    ok=log:create_logger(NodeNodeLogDir,?LocalLogDir,?LogFile,?MaxNumFiles,?MaxNumBytes),


    %% 

    %% Announce to resource_discovery
    [rd:add_local_resource(ResourceType,Resource)||{ResourceType,Resource}<-?LocalResourceTuples],
    [rd:add_target_resource_type(TargetType)||TargetType<-?TargetTypes],
    rd:trade_resources(),
    timer:sleep(1000),
    ?LOG_NOTICE("Server started ",[?MODULE]),
    {noreply, State};

handle_info(Info, State) ->
    io:format("unmatched_signal ~p~n",[{Info,?MODULE,?LINE}]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%% @end
%%--------------------------------------------------------------------
-spec terminate(Reason :: normal | shutdown | {shutdown, term()} | term(),
		State :: term()) -> any().
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%% @end
%%--------------------------------------------------------------------
-spec code_change(OldVsn :: term() | {down, term()},
		  State :: term(),
		  Extra :: term()) -> {ok, NewState :: term()} |
	  {error, Reason :: term()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called for changing the form and appearance
%% of gen_server status when it is returned from sys:get_status/1,2
%% or when it appears in termination error logs.
%% @end
%%--------------------------------------------------------------------
-spec format_status(Opt :: normal | terminate,
		    Status :: list()) -> Status :: term().
format_status(_Opt, Status) ->
    Status.

%%%===================================================================
%%% Internal functions
%%%===================================================================
