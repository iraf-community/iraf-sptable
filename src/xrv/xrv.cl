#{ XRV -- Radial Velocity Analysis Package

# Define the package
package		xrv

# Executables
task	fxcor,
	rvidlines,
	rvreidlines	= "xrv$x_xrv.e"

task	rvcorrect	= "astutil$x_astutil.e"

# PSET Tasks
task	filtpars	= "xrv$filtpars.par"
task	continpars 	= "xrv$continpars.par"
task	keywpars	= "xrv$keywpars.par"

# Hidden tasks
task	rvdebug	= 	"xrv$rvdebug.par"
    hidetask ("rvdebug")

keep
clbye()
