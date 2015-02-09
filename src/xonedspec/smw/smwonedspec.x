include <imhdr.h>
include	<smw.h>


# SMW_ONEDSPEC -- Convert old "onedspec" format to EQUISPEC.

procedure smw_onedspec (im, smw)

pointer	im			#I IMIO pointer
pointer	smw			#U MWCS pointer input SMW pointer output

int	i, dtype, ap, beam, nw, s_geti(), s_ofnl(), s_gnfn()
real	aplow[2], aphigh[2], s_getr(), mw_c1tranr()
double	ltm, ltv, r, w, dw, z, s_getd()
pointer	sp, key, mw, ct, s_mwopens(), mw_sctran()
bool	fp_equald()
errchk	smw_open, mw_gwtermd, mw_sctran

begin
#call eprintf ("smw_onedspec\n")
	call smark (sp)
	call salloc (key, SZ_FNAME, TY_CHAR)

	# Convert old W0/WPC keywords if needed.
	mw = smw
	iferr (w = s_getd (im, "CRVAL1")) {
	    ifnoerr (w = s_getd (im, "W0")) {
		dw = s_getd (im, "WPC")
		iferr (ltm = s_getd (im, "LTM1_1"))
		    ltm = 1
		iferr (ltv = s_getd (im, "LTV1"))
		    ltv = 0
		r = ltm + ltv
		dw = dw / ltm
		call s_addd (im, "CRPIX1", r)
		call s_addd (im, "CRVAL1", w)
		call s_addd (im, "CD1_1", dw)
		call s_addd (im, "CDELT1", dw)
		call mw_close(mw)
		mw = s_mwopens (im, 1)
	    }
	}

	# Get dispersion and determine number of valid pixels.
	call mw_gwtermd (mw, r, w, dw, 1)
	w = w - (r - 1) * dw
	r = 1
	call mw_swtermd (mw, r, w, dw, 1)
	ct = mw_sctran (mw, "logical", "physical", 1)
	nw = max (mw_c1tranr (ct, 1.), mw_c1tranr (ct, real (S_NDISP(im))))
	call mw_ctfree (ct)

	iferr (dtype = s_geti (im, "DC-FLAG")) {
	    if (fp_equald (1D0, w) || fp_equald (1D0, dw))
		dtype = DCNO
	    else
		dtype = DCLINEAR
	}
	if (dtype==DCLOG) {
	    if (abs(w)>20. || abs(w+(nw-1)*dw)>20.)
		dtype = DCLINEAR
	    else {
		w = 10D0 ** w
		dw = w * (10D0 ** ((nw-1)*dw) - 1) / (nw - 1)
	    }
	}

	# Convert to EQUISPEC system.
	call mw_swattrs (mw, 0, "sformat", "equispec")
	if (dtype != DCNO) {
	    iferr (call mw_gwattrs (mw, 1, "label", Memc[key], SZ_FNAME)) {
		iferr (call mw_gwattrs (mw, 1, "units", Memc[key], SZ_FNAME)) {
		    call mw_swattrs (mw, 1, "units", "angstroms")
		    call mw_swattrs (mw, 1, "label", "Wavelength")
		}
	    }
	}

	# Set the SMW data structure.
	call smw_open (smw, NULL, im)

	# Determine the aperture parameters.
	iferr (beam = s_geti (im, "BEAM-NUM"))
	    beam = 1
	iferr (ap = s_geti (im, "APNUM"))
	    ap = beam
	iferr (aplow[1] = s_getr (im, "APLOW"))
	    aplow[1] = INDEF
	iferr (aphigh[1] = s_getr (im, "APHIGH"))
	    aphigh[1] = INDEF
	iferr (z = s_getd (im, "DOPCOR"))
	    z = 0.

	call smw_swattrs (smw, 1, 1, ap, beam, dtype, w, dw, nw, z,
	    aplow, aphigh, "")

        # Delete old parameters
        i = s_ofnl (im,
            "BEAM-NUM,APNUM,APLOW,APHIGH,DOPCOR,DC-FLAG,W0,WPC,NP1,NP2", NO)
        while (s_gnfn (im, i, Memc[key], SZ_FNAME) != EOF) {
            iferr (call s_delf (im, Memc[key]))
		;
	}
	call s_cfnl (im, i)

        # Update MWCS
        call smw_saveim (smw, im)

	call sfree (sp)
end
