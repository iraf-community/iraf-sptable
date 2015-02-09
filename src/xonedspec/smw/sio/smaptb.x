include	<error.h>
include	<imhdr.h>
include	<imio.h>
include	<pkg/rg.h>
include	<tbset.h>
include	<s.h>
include	"tb.h"

# S_MAPTB -- Map a table spectrum file.

pointer procedure s_maptb (fname, mode, arg)

char	fname[ARB]		#I Spectrum file specification
int	mode			#I Spectrum access mode
int	arg			#I Procedure argument
pointer	s			#O spectrum I/O pointer

int	i, j, k, ncols, nrows, ndisp, nspec, nassoc, nerr, naux
pointer	sp, im, tp, tb, cptr, instkey, extn, rstr, ptr
pointer	rgdisp, rgspec, rgassoc, rgerr
int	ival
bool	bval
double	dval

bool	streq()
int	tbpsta(), tbcigi(), strlen(), rg_next ()
pointer	tbtopn(), tbcnum(), s_imhdr()
errchk	tbtopn, instmap_open, instmap

begin	
#call eprintf ("s_maptb: %s\n")
#call pargstr (fname)
	call smark (sp)
	call salloc (instkey, 2047, TY_CHAR)
	call salloc (extn, SZ_LINE, TY_CHAR)
	call salloc (rstr, SZ_LINE, TY_CHAR)

	iferr {
	    tp = NULL; tb = NULL; s = NULL
	    rgdisp = NULL; rgspec = NULL; rgassoc = NULL; rgerr = NULL

	    # Open the table.  Return on an error.
	    iferr (ptr = tbtopn (fname, mode, NULL)) {
		call clgstr ("tbextn", Memc[extn], SZ_FNAME)
	        call sprintf (Memc[rstr], SZ_LINE, "%s.%s")
		    call pargstr (fname)
		    call pargstr (Memc[extn])
		    ptr = tbtopn (Memc[rstr], mode, NULL)
	    }
	    tp = ptr

	    # Open the instrument map.
	    call instmap_open ()

	    # Get the columns as ranges.
	    ncols = tbpsta (tp, TBL_NCOLS)
	    nrows = tbpsta (tp, TBL_NROWS)
	    cptr = instkey; j = 2047
	    do i = 1, ncols {
	        call tbcigt (tbcnum(tp,i), TBL_COL_NAME, Memc[rstr], SZ_LINE)
		k = strlen (Memc[rstr])
		if (cptr > instkey) {
		    Memc[cptr] = ','
		    Memc[cptr+1] = EOS
		    cptr = cptr + 1; j = j - 1
		}
		if (j <= 0)
		    break
		call strcpy (Memc[rstr], Memc[cptr], j)
		cptr = cptr + k; j = j - k
	    }
	    call instmap (Memc[instkey], Memc[rstr], SZ_LINE,
	        ncols, rgdisp, rgspec, rgerr, rgassoc)

	    # Allocate spectrum I/O pointer and table pointer.
	    ndisp = nrows
	    nspec = RG_NPTS(rgspec)
	    nassoc = RG_NPTS(rgassoc)
	    nerr = RG_NPTS(rgerr)
	    naux = 0; ncols = 0
	    if (nspec > 0) {
		naux = naux + 1
		ncols = ncols + nspec
	    }
	    if (nassoc > 0) {
		naux = naux + 1
		ncols = ncols + nassoc
	    }
	    if (nerr > 0) {
		naux = naux + 1
		ncols = ncols + nerr
	    }

	    # Require matching.
	    #if (RG_NPTS(rgdisp) != 1 || nspec < 1 ||
	    if (nspec < 1 ||
	        (nassoc > 0 && nassoc != nspec) || (nerr > 0 && nerr != nspec))
		call error (1, "Table columns not properly specified")

	    call calloc (tb, TB_LEN(ncols), TY_STRUCT)
	    TB_TP(tb) = tp
	    TB_NSPEC(tb) = nspec
	    TB_NASSOC(tb) = nassoc
	    TB_NERR(tb) = nerr

	    # Get column pointers.  Note we don't worry about a column
	    # being used more than once.

	    i = 0; j = 0
	    if (rg_next (rgdisp, i) != EOF) {
		TB_COORD(tb) = tbcnum (tp, i)
		k = tbcigi (TB_COORD(tb), TBL_COL_LENDATA)
		if (nrows == 1) {
		    if (ndisp == 1)
		        ndisp = k
		    if (k != ndisp)
			call error (1, "Spectrum does not match dispersion")
		} else {
		    if (k > 1)
			call error (1, "Table format not supported")
		}
	    }
	    i = 0
	    while (rg_next (rgspec, i) != EOF) {
		j = j + 1
		TB_SPEC(tb,j) = tbcnum (tp, i)
		k = tbcigi (TB_SPEC(tb,j), TBL_COL_LENDATA)
		if (nrows == 1) {
		    if (ndisp == 1)
		        ndisp = k
		    if (k != ndisp)
			call error (1,
			    "Number of spectrum values do not match dispersion")
		} else {
		    if (k > 1)
			call error (1, "Table format not supported")
		}
	    }
	    i = 0
	    while (rg_next (rgassoc, i) != EOF) {
		j = j + 1
		TB_SPEC(tb,j) = tbcnum (tp, i)
		k = tbcigi (TB_SPEC(tb,j), TBL_COL_LENDATA)
		if (nrows == 1) {
		    if (ndisp == 1)
		        ndisp = k
		    if (k != ndisp)
			call error (1,
		"Number of associated spectrum values do not match dispersion")
		} else {
		    if (k > 1)
			call error (1, "Table format not supported")
		}
	    }
	    i = 0
	    while (rg_next (rgerr, i) != EOF) {
		j = j + 1
		TB_SPEC(tb,j) = tbcnum (tp, i)
		k = tbcigi (TB_SPEC(tb,j), TBL_COL_LENDATA)
		if (nrows == 1) {
		    if (ndisp == 1)
		        ndisp = k
		    if (k != ndisp)
			call error (1,
			   "Number of error values do not match dispersion")
		} else {
		    if (k > 1)
			call error (1, "Table format not supported")
		}
	    }

	    # Allocate working buffers.
	    TB_BUFLEN(tb) = ndisp * nspec * naux
	    call malloc (TB_BUF(tb), TB_BUFLEN(tb), TY_REAL)
	    TB_NULLLEN(tb) = ndisp
	    call malloc (TB_NULL(tb), TB_NULLLEN(tb), TY_INT)

	    # Set spectrum file information.
	    call calloc (s, S_LEN, TY_STRUCT)
	    call strcpy (fname, S_FILE(s), S_LENSTR)
	    S_PIXTYPE(s) = TY_REAL
	    S_NDISP(s) = ndisp
	    S_NSPEC(s) = nspec
	    S_NAUX(s) = naux
	    if (naux > 1)
		S_NDIM(s) = 3
	    else if (nspec > 1)
		S_NDIM(s) = 2
	    else
		S_NDIM(s) = 1
	    S_PDIM(s) = S_NDIM(s)

	    # Copy header to IMIO pointer.  Translate keywords.
	    im = s_imhdr (1, 0)
	    IM_LEN(im,1) = S_NDISP(s)
	    IM_LEN(im,2) = S_NSPEC(s)
	    IM_LEN(im,3) = S_NAUX(s)
	    IM_PIXTYPE(im) = S_PIXTYPE(s)
	    call strcpy (S_FILE(s), IM_HDRFILE(im), SZ_IMHDRFILE)
	    call strcpy (S_FILE(s), IM_PIXFILE(im), SZ_IMPIXFILE)
	    do i = 1, ARB {
		iferr (call tbhgnp (tp, i, TB_KBUF(tb), j, TB_SBUF(tb)))
		    break
		if (TB_KBUF(tb) == EOS)
		    break
		call skeymap_inv (TB_KBUF(tb), TB_KBUF(tb), TB_LENSTR)
		switch (j) {
		case TY_BOOL:
		    bval = (TB_SBUF(tb) == 'T')
		    call imaddb (im, TB_KBUF(tb), bval)
		case TY_INT, TY_LONG:
		    call sscan (TB_SBUF(tb))
		    call gargi (ival)
		    if (streq (TB_KBUF(tb), "WCSDIM"))
			IM_NPHYSDIM(im) = ival
		    call imaddi (im, TB_KBUF(tb), ival)
		case TY_REAL, TY_DOUBLE:
		    call sscan (TB_SBUF(tb))
		    call gargd (dval)
		    call imaddd (im, TB_KBUF(tb), dval)
		case TY_CHAR:
		    if (streq (TB_KBUF(tb), "XTENSION"))
		        ;
		    else
			call imastr (im, TB_KBUF(tb), TB_SBUF(tb))
		}
	    }

	    iferr (call imgstr (im, "OBJECT", IM_TITLE(im), SZ_IMTITLE))
	        IM_TITLE(im) = EOS
	    call strcpy (IM_TITLE(im), S_TITLE(s), S_LENSTR)

	    TB_TP(tb) = tp
	    TB_NROWS(tb) = nrows
	    TB_NSPEC(tb) = nspec
	    TB_NASSOC(tb) = nassoc
	    TB_NERR(tb) = nerr
	    S_TB(s) = tb
	    TB_IM(tb) = im

	    call rg_free (rgdisp)
	    call rg_free (rgspec)
	    call rg_free (rgassoc)
	    call rg_free (rgerr)
	    call sfree (sp)
	} then {
	    if (rgdisp != NULL)
		call rg_free (rgdisp)
	    if (rgspec != NULL)
		call rg_free (rgspec)
	    if (rgassoc != NULL)
		call rg_free (rgassoc)
	    if (rgerr != NULL)
		call rg_free (rgerr)
	    if (tp != NULL)
		call tbtclo (tp)
	    if (tb != NULL) {
		if (TB_BUF(tb) != NULL)
		    call mfree (TB_BUF(tb), TY_REAL)
		if (TB_NULL(tb) != NULL)
		    call mfree (TB_NULL(tb), TY_INT)
		call mfree (tb, TY_STRUCT)
	    }
	    if (s != NULL)
		call mfree (s, TY_STRUCT)
	    call sfree (sp)
	    call erract (EA_ERROR)
	}

	return (s)
end
