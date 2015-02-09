# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	"mwcs.h"

# MW_SPV -- Set the PV coefficients for an axis.

procedure mw_spv (mw, axis, pv, npv)

pointer	mw			#I pointer to MWCS descriptor
int	axis			#I axis which gets the wsamp vector
double	pv[ARB]			#I PV coefficients
int	npv			#I number of coefficients

pointer	wp
int	mw_allocd()
errchk	syserrs, mw_allocd

begin
	# Get the current WCS.
	wp = MI_WCS(mw)
	if (wp == NULL)
	    call syserrs (SYS_MWNOWCS, "mw_spv")

	# Overwrite the current curve, if any, else allocate new storage.
	if (WCS_PVC(wp,axis) == NULL || WCS_NPVC(wp,axis) < npv)
	    WCS_PVC(wp,axis) = mw_allocd (mw, npv)
	call amovd (pv, D(mw,WCS_PVC(wp,axis)), npv)

	WCS_NPVC(wp,axis) = npv
end
