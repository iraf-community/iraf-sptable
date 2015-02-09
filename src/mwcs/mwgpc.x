# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	"mwcs.h"

# MW_GPC -- Get PC coefficients for an axis.

procedure mw_gpc (mw, axis, pc, npts)

pointer	mw			#I pointer to MWCS descriptor
int	axis			#I axis which gets the wsamp vector
double	pc[ARB]			#O PC coefficients
int	npts			#I number of coefficients

pointer	wp
errchk	syserrs
string	s_name "mw_gpc"

begin
	# Get the current WCS.
	wp = MI_WCS(mw)
	if (wp == NULL)
	    call syserrs (SYS_MWNOWCS, s_name)

	# Verify that there are PC coefficients for this WCS.
	if (WCS_NPC(wp,axis) <= 0 || WCS_PC(wp,axis) == NULL)
	    call syserrs (SYS_MWNOWSAMP, s_name)

	# Copy out the coefficients.
	call amovd (D(mw,WCS_PC(wp,axis)), pc, min(WCS_NPC(wp,axis), npts))
end
