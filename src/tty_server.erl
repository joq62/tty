%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(tty_server). 

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("tty.hrl").
%% --------------------------------------------------------------------
-define(PollInterval,5*1000).

%% External exports



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {status,
		latest
	       }).

%% ====================================================================
%% External functions
%% ====================================================================

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
  
    
    spawn(fun()-> do_poll() end),
    {ok, #state{status=oam_not_started,
	       latest=na}
    }.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({print}, State) ->
    NewState=case State#state.status of
		 oam_not_started->
		     case rpc:call(node(),terminal,start,[],10*1000) of
			 {ok,Latest}->
			     State#state{status=started,latest=Latest};
			 {error,Reason}->
			     io:format("~p~n",[{error,Reason,?MODULE,?FUNCTION_NAME,?LINE}]),
			     State
		     end;
		 started->
		     case rpc:call(node(),terminal,print,[State#state.latest],5*1000) of
			 {ok,Latest}->
			     State#state{status=started,latest=Latest};
			 {Error,Reason}->
			     io:format("~p~n",[{Error,Reason,?MODULE,?FUNCTION_NAME,?LINE}]),
			     State
		     end
	     end,
  %  io:format("NewState ~p~n",[{NewState,?MODULE,?FUNCTION_NAME,?LINE}]),
    spawn(fun()-> do_poll() end),
    {noreply, NewState};

  

handle_cast({restart}, State) ->
    [rpc:call(N,os,cmd,["reboot"],1000)||N<-?KubeletNodes],
    timer:sleep(1000),
    {noreply, State};
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,?LINE,time()}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
do_poll()->
    timer:sleep(?PollInterval),
    rpc:cast(node(),tty,print,[]).
		  
