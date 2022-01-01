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
%% -------------------------------------------------------------------
%% External exports
-export([
	 start/0,
	 print/1
	]). 


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    {ok,HostName}=net:gethostname(),
    OamNode=list_to_atom("oam@"++HostName),
  %  io:format("HostName,OamNode ~p~n",[{HostName,OamNode,?MODULE,?FUNCTION_NAME,?LINE}]),
    Result= case net_adm:ping(OamNode) of
		pang->
		    io:format("error ~p~n",[{eexists,OamNode,?MODULE,?FUNCTION_NAME,?LINE}]),
		    {error,[eexists,OamNode]};
		pong->
		    case rpc:call(OamNode,cluster,get_controllers,[],5*1000) of
			{Error,Reason}->
			    {error,[Error,Reason]};
			ControllerNodes->
			    {SdResL,_}=rpc:multicall(ControllerNodes,sd,get,[dbase_infra],5*1000),
			    case [{Error,Reason}||{Error,Reason}<-lists:append(SdResL)] of
				[]-> 
				    DbaseNodes=lists:append(SdResL), % Remove []
				    {IdsResL,_}=rpc:multicall(DbaseNodes,db_logger,ids,[],5*1000),
				    case [{Error,Reason}||{Error,Reason}<-lists:append(IdsResL)] of
					[]-> 
					    case misc:rm_duplicates(lists:append(IdsResL)) of
						[]->
						    {error,[no_ids]}; 
						Ids->
					%	    io:format("{Ids = ~p~n",[{Ids,?MODULE,?FUNCTION_NAME,?LINE}]),
						    OldNew=q_sort:sort(Ids),
						    Latest=lists:last(OldNew),
					%	    io:format("{OldNew = ~p~n",[{OldNew,?MODULE,?FUNCTION_NAME,?LINE}]),
					%	    io:format("{Latest = ~p~n",[{Latest,?MODULE,?FUNCTION_NAME,?LINE}]),
						    [DbaseNode|_]=DbaseNodes,
						    [rpc:cast(DbaseNode,db_logger,nice_print,[Id])||Id<-OldNew],
						    {ok,Latest}
					    end;
					Reason ->
					    {error,[Reason]}
				    end;
				Reason ->
				    {error,[Reason]}
			    end
		    end
	    end,
    Result.
		
print(Latest)->		
    {ok,HostName}=net:gethostname(),
    OamNode=list_to_atom("oam@"++HostName),	   
 %   io:format("HostName,OamNode ~p~n",[{HostName,OamNode,?MODULE,?FUNCTION_NAME,?LINE}]),
      Result= case net_adm:ping(OamNode) of
		pang->
		      io:format("error ~p~n",[{eexists,OamNode,?MODULE,?FUNCTION_NAME,?LINE}]),
		    {error,[eexists,OamNode]};
		pong->
		      case rpc:call(OamNode,cluster,get_controllers,[],5*1000) of
			  {Error,Reason}->
			      {error,[Error,Reason]};
			  ControllerNodes->
			      {SdResL,_}=rpc:multicall(ControllerNodes,sd,get,[dbase_infra],5*1000),
			      case [{Error,Reason}||{Error,Reason}<-lists:append(SdResL)] of
				  []-> 
				      DbaseNodes=lists:append(SdResL), % Remove []
				      {IdsResL,_}=rpc:multicall(DbaseNodes,db_logger,ids,[],5*1000),
				      case [{Error,Reason}||{Error,Reason}<-lists:append(IdsResL)] of
					  []-> 
					      case misc:rm_duplicates(lists:append(IdsResL)) of
						  []->
						      {error,[no_ids]}; 
						  Ids->
					%	      io:format("{Ids = ~p~n",[{Ids,?MODULE,?FUNCTION_NAME,?LINE}]),
						      OldNew=q_sort:sort(Ids),
						      NewLatest=lists:last(OldNew),
					%	      io:format("{OldNew = ~p~n",[{OldNew,?MODULE,?FUNCTION_NAME,?LINE}]),
					%	      io:format("{NewLatest = ~p~n",[{NewLatest,?MODULE,?FUNCTION_NAME,?LINE}]),
						      [DbaseNode|_]=DbaseNodes,
						      [rpc:cast(DbaseNode,db_logger,nice_print,[Id])||Id<-OldNew,
												      Id>Latest],
						      {ok,NewLatest}
					      end;
					  Reason ->
					      {error,[Reason]}
				      end;
				  Reason ->
				      {error,[Reason]}
			      end
		      end
	      end,
    Result.
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
