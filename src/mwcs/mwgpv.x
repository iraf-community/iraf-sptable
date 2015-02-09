# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	"mwcs.h"

# MW_GPV -- Get the PV coefficients for an axis.

procedure mw_gpv (mw, axis, pv, npts)

pointer	mw			#I pointer to MWCS descriptor
int	axis			#I axis which gets the wsamp vector
double	pv[ARB]			#O PV coefficients
int	npts			#I number of coefficients

pointer	wp
errchk	syserrs
string	s_name "mw_gpv"

begin
	# Get the current WCS.
	wp = MI_WCS(mw)
	if (wp == NULL)
	    call syserrs (SYS_MWNOWCS, s_name)

	# Verify that there are PV coefficients for this WCS.
	if (WCS_NPVC(wp,axis) <= 0 || WCS_PVC(wp,axis) == NULL)
	    call syserrs (SYS_MWNOWSAMP, s_name)

	# Copy out the coefficients.
	call amovd (D(mw,WCS_PVC(wp,axis)), pv, min(WCS_NPVC(wp,axis), npts))
end
