include	<tbset.h>
include	<smw.h>
include	"tb.h"


# S_MWOPENS -- Open an MWCS descriptor on a spectrum.

pointer procedure s_mwopens (s, index)

pointer	s			#I pointer to spectrum descriptor
int	index			#I spectrum index
pointer	mw			#O MWCS descriptor

pointer	s_mwopeni(), s_mwopent()
errchk	s_mwopeni, s_mwopent

begin
	if (S_IM(s) != NULL)
	    mw = s_mwopeni (s, index)
	else if (S_TB(s) != NULL)
	    mw = s_mwopent (s, index)

	return (mw)
end


# S_MWOPENI -- Open an MWCS descriptor on an image spectrum.

pointer procedure s_mwopeni (s, index)

pointer	s			#I pointer to spectrum descriptor
int	index			#I spectrum index
pointer	mw			#O MWCS descriptor

pointer	sp, sformat, mw_openim()
errchk	mw_openim

begin
	call smark (sp)
	call salloc (sformat, SZ_FNAME, TY_CHAR)

	mw = mw_openim (S_IM(s))
	call mw_gwattrs (mw, 0, "system", Memc[sformat], SZ_FNAME)
	call mw_swattrs (mw, 0, "sformat", Memc[sformat])

	call sfree (sp)
	return (mw)
end


# S_MWOPENT -- Open an MWCS descriptor on a table spectrum.
# This returns a pointer to an array S_NSPEC MWCS pointers.
# The pointers maybe the same or different.
#
# Note that even through a sampled WCS is used the DC type is linear.

pointer procedure s_mwopent (s, index)

pointer	s			#I pointer to spectrum descriptor
int	index			#I spectrum index
pointer	mw			#O MWCS descriptor

int	i, n
double	dval
pointer	tb, tp, im, ct, pv, wv

int	ap, aptype, dtype, imgeti()
double	r, w, dw, aplow, aphigh, imgetd()

bool	streq()
int	s_accf()
double	mw_c1trand()
pointer	mw_openim(), mw_sctran()
errchk	mw_openim, mw_sctran, mw_c1trand, s_setwcs

begin
	tb = S_TB(s)
	tp = TB_TP(tb)
	im = TB_IM(tb)

#	# Set all scalar parameters in the image header.
#	n = tbpsta (tp, TBL_NCOLS)
#	do i = 1, n {
#	    cptr = tbcnum (tp, i)
#	    if (tbcigi (cptr, TBL_COL_LENDATA) == 1) {
#		call tbcigt (cptr, TBL_COL_NAME, TB_KBUF(tb), TB_LENSTR)
#		call skeymap_inv (TB_KBUF(tb), TB_KBUF(tb), TB_LENSTR)
#		switch (tbcigi (cptr, TBL_COL_DATATYPE)) {
#		case TY_BOOL:
#		    call tbegtb (tp, cptr, index, bval)
#		    call imaddb (im, TB_KBUF(tb), bval)
#		case TY_SHORT, TY_INT:
#		    call tbegti (tp, cptr, index, ival)
#		    call imaddi (im, TB_KBUF(tb), ival)
#		case TY_REAL, TY_DOUBLE:
#		    call tbegtd (tp, cptr, index, dval)
#		    call imaddd (im, TB_KBUF(tb), dval)
#		case TY_CHAR:
#		    call tbegtt (tp, cptr, index, TB_SBUF(tb), TB_LENSTR)
#		    call imastr (im, TB_KBUF(tb), TB_SBUF(tb))
#		}
#	    }
#	}

	# Set WCS defaults if they are in the keyword translation file.
#call eprintf ("s_mwopent: 10\n")
	if (s_accf (s, "CRVAL1") == NO) {
	    ifnoerr (call skeymap_defd ("CRVAL1", dval))
		call s_addd (s, "CRVAL1", dval)
	}
#call eprintf ("s_mwopent: 20\n")
	if (s_accf (s, "CRPIX1") == NO) {
	    ifnoerr (call skeymap_defd ("CRPIX1", dval))
		call s_addd (s, "CRPIX1", dval)
	}
#call eprintf ("s_mwopent: 30\n")
	if (s_accf (s, "CD1_1") == NO) {
	    ifnoerr (call skeymap_defd ("CD1_1", dval))
		call s_addd (s, "CD1_1", dval)
	}
