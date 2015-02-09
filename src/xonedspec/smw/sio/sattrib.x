include	<tbset.h>
include	<smw.h>
include	<s.h>
include	"tb.h"


# S_ATTRIB -- Set attributes for multiple WCS.

procedure s_attrib (s, smw)

pointer	s			#I Spectrum I/O pointer
pointer	smw			#I Spectrum WCS descriptor

int	i, j, k, n, ap, aptype, dtype, nw, tbcigi()
real	aplow, aphigh
double	w1, dw, z
pointer	tb, tp, mw, pv, wv, mw_newcopy()
errchk	mw_newcopy, malloc, mw_sampled

begin
	if (S_IM(s) != NULL)
	    return

	tb = S_TB(s)
	tp = TB_TP(tb)

	switch (SMW_FORMAT(smw)) {
	case SMW_MS:
	    do i = 1, SMW_NSPEC(smw) {
		call tbegti (tp, TB_APNUM(tb), i, ap)
		call tbegti (tp, TB_APTYPE(tb), i, aptype)
		call tbegtr (tp, TB_APLOW(tb), i, aplow)
		call tbegtr (tp, TB_APHIGH(tb), i, aphigh)
		call tbegti (tp, TB_DTYPE(tb), i, dtype)
		call tbegtd (tp, TB_W1(tb), i, w1)
		call tbegtd (tp, TB_DW(tb), i, dw)
		call tbegti (tp, TB_NW(tb), i, nw)
		call tbegtd (tp, TB_Z(tb), i, z)
		call smw_swattrs (smw, i, 1, ap, aptype, dtype, w1, dw, nw,
		    z, aplow, aphigh, "")
	    }
	}

	# Check for sampled WCS.
	if (TB_COORD(tb) != NULL) {
	    j = SMW_NMW(smw)

	    SMW_NSMW(smw) = 1
	    SMW_NMW(smw) = SMW_NSPEC(smw)
	    if (SMW_NMW(smw) > j)
		call realloc (smw, SMW_LEN(SMW_NMW(smw)), TY_STRUCT)

	    mw = SMW_MW(smw,0)
	    do i = j, SMW_NMW(smw)-1
		SMW_MW(smw,i) = mw_newcopy (mw)

	    n = tbcigi (TB_COORD(tb), TBL_COL_LENDATA) + 2
	    call malloc (pv, n, TY_DOUBLE)
	    call malloc (wv, n, TY_DOUBLE)
	    do i = 1, n-1
		Memd[pv+i] = i
	    Memd[pv] = Memd[pv] - 0.5
	    Memd[pv+n-1] = Memd[pv+n-1] + 0.5
	    do i = 1, SMW_NSPEC(smw) {
		call tbegti (tp, TB_APNUM(tb), i, ap)
		call tbegti (tp, TB_APTYPE(tb), i, aptype)
		call tbegtr (tp, TB_APLOW(tb), i, aplow)
		call tbegtr (tp, TB_APHIGH(tb), i, aphigh)
		call tbegti (tp, TB_DTYPE(tb), i, dtype)
		call tbegtd (tp, TB_W1(tb), i, w1)
		call tbegtd (tp, TB_DW(tb), i, dw)
		call tbegti (tp, TB_NW(tb), i, nw)
		call tbegtd (tp, TB_Z(tb), i, z)
		call smw_swattrs (smw, i, 1, ap, aptype, dtype, w1, dw, nw,
		    z, aplow, aphigh, "")

		call tbagtd (tp, TB_COORD(tb), i, Memd[wv+1], 1, n-2)
		Memd[wv] = (Memd[wv+1] - Memd[wv+2]) / 2
		Memd[wv+n-1] = (3 * Memd[wv+n-2] - Memd[wv+n-3]) / 2
		call smw_mw (smw, i, 1, mw, j, k)
		call mw_swtype (mw, 1, 1, "sampled", "")
		call mw_swtype (mw, 2, 1, "linear", "")
		call mw_swsampd (mw, 1, Memd[pv], Memd[wv], n)
	    }
	    call mfree (pv, TY_DOUBLE)
	    call mfree (wv, TY_DOUBLE)
	}
end
