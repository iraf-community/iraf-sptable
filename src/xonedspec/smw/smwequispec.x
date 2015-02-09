include <imhdr.h>
include	<mwset.h>
include	<smw.h>


# SMW_EQUISPEC -- Setup the EQUISPEC SMW parameters.
# The aperture information is in the APNUM and APID keywords and the
# WCS information is in the linear MWCS.

procedure smw_equispec (im, smw)

pointer	im			#I IMIO pointer
pointer	smw			#U MWCS pointer input SMW pointer output

bool	streq()
int	i, j, k, nchar, ap, beam, dtype, nw
double	w1, dw, z
real	aplow[2], aphigh[2], mw_c1tranr()
pointer	sp, key, val, wterm, mw, ct, mw_sctran()
int	s_geti(), mw_stati(), ctoi(), ctor()
errchk	s_gstr, mw_gwtermd, mw_sctran
errchk	smw_open, smw_swattrs, smw_sapid

pointer	foo

begin
	call smark (sp)
	call salloc (key, SZ_FNAME, TY_CHAR)
	call salloc (val, SZ_LINE, TY_CHAR)

	# Determine the dispersion parameters
	mw = smw
	i = mw_stati (mw, MW_NDIM)
#call eprintf ("smw_equispec: ndim=%d\n")
#call pargi (i)
	call mw_gwattrs (mw, 1, "wtype", Memc[val], SZ_LINE)
#call eprintf ("smw_equispec: axtype = %s\n")
#call pargstr (Memc[val])
	if (streq (Memc[val], "sampled") && S_IM(im) == NULL) {
	    w1 = S_W(im)
	    dw = S_DW(im)
	} else {
	    call salloc (wterm, 2*i+i*i, TY_DOUBLE)
	    call mw_gwtermd (mw, Memd[wterm], Memd[wterm+i], Memd[wterm+2*i], i)
	    w1 = Memd[wterm+i]
	    dw = Memd[wterm+2*i]
	}
#call eprintf ("smw_equispec: w1=%.g dw=%.4g\n")
#call pargd (w1)
#call pargd (dw)

	# Determine the number of physical pixels.
	ct = mw_sctran (mw, "logical", "physical", 1)
	nw = max (mw_c1tranr (ct, 1.), mw_c1tranr (ct, real(S_NDISP(im))))
	call mw_ctfree (ct)

	# Determine the dispersion type.
	iferr (dtype = s_geti (im, "DC-FLAG"))
	    dtype = DCNO
	if (dtype==DCLOG) {
	    if (abs(w1)>20. || abs(w1+(nw-1)*dw)>20.)
		dtype = DCLINEAR
	    else {
		w1 = 10D0 ** w1
		dw = w1 * (10D0 ** ((nw-1)*dw) - 1) / (nw - 1)
	    }
	} else if (dtype==DCFUNC)
	    dtype = DCLINEAR

	# Set the SMW data structure.
#call eprintf ("smw_equispec: 10\n")
	call smw_open (smw, NULL, im)
#call eprintf ("smw_equispec: 15 dtype = %d\n")
#call pargi (dtype)
	do i = 1, SMW_NSPEC(smw) {
#call eprintf ("smw_equispec: 20\n")
	    call smw_mw (smw, i, 1, mw, j, k)
	    if (j < 1000)
		call sprintf (Memc[key], SZ_FNAME, "APNUM%d")
	    else
		call sprintf (Memc[key], SZ_FNAME, "AP%d")
		call pargi (j)
#call eprintf ("smw_equispec: 30\n")
	    iferr (call s_gstr (im, Memc[key], Memc[val], SZ_LINE))
	         call strcpy ("1 1", Memc[val], SZ_LINE)
	    k = 1
	    nchar = ctoi (Memc[val], k, ap)
	    nchar = ctoi (Memc[val], k, beam)
	    if (ctor (Memc[val], k, aplow[1]) == 0)
		aplow[1] = INDEF
	    if (ctor (Memc[val], k, aphigh[1]) == 0)
		aphigh[1] = INDEF
	    if (ctor (Memc[val], k, aplow[2]) == 0)
		aplow[2] = INDEF
	    if (ctor (Memc[val], k, aphigh[2]) == 0)
		aphigh[2] = INDEF
	    z = 0.

#call eprintf ("smw_equispec: 40 ap=%d w1=%.4g\n")
#call pargi (ap)
#call pargd (w1)
#call eprintf ("smw_equispec: 45 dtype = %d\n")
#call pargi (dtype)
	    call smw_swattrs (smw, i, 1, ap, beam, dtype, w1, dw, nw, z,
		aplow, aphigh, "")
#call eprintf ("smw_equispec: 50 SMW_DTYPE(%d) = %d\n")
#call pargi (smw)
#call pargi (SMW_DTYPE(smw))

	    call sprintf (Memc[key], SZ_FNAME, "APID%d")
		call pargi (j)
	    ifnoerr (call s_gstr (im, Memc[key], Memc[val], SZ_LINE))
		call smw_sapid (smw, i, 1, Memc[val])
	}
#call eprintf ("smw_equispec: 60 SMW_DTYPE(%d) = %d\n")
#call pargi (smw)
#call pargi (SMW_DTYPE(smw))

	call sfree (sp)
end
