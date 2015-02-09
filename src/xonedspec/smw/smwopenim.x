include <imhdr.h>
include	<imio.h>
include	<mwset.h>
include	<smw.h>

define	SYSTEMS	"|equispec|multispec|physical|image|world|linear|"


# SMW_OPENIM -- Open the spectral MWCS for various input formats.

pointer procedure smw_openim (im)

pointer	im		#I Image pointer
pointer	mw		#O MWCS pointer

pointer	sp, system, s_mwopens()
bool	streq()
int	wcsdim, sys, strdic(), mw_stati()
errchk	s_mwopens, smw_oldms, smw_linear

begin
	call smark (sp)
	call salloc (system, SZ_FNAME, TY_CHAR)

#call eprintf ("smw_openim: call s_mwopens\n")
	mw = s_mwopens (im, 1)
	call mw_seti (mw, MW_USEAXMAP, NO)
	wcsdim = mw_stati (mw, MW_NDIM)
#call eprintf ("smw_openim: call mw_gwattrs\n")
	call mw_gwattrs (mw, 0, "sformat", Memc[system], SZ_FNAME)
	sys = strdic (Memc[system], Memc[system], SZ_FNAME, SYSTEMS)
#call eprintf ("smw_openim: sformat = %s\n")
#call pargstr (Memc[system])

	# Set various input systems.
	switch (sys) {
	case 1:
#call eprintf ("smw_openim: 20\n")
	    call s_setwcs (mw, 1)
	    call smw_equispec (im, mw)
	case 2:
#call eprintf ("smw_openim: 30\n")
	    call s_setwcs (mw, 1)
	    call smw_multispec (im, mw)
	default:
#call eprintf ("smw_openim: 40\n")
	    if (sys == 0) {
	        call eprintf (
	    "WARNING: Unknown coordinate system `%s' - assuming `linear'.\n")
		    call pargstr (Memc[system])
	    } else if (sys == 3)
		call mw_newsystem (mw, "image", wcsdim)

	    # Old "multispec" format.
	    ifnoerr (call s_gstr (im, "APFORMAT", Memc[system], SZ_FNAME)) {
#call eprintf ("smw_openim: 50\n")
		call s_setwcs (mw, 1)
		if (streq (Memc[system], "onedspec"))
		    call smw_onedspec (im, mw)
		else
		    call smw_oldms (im, mw)

	    # Old "onedspec" format or other 1D image.
	    } else if (wcsdim == 1) {
#call eprintf ("smw_openim: 60\n")
		call s_setwcs (mw, 1)
		call smw_onedspec (im, mw)

	    # N-dimensional image.
	    } else {
#call eprintf ("smw_openim: 70\n")
		call smw_nd (im, mw)
}
	}

#call eprintf ("smw_openim: SMW_DTYPE = %d\n")
#call pargi (SMW_DTYPE(mw))
	call sfree (sp)
	return (mw)
end
