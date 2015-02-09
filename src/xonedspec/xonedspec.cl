#{ Package script task for the XONEDSPEC package.

# Define necessary paths

package xonedspec

task	autoidentify,
	calibrate,
	continuum,
	deredden,
	dispcor,
	disptrans,
	dopcor,
	fitprofs,
	identify,
	lcalib,
	mkspec,
	names,
	refspectra,
	reidentify,
	rstext,
	sapertures,
	sarith,
	sbands,
	odcombine,
	scoords,
	sensfunc,
	sfit,
	sflip,
	sinterp,
	skytweak,
	slist,
	specplot,
	specshift,
	splot,
	standard,
	telluric	= xonedspec$x_xonedspec.e

task	scombine	= "xonedspec$scombine/x_xscombine.e"

task	setairmass,
	setjd		= astutil$x_astutil.e

# Scripts and Psets

task	aidpars		= xonedspec$aidpars.par
task	bplot		= xonedspec$bplot.cl
task	ndprep		= xonedspec$ndprep.cl
task	scopy		= xonedspec$scopy.cl
task	rspectext	= xonedspec$rspectext.cl
task	wspectext	= xonedspec$wspectext.cl

task	$process	= process.cl			# Used by BATCHRED
task	dispcor1	= xonedspec$dispcor1.par	# Used by DISPCOR
hidetask dispcor1,process,rstext

task	wspectable	= xonedspec$wspectable.cl
task	wtabhdr		= xonedspec$wtabhdr.cl
hidetask wtabhdr

clbye
