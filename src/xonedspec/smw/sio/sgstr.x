include	<s.h>
include	"tb.h"

# S_GSTR -- Get string header parameter.
# This creates the APNUM and APID keywords from table columns.

procedure s_gstr (s, key, str, maxchar)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword
char	str[ARB]		#O String value
int	maxchar			#I Maximum number of characters

int	i, j, row, apnum, aptype, strncmp(), ctoi()
real	aplow, aphigh
pointer	tb, tp, im, cptr
errchk	s_gkey, skeymap_defs, tbcfnd1, tbegti, tbegtr, tbegtt

define	default_	10

begin
	# Get keyword and possibly array element.
	call s_gkey (s, key, S_STRBUF(s), i)

	# For an image all array elements are the same as a keyword.
	if (S_IM(s) != NULL) {
	    iferr (call imgstr (S_IM(s), S_STRBUF(s), str, maxchar))
		call skeymap_defs (S_STRBUF(s), str, maxchar)
	    return
	}

	tb = S_TB(s)
	tp = TB_TP(tb)
	im = TB_IM(tb)

	# Check for APNUMnnn.
	if (strncmp (S_STRBUF(s), "APNUM", 5) == 0) {
	    j = 6
	    if (ctoi (S_STRBUF(s), j, row) != 0) {
		if (row < 0 || row > S_NSPEC(s))
		    goto default_
		call skeymap_key ("APNUM", TB_KBUF(tb), TB_LENSTR)
		call tbcfnd1 (tp, TB_KBUF(tb), cptr)
		if (cptr == NULL)
		    apnum = row
		else
		    call tbegti (tp, cptr, row, apnum)
		call skeymap_key ("APTYPE", TB_KBUF(tb), TB_LENSTR)
		call tbcfnd1 (tp, TB_KBUF(tb), cptr)
		if (cptr == NULL)
		    goto default_
		call tbegti (tp, cptr, row, aptype)
		call skeymap_key ("APLOW", TB_KBUF(tb), TB_LENSTR)
		call tbcfnd1 (tp, TB_KBUF(tb), cptr)
		if (cptr == NULL)
		    goto default_
		call tbegtr (tp, cptr, row, aplow)
		call skeymap_key ("APHIGH", TB_KBUF(tb), TB_LENSTR)
		call tbcfnd1 (tp, TB_KBUF(tb), cptr)
		if (cptr == NULL)
		    goto default_
		call tbegtr (tp, cptr, row, aphigh)

		call sprintf (str, maxchar, "%d %d %g %g")
		    call pargi (apnum)
		    call pargi (aptype)
		    call pargr (aplow)
		    call pargr (aphigh)
		return
	    }
	}

	# Check for APIDnnn.
	if (strncmp (S_STRBUF(s), "APID", 4) == 0) {
	    j = 5
	    if (ctoi (S_STRBUF(s), j, row) != 0) {
		if (row < 0 || row > S_NSPEC(s))
		    goto default_
		call skeymap_key ("APID", TB_KBUF(tb), TB_LENSTR)
		call tbcfnd1 (tp, TB_KBUF(tb), cptr)
		if (cptr == NULL)
		    goto default_
		call tbegtt (tp, cptr, row, str, maxchar)
		return
	    }
	}

default_
	# If there is no array specification return the keyword value.
	if (i == 0) {
	    iferr (call imgstr (im, S_STRBUF(s), str, maxchar))
		call skeymap_defs (S_STRBUF(s), str, maxchar)
	    return
	}

	# Look for a column.  If there is no column look in header.
	call skeymap_key (S_STRBUF(s), TB_KBUF(tb), TB_LENSTR)
	call tbcfnd1 (tp, TB_KBUF(tb), cptr)
	if (cptr != NULL)
	    call tbegtt (tp, cptr, i, str, maxchar)
	else {
	    iferr (call imgstr (im, S_STRBUF(s), str, maxchar))
		call skeymap_defs (S_STRBUF(s), str, maxchar)
	}
end
