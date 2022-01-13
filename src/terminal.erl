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

-include("tty.hrl").
-include("log.hrl").
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
   % io:format("ping = ~p~n",[{[net_adm:ping(N)||N<-?KubeletNodes],?MODULE,?FUNCTION_NAME,?LINE}]),
    {IdsResL,BadNodes}=rpc:multicall(?KubeletNodes,log,read_all_info,[],2*1000),
    %io:format("{IdsResL,BadNodes = ~p~n",[{IdsResL,BadNodes,?MODULE,?FUNCTION_NAME,?LINE}]),
    Result=case [{Error,Reason}||{Error,Reason}<-lists:append(IdsResL)] of
	       []-> 
		   case misc:rm_duplicates(lists:append(IdsResL)) of
		       []->
			   {error,[no_ids]}; 
		       Info->
						%	    io:format("{Ids = ~p~n",[{Ids,?MODULE,?FUNCTION_NAME,?LINE}]),
			   OldNew=lists:keysort(1,Info),
		%	   io:format("{OldNew = ~p~n",[{OldNew,?MODULE,?FUNCTION_NAME,?LINE}]),
			   {Latest,_SystemTime,_Node,_Severity,_Msg,_Module,_Function,_Line,_Args,_Status}=lists:last(OldNew),
						%	    io:format("{OldNew = ~p~n",[{OldNew,?MODULE,?FUNCTION_NAME,?LINE}]),
			   io:format("{Latest = ~p~n",[{Latest,?MODULE,?FUNCTION_NAME,?LINE}]),
		%	   init:stop(),
		%	   timer:sleep(2000),
			   [nice_print_info(Info)||Info<-OldNew],
			   {ok,Latest}
		   end;
	       Reason ->
		   {error,[Reason]}
	   end,
    Result.
	
print(Latest)->		
 %   {IdsResL,_}=rpc:multicall(?KubeletNodes,log,read_all_info,[Latest],5*1000),
    {IdsResL,_}=rpc:multicall(?KubeletNodes,log,read_all_info,[],5*1000),
    Result=case [{Error,Reason}||{Error,Reason}<-lists:append(IdsResL)] of
	       []-> 
		   case misc:rm_duplicates(lists:append(IdsResL)) of
		       []->
			   {error,[no_ids]}; 
		       Info->
						%	    io:format("{Ids = ~p~n",[{Ids,?MODULE,?FUNCTION_NAME,?LINE}]),
			   OldNew=lists:keysort(1,Info),
		%	   io:format("{OldNew = ~p~n",[{OldNew,?MODULE,?FUNCTION_NAME,?LINE}]),
			   {NewLatest,_SystemTime,_Node,_Severity,_Msg,_Module,_Function,_Line,_Args,_Status}=lists:last(OldNew),
						%	    io:format("{OldNew = ~p~n",[{OldNew,?MODULE,?FUNCTION_NAME,?LINE}]),
					%	    io:format("{Latest = ~p~n",[{Latest,?MODULE,?FUNCTION_NAME,?LINE}]),
			   [nice_print_info(Info)||Info<-OldNew],
			   {ok,NewLatest}
		   end;
	       Reason ->
		   {error,[Reason]}
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
nice_print_info(Info)->
    {Id,SystemTime,Node,Severity,Msg,Module,Function,Line,Args,_Status}=Info,
    Time=calendar:system_time_to_rfc3339(SystemTime,                
					 [{unit, ?SystemTime}, {time_designator, $\s}, {offset, "Z"}]),
    
    Node1=atom_to_list(Node),
    Severity1=" "++Severity,
    Module1=atom_to_list(Module),
    Function1=atom_to_list(Function),
    Line1=integer_to_list(Line),
						%Status1=atom_to_list(Status),
    Msg1=" "++Msg,
    MF=" "++Module1++":"++Function1,
    
	  %  io:format("MF ~p~n",[{Id,?MODULE,?FUNCTION_NAME,?LINE}]),	    
    io:format("~s ~s ~s ~s",[Time,Severity1,Msg1,MF]),
    io:format(" ["),
    nice_print(Args),
    io:format("] "),
    io:format("Line=~s Node=~s",[Line1,Node1]),
    io:format("~n"),
    ok.

nice_print([])->
    ok;
nice_print([Arg|T]) ->
    io:format("~p",[Arg]),
    case T of
	[]->
	    ok;
	_ ->
	    io:format(",")
    end,
    print(T).
