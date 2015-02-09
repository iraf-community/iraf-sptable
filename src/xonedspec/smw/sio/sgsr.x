include	<s.h>
include	<tbset.h>
include	"tb.h"


# S_GSR -- Get spectrum.

pointer procedure s_gsr (s, l, b)

pointer	s			#I Spectrum I/O pointer
int	l			#I Spectrum line number
int	b			#I Auxilary number

int	i, j, k, strncmp(), ctoi()
real	scale
pointer	tb, buf, null, imgl3r()
errchk	malloc, realloc, imgl3r, tbcgtr

begin	
	if (S_IM(s) != NULL) {
	    S_TBCOLS(s) = EOS
	    return (imgl3r (S_IM(s), l, b))
	}

	tb = S_TB(s)
	buf = TB_BUF(tb)
	null = TB_NULL(tb)

	# Find column.
	if (b == 1)
	    i = l
	else if ((b==2 && TB_NASSOC(tb)>0) || (b==3 && TB_NASSOC(tb)==0))
	    i = l + TB_NSPEC(tb)
	else if (b == 3 && TB_NERR(tb) > 0)
	    i = l +  TB_NSPEC(tb) + TB_NASSOC(tb)
	else if (b == 2 && TB_NASSOC(tb) == 0 && TB_NERR(tb) > 0)
	    i = l + TB_NSPEC(tb)
	else
	    call error (1, "Spectrum not found")

	# Get data.
	if (TB_NROWS(tb) == 1) {
	    call tbagtr (TB_TP(tb), TB_SPEC(tb,i), 1,
		Memr[buf], 1, S_NDISP(s))
	} else {
	    call tbcgtr (TB_TP(tb), TB_SPEC(tb,i),
		Memr[buf], Memi[null], 1, S_NDISP(s))
	}

	# Set column names.
	if (TB_COORD(tb,i) != NULL)
	    call tbcigt (TB_COORD(tb,i), TBL_COL_NAME, TB_KBUF(tb), TB_LENSTR)
	else
	    call strcpy ("row", TB_KBUF(tb), TB_LENSTR)
	call tbcigt (TB_SPEC(tb,i), TBL_COL_NAME, TB_SBUF(tb), TB_LENSTR)
	call sprintf (S_TBCOLS(s), S_LENSTR, "[%s,%s]")
	    call pargstr (TB_KBUF(tb))
	    call pargstr (TB_SBUF(tb))

	# Check for units scaling.
	call tbcigt (TB_SPEC(tb,i), TBL_COL_UNITS, TB_SBUF(tb), TB_LENSTR)
	if (strncmp ("10^", TB_SBUF(tb), 3) == 0) {
	    j = 4
	    if (ctoi (TB_SBUF(tb), j, k) > 0) {
		scale = 10.**(k)
		call amulkr (Memr[buf], scale, Memr[buf], S_NDISP(s))
	    }
	}
	if (strncmp ("10**(", TB_SBUF(tb), 5) == 0) {
	    j = 6
	    if (ctoi (TB_SBUF(tb), j, k) > 0) {
		scale = 10.**(k)
		call amulkr (Memr[buf], scale, Memr[buf], S_NDISP(s))
	    }
	}
	if (strncmp ("1e", TB_SBUF(tb), 2) == 0) {
	    j = 3
	    if (ctoi (TB_SBUF(tb), j, k) > 0) {
		scale = 10.**(k)
		call amulkr (Memr[buf], scale, Memr[buf], S_NDISP(s))
	    }
	}

	return (buf)
end
