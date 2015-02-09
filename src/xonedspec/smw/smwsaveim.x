include <imhdr.h>
include	<imio.h>
include	<smw.h>


# SMW_SAVEIM -- Save spectral WCS in image header.
# The input and output formats are EQUISPEC and MULTISPEC.  A split input
# MULTISPEC WCS is first merged to a single EQUISPEC or MULTISPEC WCS.
# An input MULTISPEC WCS is converted to EQUISPEC output if possible.

procedure smw_saveim (smw, im)

pointer	smw			# SMW pointer
pointer	im			# Image pointer

int	i, j, format, nl, pdim, pdim1, beam, dtype, dtype1, nw, nw1
int	ap, axes[3]
real	aplow[2], aphigh[2]
double	v, m, w1, dw, z, w11, dw1, z1
pointer	sp, key, str1, str2, axmap, lterm, coeff, mw, mw1

bool	strne(), fp_equald()
int	s_accf(), s_geti()
pointer	mw_open()
errchk	smw_merge, s_delf
data	axes/1,2,3/

begin
#call eprintf ("smw_saveim\n")
	call smark (sp)
	call salloc (key, SZ_FNAME, TY_CHAR)
	call salloc (str1, SZ_LINE, TY_CHAR)
	call salloc (str2, SZ_LINE, TY_CHAR)
	call salloc (axmap, 6, TY_INT)
	call salloc (lterm, 15, TY_DOUBLE)
	coeff = NULL

	# Merge split WCS into a single WCS.
	call smw_merge (smw)

	mw = SMW_MW(smw,0)
	pdim = SMW_PDIM(smw)
	format = SMW_FORMAT(smw)
	if (S_NDIM(im) == 1)
	    nl = 1
	else
	    nl = S_NSPEC(im)

	# If writing to an existing image we must follow S_PDIM
	# but in a NEW_COPY header we may really want a lower dimension.

	pdim1 = max (S_NDIM(im), S_PDIM(im))
	ifnoerr (i = s_geti (im, "SMW_NDIM")) {
	    pdim1 = i
	    call s_delf (im, "SMW_NDIM")
	}

	# Check if MULTISPEC WCS can be converted to EQUISPEC.
	if (format == SMW_MS) {
	    format = SMW_ES
	    do i = 1, nl {
		call smw_gwattrs (smw, i, 1, ap, beam, dtype, w1, dw, nw, z,
		    aplow, aphigh, coeff)
		if (i == 1) {
		    dtype1 = dtype
		    w11 = w1
		    dw1 = dw
		    z1 = z
		    nw1 = nw
		}
		if (dtype>1||dtype!=dtype1||!fp_equald(w1,w11)||
		    !fp_equald(dw,dw1)||nw!=nw1||!fp_equald(z,z1)) {
		    format = SMW_MS
		    break
		}
	    }
	}

	# Save WCS in desired format.
	switch (format) {
	case SMW_ND:
	    if (SMW_DTYPE(smw) != -1)
		call s_addi (im, "DC-FLAG", SMW_DTYPE(smw))
	    else if (s_accf (im, "DC-FLAG") == YES)
		call s_delf (im, "DC-FLAG")
	    if (s_accf (im, "DISPAXIS") == YES)
		call s_addi (im, "DISPAXIS", SMW_PAXIS(smw,1))

	    call smw_gapid (smw, 1, 1, S_TITLE(im), SZ_IMTITLE)
	    call s_mwsaves (mw, im)

	case SMW_ES:
	    # Save aperture information.
#call eprintf ("smw_saveim: nl=%d\n")
#call pargi (nl)
	    do i = 1, nl {
		call smw_gwattrs (smw, i, 1, ap, beam, dtype, w1, dw, nw, z,
		    aplow, aphigh, coeff)
#call eprintf ("smw_saveim: %.4g %.4g %d %.4g\n")
#call pargd (w1)
#call pargd (dw)
#call pargi (nw)
#call pargd (z)
		if (i < 1000)
		    call sprintf (Memc[key], SZ_FNAME, "APNUM%d")
		else
		    call sprintf (Memc[key], SZ_FNAME, "AP%d")
		    call pargi (i)
		call sprintf (Memc[str1], SZ_LINE, "%d %d")
		    call pargi (ap)
		    call pargi (beam)
		if (!IS_INDEF(aplow[1]) || !IS_INDEF(aphigh[1])) {
		    call sprintf (Memc[str2], SZ_LINE, " %.2f %.2f")
			call pargr (aplow[1])
			call pargr (aphigh[1])
		    call strcat (Memc[str2], Memc[str1], SZ_LINE)
		    if (!IS_INDEF(aplow[2]) || !IS_INDEF(aphigh[2])) {
			call sprintf (Memc[str2], SZ_LINE, " %.2f %.2f")
			    call pargr (aplow[2])
			    call pargr (aphigh[2])
			call strcat (Memc[str2], Memc[str1], SZ_LINE)
		    }
		}
		call s_astr (im, Memc[key], Memc[str1])
		if (i == 1) {
		    iferr (call s_delf (im, "APID1"))
			;
		}
		call smw_gapid (smw, i, 1, Memc[str1], SZ_LINE)
		if (Memc[str1] != EOS) {
		    if (strne (Memc[str1], S_TITLE(im))) {
			if (nl == 1) {
			    call s_astr (im, "MSTITLE", S_TITLE(im))
			    call strcpy (Memc[str1], S_TITLE(im), SZ_IMTITLE)
			} else {
			    call sprintf (Memc[key], SZ_FNAME, "APID%d")
				call pargi (i)
			    call s_astr (im, Memc[key], Memc[str1])
			}
		    }
		}
	    }

	    # Delete unnecessary aperture information.
	    do i = nl+1, ARB {
		if (i < 1000)
		    call sprintf (Memc[key], SZ_FNAME, "APNUM%d")
		else
		    call sprintf (Memc[key], SZ_FNAME, "AP%d")
		    call pargi (i)
		iferr (call s_delf (im, Memc[key]))
		    break
		call sprintf (Memc[key], SZ_FNAME, "APID%d")
		    call pargi (i)
		iferr (call s_delf (im, Memc[key]))
		    ;
	    }

	    # Add dispersion parameters to image.
#call eprintf ("smw_saveim: dtype = %d\n")
#call pargi (dtype)
	    if (dtype != -1)
		call s_addi (im, "DC-FLAG", dtype)
	    else if (s_accf (im, "DC-FLAG") == YES)
		call s_delf (im, "DC-FLAG")
	    if (nw < S_NDISP(im))
		call s_addi (im, "NP2", nw)
	    else if (s_accf (im, "NP2") == YES)
		call s_delf (im, "NP2")

	    # Setup EQUISPEC WCS.

	    mw1 = mw_open (NULL, pdim1)
	    call mw_newsystem (mw1, "equispec", pdim1)
	    call mw_swtype (mw1, axes, pdim1, "linear", "")
	    ifnoerr (call mw_gwattrs (mw, 1, "label", Memc[str1], SZ_LINE))
		call mw_swattrs (mw1, 1, "label", Memc[str1])
	    ifnoerr (call mw_gwattrs (mw, 1, "units", Memc[str1], SZ_LINE))
		call mw_swattrs (mw1, 1, "units", Memc[str1])
	    ifnoerr (call mw_gwattrs (mw, 1, "units_display", Memc[str1],
		SZ_LINE))
		call mw_swattrs (mw1, 1, "units_display", Memc[str1])
	    call mw_gltermd (mw, Memd[lterm+pdim], Memd[lterm], pdim)
	    v = Memd[lterm]
	    m = Memd[lterm+pdim]
	    call mw_gltermd (mw1, Memd[lterm+pdim1], Memd[lterm], pdim1)
	    Memd[lterm] = v
	    Memd[lterm+pdim1] = m
	    call mw_sltermd (mw1, Memd[lterm+pdim1], Memd[lterm], pdim1)
	    call mw_gwtermd (mw1, Memd[lterm], Memd[lterm+pdim1],
		Memd[lterm+2*pdim1], pdim1)
	    Memd[lterm] = 1.
	    w1 = w1 / (1 + z)
	    dw = dw / (1 + z)
	    if (dtype == DCLOG) {
		dw = log10 ((w1 + (nw - 1) * dw) / w1) / (nw - 1)
		w1 = log10 (w1)
	    }
	    Memd[lterm+pdim1] = w1
	    Memd[lterm+2*pdim1] = dw
#call eprintf ("smw_saveim: %.4g %.4g %.4g %d\n")
#call pargd (Memd[lterm])
#call pargd (Memd[lterm+pdim1])
#call pargd (Memd[lterm+2*pdim1])
#call pargi (pdim)
	    call mw_swtermd (mw1, Memd[lterm], Memd[lterm+pdim1],
		Memd[lterm+2*pdim1], pdim1)
#call eprintf ("smw_saveim: 10\n")
	    call s_mwsaves (mw1, im)
	    call mw_close (mw1)

	case SMW_MS:
	    # Delete any APNUM keywords.  If there is only one spectrum
	    # define the axis mapping.

	    do j = 1, ARB {
		if (j < 1000)
		    call sprintf (Memc[key], SZ_FNAME, "APNUM%d")
		else
		    call sprintf (Memc[key], SZ_FNAME, "AP%d")
		    call pargi (j)
		iferr (call s_delf (im, Memc[key]))
		    break
	    }
	    if (S_NDIM(im) == 1) {
		call aclri (Memi[axmap], 2*pdim)
		Memi[axmap] = 1
		call mw_saxmap (mw, Memi[axmap], Memi[axmap+pdim], pdim)
	    }

	    # Set aperture ids.
	    do i = 1, nl {
		if (i == 1) {
		    iferr (call s_delf (im, "APID1"))
			;
		}
		call smw_gapid (smw, i, 1, Memc[str1], SZ_LINE)
		if (Memc[str1] != EOS) {
		    if (strne (Memc[str1], S_TITLE(im))) {
			if (nl == 1) {
			    call s_astr (im, "MSTITLE", S_TITLE(im))
			    call strcpy (Memc[str1], S_TITLE(im), SZ_IMTITLE)
			} else {
			    call sprintf (Memc[key], SZ_FNAME, "APID%d")
				call pargi (i)
			    call s_astr (im, Memc[key], Memc[str1])
			}
		    }
		}
	    }

	    do i = nl+1, ARB {
		call sprintf (Memc[key], SZ_FNAME, "APID%d")
		    call pargi (i)
		iferr (call s_delf (im, Memc[key]))
		    break
	    }

#call eprintf ("smw_saveim: 20\n")
	    call s_mwsaves (mw, im)
	}

	call mfree (coeff, TY_CHAR)
	call sfree (sp)
end
