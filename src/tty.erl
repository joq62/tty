%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
-module(tty). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(SERVER,tty_server).
%% --------------------------------------------------------------------
-export([
	 print/0,
	 ping/0
	 
        ]).

-export([
	 boot/0,
	 start/0,
	 stop/0
	]).



%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals
boot()->
    ok=application:start(tty).
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).




%%---------------------------------------------------------------
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
print()-> 
    gen_server:cast(?SERVER, {print}).


ping()-> 
    gen_server:call(?SERVER, {ping},infinity).


%%----------------------------------------------------------------------