#call eprintf ("s_mwopent: 40\n")
	if (s_accf (s, "CTYPE1") == NO) {
	    ifnoerr (call skeymap_defs ("CTYPE1", TB_SBUF(tb), TB_LENSTR))
		call s_astr (s, "CTYPE1", TB_SBUF(tb))
	}
#call eprintf ("s_mwopent: 50\n")
	if (s_accf (s, "CUNIT1") == NO) {
	    ifnoerr (call skeymap_defs ("CUNIT1", TB_SBUF(tb), TB_LENSTR))
		call s_astr (s, "CUNIT1", TB_SBUF(tb))
	}
#call eprintf ("s_mwopent: 60\n")
#	if (s_accf (s, "DC-FLAG") == NO) {
#	    ival = DCLINEAR
#	    ifnoerr (call skeymap_defi ("DC-FLAG", ival))
#	        ;
#	    call s_addi (s, "DC-FLAG", ival)
#	}
#call eprintf ("s_mwopent: 70\n")

	# Open WCS.
	mw = mw_openim (im)
	call mw_swattrs (mw, 0, "sformat", "equispec")

	# Set WCS.
	if (TB_COORD(tb) != NULL) {
	    # Set units if defined.
	    call tbcigt (TB_COORD(tb), TBL_COL_UNITS, TB_SBUF(tb), TB_LENSTR)
	    if (TB_SBUF(tb) == EOS)
		call clgstr ("tbdunits", TB_SBUF(tb), TB_LENSTR)
	    call mw_swattrs (mw, 1, "units", TB_SBUF(tb))

	    # Check/Set sampled WCS.
	    n = S_NDISP(s) + 2
	    call malloc (pv, n, TY_DOUBLE)
	    call malloc (wv, n, TY_DOUBLE)
	    do i = 1, n-2
		Memd[pv+i] = i
	    Memd[pv] = Memd[pv+1] - 0.5
	    Memd[pv+n-1] = Memd[pv+n-2] + 0.5
#call eprintf ("s_mwopent: A %d %d\n")
#call pargi (TB_COORD(tb))
#call pargi (TB_NULL(tb))
	    if (TB_NROWS(tb) == 1)
		call tbagtd (tp, TB_COORD(tb), 1,
		    Memd[wv+1], 1, S_NDISP(s))
	    else
		call tbcgtd (tp, TB_COORD(tb),
		    Memd[wv+1], Memi[TB_NULL(tb)], 1, S_NDISP(s))
	    Memd[wv] = (3 * Memd[wv+1] - Memd[wv+2]) / 2
	    Memd[wv+n-1] = (3 * Memd[wv+n-2] - Memd[wv+n-3]) / 2
	    call s_linfit (Memd[pv+1], Memd[wv+1], n-2, w, dw, r)
#call eprintf ("s_mwopent: s_linfit - %.4g %.4g %.4g\n")
#call pargd (w)
#call pargd (dw)
#call pargd (r)
#do i = 0, n-1 {
#if (i < 5 || i > n-7) {
#call eprintf ("s_mwopent: %.1f %.2f\n")
#call pargd (nint(10*Memd[pv+i])/10D0)
#call pargd (Memd[wv+i])
#}
#}
#r = 1
	    if (r > 0.9999) {
#call eprintf ("s_mwopent: Create linear WCS\n")
		S_DTYPE(s) = DCLINEAR
		S_W(s) = w
		S_DW(s) = dw
		r = Memd[pv+1]
		call mw_swtype (mw, 1, 1, "linear", "")
		call mw_swtermd (mw, r, w, dw, 1)
	    } else {
#call eprintf ("s_mwopent: Create sampled WCS\n")
		S_DTYPE(s) = DCFUNC
		S_W(s) = w
		S_DW(s) = dw
		call mw_ssystem (mw, "world")
		call mw_swtype (mw, 1, 1, "sampled", "")
		call mw_swsampd (mw, 1, Memd[pv+1], Memd[wv+1], n-2)
	    }
	    call mfree (pv, TY_DOUBLE)
	    call mfree (wv, TY_DOUBLE)
	}

	# Set dispersion types.
