include	<s.h>
include	"tb.h"

# S_GETR -- Get real parameter.

real procedure s_getr (s, key)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword

int	i
real	rval, imgetr()
pointer	tb, tp, im, cptr
errchk	s_gkey, skeymap_defr, tbcfnd1, tbegtr

begin
	# Get keyword and possibly array element.
	call s_gkey (s, key, S_STRBUF(s), i)

	# For an image all array elements are the same as a keyword.
	if (S_IM(s) != NULL) {
	    iferr (rval = imgetr (S_IM(s), S_STRBUF(s)))
		call skeymap_defr (S_STRBUF(s), rval)
	    return (rval)
	}

	tb = S_TB(s)
	tp = TB_TP(tb)
	im = TB_IM(tb)

	# If there is no array specification return the keyword value.
	if (i == 0) {
	    iferr (rval = imgetr (im, S_STRBUF(s)))
		call skeymap_defr (S_STRBUF(s), rval)
	    return (rval)
	}

	# Look for a column.  If there is no column look in header.
	call skeymap_key (S_STRBUF(s), TB_KBUF(tb), TB_LENSTR)
	call tbcfnd1 (tp, TB_KBUF(tb), cptr)
	if (cptr != NULL) {
	    call tbegtr (tp, cptr, i, rval)
	    return (rval)
	} else {
	    iferr (rval = imgetr (im, S_STRBUF(s)))
		call skeymap_defr (S_STRBUF(s), rval)
	    return (rval)
	}
end
