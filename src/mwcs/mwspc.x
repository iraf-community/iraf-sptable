# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	"mwcs.h"

# MW_SPC -- Set PC coefficients for an axis.

procedure mw_spc (mw, axis, pc, npc)

pointer	mw			#I pointer to MWCS descriptor
int	axis			#I axis which gets the wsamp vector
double	pc[ARB]			#I PC coefficients
int	npc			#I number of coefficients

pointer	wp
int	mw_allocd()
errchk	syserrs, mw_allocd

begin
	# Get the current WCS.
	wp = MI_WCS(mw)
	if (wp == NULL)
	    call syserrs (SYS_MWNOWCS, "mw_spc")

	# Overwrite the current curve, if any, else allocate new storage.
	if (WCS_PC(wp,axis) == NULL || WCS_NPC(wp,axis) < npc)
	    WCS_PC(wp,axis) = mw_allocd (mw, npc)
	call amovd (pc, D(mw,WCS_PC(wp,axis)), npc)

	WCS_NPC(wp,axis) = npc
end