#call eprintf ("s_mwopens: call s_setwcs\n")
	call s_setwcs (mw, 1)

	# Set spec1 attribute.
	iferr (ap = imgeti (im, "APNUM"))
	    ap = index
	iferr (aptype = imgeti (im, "APTYPE"))
	    aptype = 0
	iferr (aphigh = imgetd (im, "APHIGH"))
	    aphigh = INDEFD
	iferr (aplow = imgetd (im, "APLOW"))
	    aplow = INDEFD
	iferr (call mw_gwattrs (mw, 1, "units", TB_SBUF(tb), TB_LENSTR))
	    TB_SBUF(tb) = EOS
	if (streq (TB_SBUF(tb), "pixel"))
	    dtype = DCNO
	else
	    dtype = DCLINEAR

#call eprintf ("s_mwopent: call mw_sctran\n")
	ct = mw_sctran (mw, "logical", "world", 1)
#call eprintf ("A: Memi[Memi[mw+2]+111]=Memi[%d]=%d\n")
#call pargi (Memi[mw+2]+111)
#call pargi (Memi[Memi[mw+2]+111])
	w = mw_c1trand (ct, 1D0)
	dw = mw_c1trand (ct, 2D0)
#call eprintf ("s_mwopent: First two points  %g %g\n")
#call pargd (w)
#call pargd (dw)
	dw = dw - w
	call mw_ctfree (ct)
#call eprintf ("B: Memi[Memi[mw+2]+111]=Memi[%d]=%d\n")
#call pargi (Memi[mw+2]+111)
#call pargi (Memi[Memi[mw+2]+111])

	call sprintf (TB_SBUF(tb), TB_LENSTR,
	    "%d %d %d %.14g %.14g %d %.14g %.2f %.2f")
	    call pargi (ap)
	    call pargi (aptype)
	    call pargi (dtype)
	    call pargd (w)
	    call pargd (dw)
	    call pargi (S_NDISP(s))
	    call pargd (0D0)
	    call pargd (aplow)
	    call pargd (aphigh)
#call eprintf ("s_mwopent: call mw_swattrs\n")
	call mw_swattrs (mw, 2, "spec1", TB_SBUF(tb))
#call eprintf ("s_mwopent: %s\n")
#call pargstr (TB_SBUF(tb))
#call eprintf ("C: Memi[Memi[mw+2]+111]=Memi[%d]=%d\n")
#call pargi (Memi[mw+2]+111)
#call pargi (Memi[Memi[mw+2]+111])

	# Set spectrum WCS format identification.
#	call mw_swattrs (mw, 0, "sformat", "equispec")
	#call mw_swattrs (mw, 0, "sformat", "multispec")
	#if (S_NSPEC(s) == 1)
	#    call mw_swattrs (mw, 0, "sformat", "equispec")
	#else
	#    call mw_swattrs (mw, 0, "sformat", "multispec")
#call eprintf ("Z: Memi[Memi[mw+2]+111]=Memi[%d]=%d\n")
#call pargi (Memi[mw+2]+111)
#call pargi (Memi[Memi[mw+2]+111])

	return (mw)
end


# S_LINFIT -- Determine a linear dispersion.
# This is used to decide whether a linear or sampled WCS should be used.

procedure s_linfit (x, y, n, w, dw, r)

double	x[n], y[n]		#I Sampled spectrum
int	n			#I Number of samples
double	w			#O Wavelength at x[1]
double	dw			#O Dispersion
double	r			#O Correlation coefficient squared

int	i
double	x1, xi, sumx, sumy, sumxx, sumyy, sumxy, dx, dy, dz

begin
	sumx = 0; sumy = 0; sumxx = 0; sumyy = 0; sumxy = 0
	x1 = x[1]
	do i = 1, n {
	    xi = x[i] - x1
#if (i > 1) {
#dx = x[i] - x[i-1]
#if (i > 2) {
#if (dy * dx < 0)
#call eprintf ("Non-monotonic\n")
#}
#dy = dx
#}
	    sumx = sumx + xi
	    sumy = sumy + y[i]
	    sumxx = sumxx + xi * xi
	    sumyy = sumyy + y[i] * y[i]
	    sumxy = sumxy + xi * y[i]
	}

	dx = n * sumxx - sumx * sumx
	dy = n * sumyy - sumy * sumy
	dz = n * sumxy - sumx * sumy
	w = (sumy * sumxx - sumx * sumxy) / dx
	dw = dz / dx
	r = (dz * dz) / (dx * dy)
end
