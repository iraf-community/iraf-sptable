include	<mwset.h>

define	AXTYPES	"|wave|freq|velo|vrad|vopt|zopt|"
define	WTYPES	"|wav|frq|vel|log|"
define	SKYTYPES "|tan|tnx|"

define	WAVE	1
define	FREQ	2
define	VELO	3
define	VRAD	4
define	VOPT	5
define	ZOPT	6
define	LOG	4


# S_SETWCS -- Reset WCS parameters to a standard format.
# The purpose of this routine is to run a set of heuristics to
# set the WCS parameters to a standard format.

procedure s_setwcs (mw, axis)

pointer	mw				#I MWCS pointer
int	axis				#I Dispersion axis

int	i, j, iaxtype, iwtype
pointer	sp, axtype, wtype, ctype, label, units, str, cd, r, w

bool	streq()
int	strdic(), strlen(), mw_stati()
errchk	mw_swtype, mw_swattrs, mw_swtermd

begin
	call smark (sp)
	call salloc (axtype, SZ_FNAME, TY_CHAR)
	call salloc (wtype, SZ_FNAME, TY_CHAR)
	call salloc (ctype, SZ_FNAME, TY_CHAR)
	call salloc (label, SZ_FNAME, TY_CHAR)
	call salloc (units, SZ_FNAME, TY_CHAR)
	call salloc (str, SZ_FNAME, TY_CHAR)

#call eprintf ("s_setwcs: A\n")
	# First check if MWCS has already set CTYPE.
	iferr (call mw_gwattrs (mw, axis, "axtype", Memc[axtype], SZ_FNAME))
	    Memc[axtype] = EOS
	call strlwr (Memc[axtype])
	iaxtype = strdic (Memc[axtype], Memc[str], SZ_FNAME, AXTYPES)
	if (iaxtype > 0 && !streq (Memc[str], Memc[axtype]))
	    iaxtype = 0
	iferr (call mw_gwattrs (mw, axis, "wtype", Memc[wtype], SZ_FNAME))
	    call strcpy ("linear", Memc[wtype], SZ_FNAME)
	iwtype = strdic (Memc[wtype], Memc[str], SZ_FNAME, WTYPES)
	if (iwtype > 0 && !streq (Memc[str], Memc[wtype]))
	    iwtype = 0

