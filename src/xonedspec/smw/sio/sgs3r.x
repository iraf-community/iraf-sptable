include	<s.h>
include	<tbset.h>
include	"tb.h"


# S_GS3R -- Get section.

pointer procedure s_gs3r (s, c1, c2, l1, l2, b1, b2)

pointer	s			#I Spectrum I/O pointer
int	c1, c2			#I Columns
int	l1, l2			#I Lines
int	b1, b2			#I Bands

int	i, j, k, nc, nl, nb, l, b, strncmp(), ctoi()
real	scale
pointer	tb, tp, buf, null, ptr, imgs3r()
errchk	malloc, realloc, imgs3r

begin	
	if (S_IM(s) != NULL)
	    return (imgs3r (S_IM(s), c1, c2, l1, l2, b1, b2))

	tb = S_TB(s)
	tp = TB_TP(tb)
	buf = TB_BUF(tb)
	null = TB_NULL(tb)

	nc = c2 - c1 + 1
	nl = l2 - l1 + 1
	nb = b2 - b1 + 1

	ptr = buf
	do b = b1, b2 {
	    do l = l1, l2 {
		if (b == 1)
		    i = l
		else if ((b == 2 && TB_NASSOC(tb) > 0) ||
		    (b == 3 && TB_NASSOC(tb) == 0))
		    i = l + TB_NSPEC(tb)
		else if (b == 3 && TB_NERR(tb) > 0)
		    i = l +  TB_NSPEC(tb) + TB_NASSOC(tb)
		else if (b == 2 && TB_NASSOC(tb) == 0 && TB_NERR(tb) > 0)
		    i = l +  TB_NSPEC(tb)
		else
		    call error (1, "Spectrum not found")

		# Get data.
		if (TB_NROWS(tb) == 1)
		    call tbagtr (TB_TP(tb), TB_SPEC(tb,i), 1,
			Memr[ptr], c1, nc)
		else
		    call tbcgtr (TB_TP(tb), TB_SPEC(tb,i),
			Memr[ptr], Memr[null], c1, nc)

		# Set column names.
		if (TB_COORD(tb,i) != NULL)
		    call tbcigt (TB_COORD(tb,i), TBL_COL_NAME, TB_KBUF(tb),
			TB_LENSTR)
		else
		    call strcpy ("row", TB_KBUF(tb), TB_LENSTR)
		call tbcigt (TB_SPEC(tb,i), TBL_COL_NAME, TB_SBUF(tb),
		    TB_LENSTR)
		call sprintf (S_TBCOLS(s), S_LENSTR, "[%s,%s]")
		    call pargstr (TB_KBUF(tb))
		    call pargstr (TB_SBUF(tb))

		# Check for units scaling.
		call tbcigt (TB_SPEC(tb,i), TBL_COL_UNITS, TB_SBUF(tb),
		    TB_LENSTR)
		if (strncmp ("10^", TB_SBUF(tb), 3) == 0) {
		    j = 4
		    if (ctoi (TB_SBUF(tb), j, k) > 0) {
			scale = 10.**(k)
			call amulkr (Memr[buf], scale, Memr[buf], nc)
		    }
		}
		if (strncmp ("10**(", TB_SBUF(tb), 5) == 0) {
		    j = 6
		    if (ctoi (TB_SBUF(tb), j, k) > 0) {
			scale = 10.**(k)
			call amulkr (Memr[buf], scale, Memr[buf], nc)
		    }
		}
		if (strncmp ("1e", TB_SBUF(tb), 2) == 0) {
		    j = 3
		    if (ctoi (TB_SBUF(tb), j, k) > 0) {
			scale = 10.**(k)
			call amulkr (Memr[buf], scale, Memr[buf], nc)
		    }
		}

		ptr = ptr + nc
	    }
	}

	return (buf)
end
