%% This is the application resource file (.app file) for the 'base'
%% application.
{application, tty,
[{description, "Tty application and cluster" },
{vsn, "1.0.0" },
{modules, 
	  [tty,tty_sup,tty_app,tty_server]},
{registered,[tty]},
{applications, [kernel,stdlib]},
{mod, {tty_app,[]}},
{start_phases, []},
{git_path,"https://github.com/joq62/tty.git"}
]}.
