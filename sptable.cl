#{ SPTABLE -- Tasks for working with spectral table formats.

# For now force only old templates.
reset use_new_imt = no

cl < "sptable$lib/zzsetenv.def"
package	sptable, bin = spbin$

set	xonedspec	= "sptable$src/xonedspec/"
task	xonedspec.pkg	= "xonedspec$xonedspec.cl"

set	xrv		= "sptable$src/xrv/"
task	xrv.pkg		= "xrv$xrv.cl"

clbye()
