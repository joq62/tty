%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(terminal).    
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include("controller.hrl").
-include("logger_infra.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([
	 start/1,
	 print/2
	]). 


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start(ControllerNode)->
    Result=case rpc:call(ControllerNode,sd,get,[dbase_infra],5*1000) of
	       {badrpc,Reason}->
		   io:format("{error = ~p~n",[{badrpc,Reason,?MODULE,?FUNCTION_NAME,?LINE}]),
		   timer:sleep(3000),
		   start(ControllerNode);
	       []->
		   io:format("{error = ~p~n",[{error,[],?MODULE,?FUNCTION_NAME,?LINE}]),
		   timer:sleep(3000),
		   start(ControllerNode);
	       [DbaseNode|_]->
		   case rpc:call(DbaseNode,db_logger,ids,[],3000) of
		       {badrpc,Reason}->
			   io:format("{error = ~p~n",[{badrpc,Reason,?MODULE,?FUNCTION_NAME,?LINE}]),
			   timer:sleep(3000),
			   start(ControllerNode);
		       []->
			   io:format("{No Ids = ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
			   timer:sleep(3000),
			   start(ControllerNode);
		       Ids->
			   OldNew=q_sort:sort(Ids),
			   Latest=lists:last(OldNew),
			   [{Id,rpc:cast(DbaseNode,db_logger,nice_print,[Id])}||Id<-OldNew],
			   Pid=spawn(fun()->print(ControllerNode,Latest) end),
			   {ok,Pid}
		   end
	   end,   
    Result.

print(ControllerNode,Latest)->
    NewLatest=case rpc:call(ControllerNode,sd,get,[dbase_infra],5*1000) of
		  {badrpc,Reason}->
		      io:format("{error = ~p~n",[{badrpc,Reason,?MODULE,?FUNCTION_NAME,?LINE}]),
		      Latest;
		  []->
		      io:format("{error, = ~p~n",[{error,[],?MODULE,?FUNCTION_NAME,?LINE}]),
		      Latest;
		  [DbaseNode|_]->
		      case rpc:call(DbaseNode,db_logger,ids,[],3000) of
			  {badrpc,Reason}->
			      io:format("{error = ~p~n",[{badrpc,Reason,?MODULE,?FUNCTION_NAME,?LINE}]),
			      Latest;
			  []->
			      io:format("{No Ids = ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
			      Latest;
			  Ids->
			      OldNew=q_sort:sort(Ids),
			      XLatest=lists:last(OldNew),
			      [rpc:cast(DbaseNode,db_logger,nice_print,[Id])||Id<-OldNew,
									   Id>Latest],
			      XLatest
		      end
	      end,   
    receive
	exit->
	    ok
    after 2000->
	    print(ControllerNode,NewLatest)
    end.

		     
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