#call eprintf ("s_setwcs: B\n")
	# MWCS puts CTYPE in the "label" attribute if it does not recognize it.
	iferr (call mw_gwattrs (mw, axis, "label", Memc[label], SZ_FNAME))
	    Memc[label] = EOS
	if (iaxtype == 0 || iwtype == 0) {
#call eprintf ("s_setwcs: C\n")
	    call strcpy (Memc[label], Memc[ctype], SZ_FNAME)
	    call strlwr (Memc[ctype])
	    if (streq (Memc[ctype], "lambda")) {
#call eprintf ("s_setwcs: D\n")
		call strcpy ("wave-wav", Memc[ctype], SZ_FNAME)
	    } else if (streq (Memc[ctype], "freq")) {
#call eprintf ("s_setwcs: E\n")
		call strcpy ("freq-frq", Memc[ctype], SZ_FNAME)
	    } else if (streq (Memc[ctype], "velo")) {
#call eprintf ("s_setwcs: F\n")
		call strcpy ("velo-vel", Memc[ctype], SZ_FNAME)
	    } else if (streq (Memc[ctype], "waveleng")) {
#call eprintf ("s_setwcs: G\n")
		call strcpy ("wave-wav", Memc[ctype], SZ_FNAME)
	    } else if (strdic (Memc[wtype],Memc[wtype],SZ_FNAME,SKYTYPES) > 0) {
#call eprintf ("s_setwcs: H\n")
		i = mw_stati (mw, MW_NPHYSDIM)
		call salloc (cd, i*i+2*i, TY_DOUBLE)
		r = cd + i * i
		w = r + i
		call aclrd (Memd[cd], i*i+2*i)
		do j = 1, i {
		    Memd[cd+(j-1)*(i+1)] = 1
		    call mw_swtype (mw, j, 1, "linear", "")
		    call mw_swattrs (mw, j, "axtype", "")
		}
		call mw_swtermd (mw, Memd[r], Memd[w], Memd[cd], i)
	    } else if (streq (Memc[wtype], "linear")) {
#call eprintf ("s_setwcs: I\n")
		# Last ditch effort: IRAF default
		i = mw_stati (mw, MW_NPHYSDIM)
		call salloc (cd, i*i+2*i, TY_DOUBLE)
		r = cd + i * i
		w = r + i
		call mw_gwtermd (mw, Memd[r], Memd[w], Memd[cd], i)
		if (Memd[cd+(axis-1)*(i+1)] != 1) {
		    call strcpy ("wave-wav", Memc[ctype], SZ_FNAME)
		    iferr (call mw_gwattrs (mw, axis, "units", Memc[units],
			SZ_FNAME))
			Memc[units] = EOS
		    if (Memc[units] == EOS)
			call mw_swattrs (mw, axis, "units", "Angstrom")
		}
	    }

	    if (strlen (Memc[ctype]) == 8 && Memc[ctype+4] == '-') {
#call eprintf ("s_setwcs: J\n")
		call strcpy (Memc[ctype], Memc[axtype], 4)
		iaxtype = strdic (Memc[axtype], Memc[str], SZ_FNAME, AXTYPES)
		if (iaxtype > 0 && !streq (Memc[str], Memc[axtype]))
		    iaxtype = 0
		call strcpy (Memc[ctype+5], Memc[wtype], 3)
		iwtype = strdic (Memc[wtype], Memc[str], SZ_FNAME, WTYPES)
		if (iwtype > 0 && !streq (Memc[str], Memc[wtype]))
		    iwtype = 0
	    }

	    if (iaxtype > 0 && iwtype > 0) {
#call eprintf ("s_setwcs: K\n")
		#call mw_swtype (mw, axis, 1, Memc[wtype], "")
		#call mw_swattrs (mw, axis, "axtype", Memc[axtype])
		Memc[label] = EOS
	    }
	}

	# Set label.
	if (Memc[label] == EOS) {
	    switch (iaxtype) {
	    case WAVE:
#call eprintf ("s_setwcs: L\n")
		call mw_swattrs (mw, axis, "label", "Wavelength")
	    case FREQ:
#call eprintf ("s_setwcs: M\n")
		call mw_swattrs (mw, axis, "label", "Frequency")
	    case VELO, VRAD, VOPT:
#call eprintf ("s_setwcs: N\n")
		call mw_swattrs (mw, axis, "label", "Velocity")
	    case ZOPT:
#call eprintf ("s_setwcs: O\n")
		call mw_swattrs (mw, axis, "label", "Redshift")
	    }
	}

	# Set units.
	iferr (call mw_gwattrs (mw, axis, "units", Memc[units], SZ_FNAME))
	    Memc[units] = EOS
	if (Memc[units] == EOS) {
	    switch (iaxtype) {
	    case WAVE:
#call eprintf ("s_setwcs: P\n")
		#call mw_swattrs (mw, axis, "units", "m")
		call mw_swattrs (mw, axis, "units", "Angstrom")
	    case FREQ:
#call eprintf ("s_setwcs: Q\n")
		call mw_swattrs (mw, axis, "units", "Hz")
	    case VELO, VRAD, VOPT:
#call eprintf ("s_setwcs: R\n")
		call mw_swattrs (mw, axis, "units", "m /s")
	    case ZOPT:
#call eprintf ("s_setwcs: S\n")
		call mw_swattrs (mw, axis, "units", "")
	    default:
#call eprintf ("s_setwcs: T\n")
		call mw_swattrs (mw, axis, "units", "pixel")
	    }
	}

#call eprintf ("s_setwcs: U\n")
	call sfree (sp)
end
