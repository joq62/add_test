%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%%
%%% -------------------------------------------------------------------
-module(all).       
 
-export([start/0]).


%%
-define(CheckDelay,20).
-define(NumCheck,1000).


%% Change
-define(NodeName,"add_test").
-define(Vm,add_test@c50).
-define(AppEbinPath,"_build/default/lib/add_test/ebin").
-define(Foreground,"./_build/default/rel/add_test/bin/add_test foreground").
-define(Daemon,"./_build/default/rel/add_test/bin/add_test daemon").


%%
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    ok=test1(),
    ok=error_test(),
   
    io:format("Test OK !!! ~p~n",[?MODULE]),
    timer:sleep(2000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test1()->    
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    %% Change
    42=rpc:call(?Vm,add_test,add,[20,22],5000),
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
error_test()->    
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),


    
    %% Vm not started
    ok=stop_application(),
    {badrpc,nodedown}=rpc:call(?Vm,add_test,add,[20,22],5000),
    
    %% Application not started
    ok=start_node(),
    A=20,B=22,C=10,
    {badrpc,{'EXIT',{undef,[{add_test,add,[A,B],[]}]}}}=rpc:call(?Vm,add_test,add,[20,22],5000),

    %% M,F,A,T correct
    ok=start_application(),
    42=rpc:call(?Vm,add_test,add,[A,B],5000),
    2.0=rpc:call(?Vm,add_test,divi,[A,C],5000),
    %% M,F,A,T: F= non existing
    {badrpc,{'EXIT',{undef,[{add_test,glurk,[A,B],[]}]}}}=rpc:call(?Vm,add_test,glurk,[A,B],5000),

    
    
    %% M,F,A,T: A=wrong type of A, wrong number of A

    %% Information {error,[Event,Reason,?MODULE,?FUNCTION_NAME,?LINE,"START StackTrace ",Stacktrace,"END Stacktrace"]}
  %  {error,[error,badarith,add_test,handle_call,111,"START StackTrace ",_Stacktrace,"END Stacktrace"]}=rpc:call(?Vm,add_test,add,[A,glurk],5000),
   % {error,[error,badarith,add_test,handle_call,135,"START StackTrace ",_,"END Stacktrace"]}=rpc:call(?Vm,add_test,divi,[A,0],5000),
    {badrpc,{'EXIT',{undef,[{add_test,add,[A,B,C],[]}]}}}=rpc:call(?Vm,add_test,add,[A,B,C],5000),

     {error,Maps}=rpc:call(?Vm,add_test,divi,[A,0],5000),
   % {error,Maps}=rpc:call(?Vm,add_test,divi_safe,[A,0],5000),
     print(Maps),
    
    %% M,F;A,T: T= timeout 

     
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
  
%    rpc:call(?Vm,init,stop,[],5000),
 %   true=check_node_stopped(?Vm),
%	  []=os:cmd(?Daemon),
 %   true=check_node_started(?Vm),
   
    %% Start application to test and check node started
    {ok,HostName}=net:gethostname(),
    CookieStr=atom_to_list(erlang:get_cookie()),
    {ok,Vm}=slave:start(HostName,?NodeName,"-setcookie "++CookieStr),
    pong=net_adm:ping(Vm),

    %% Set right pathes
    AddPatha=["./test_ebin",?AppEbinPath],
    ok=rpc:call(Vm,code,add_pathsa,[AddPatha],5000),
     
    %% 4. load and start the application , at each stage check 
    
    ok=rpc:call(Vm,application,start,[log],5000),
    pong=rpc:call(Vm,log,ping,[],5000),
    ok=rpc:call(Vm,application,start,[rd],5000),
    pong=rpc:call(Vm,rd,ping,[],5000),
  

    ok=rpc:call(Vm,application,start,[add_test],5000),
    pong=rpc:call(Vm,add_test,ping,[],5000),

    ok.


%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
print([])->
    io:format("~n");
print([Map|T]) ->
    io:format("Event ~w,Reason ~w ~n",[maps:get(event,Map),maps:get(reason,Map)]),
    io:format("Stacktrace ~w ~n",[maps:get(stacktrace,Map)]),
    io:format("M ~w F ~w L ~w A ~w ~n",[maps:get(calling_module,Map),maps:get(calling_function,Map),maps:get(calling_line,Map),maps:get(calling_args,Map)]),
    
    
    print(T).
    
    
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------



start_node()->
    %% Start application to test and check node started
    {ok,HostName}=net:gethostname(),
    CookieStr=atom_to_list(erlang:get_cookie()),
    {ok,Vm}=slave:start(HostName,?NodeName,"-setcookie "++CookieStr),
    pong=net_adm:ping(Vm),
    ok.

start_application()->
    {ok,HostName}=net:gethostname(),
    Vm=list_to_atom(?NodeName++"@"++HostName),
    pong=net_adm:ping(Vm),

    %% Set right pathes
    AddPatha=["./test_ebin",?AppEbinPath],
    ok=rpc:call(Vm,code,add_pathsa,[AddPatha],5000),
     
    %% 4. load and start the application , at each stage check 
    
    ok=rpc:call(Vm,application,start,[log],5000),
    pong=rpc:call(Vm,log,ping,[],5000),
    ok=rpc:call(Vm,application,start,[rd],5000),
    pong=rpc:call(Vm,rd,ping,[],5000),
  

    ok=rpc:call(Vm,application,start,[add_test],5000),
    pong=rpc:call(Vm,add_test,ping,[],5000),
    ok.

stop_application()->   
    {ok,HostName}=net:gethostname(),
    Vm=list_to_atom(?NodeName++"@"++HostName),
    slave:stop(Vm),
    timer:sleep(1000),
    pang=net_adm:ping(Vm),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------

check_node_started(Node)->
    check_node_started(Node,?NumCheck,?CheckDelay,false).

check_node_started(_Node,_NumCheck,_CheckDelay,true)->
    true;
check_node_started(_Node,0,_CheckDelay,Boolean)->
    Boolean;
check_node_started(Node,NumCheck,CheckDelay,false)->
    case net_adm:ping(Node) of
	pong->
	    N=NumCheck,
	    Boolean=true;
	pang ->
	    timer:sleep(CheckDelay),
	    N=NumCheck-1,
	    Boolean=false
    end,
 %   io:format("NumCheck ~p~n",[{NumCheck,?MODULE,?LINE,?FUNCTION_NAME}]),
    check_node_started(Node,N,CheckDelay,Boolean).
    
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------

check_node_stopped(Node)->
    check_node_stopped(Node,?NumCheck,?CheckDelay,false).

check_node_stopped(_Node,_NumCheck,_CheckDelay,true)->
    true;
check_node_stopped(_Node,0,_CheckDelay,Boolean)->
    Boolean;
check_node_stopped(Node,NumCheck,CheckDelay,false)->
    case net_adm:ping(Node) of
	pang->
	    N=NumCheck,
	    Boolean=true;
	pong ->
	    timer:sleep(CheckDelay),
	    N=NumCheck-1,
	    Boolean=false
    end,
 %   io:format("NumCheck ~p~n",[{NumCheck,?MODULE,?LINE,?FUNCTION_NAME}]),
    check_node_stopped(Node,N,CheckDelay,Boolean).    
    
