include	<s.h>
include	"tb.h"

# S_GETD -- Get double parameter.

double procedure s_getd (s, key)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword

int	i
double	dval, imgetd()
pointer	tb, tp, im, cptr
errchk	s_gkey, skekymap_defd, tbcfnd1, tbegtd

begin
	# Get keyword and possibly array element.
	call s_gkey (s, key, S_STRBUF(s), i)

	# For an image all array elements are the same as a keyword.
	if (S_IM(s) != NULL) {
	    iferr (dval = imgetd (S_IM(s), S_STRBUF(s)))
		call skeymap_defd (S_STRBUF(s), dval)
	    return (dval)
	}

	tb = S_TB(s)
	tp = TB_TP(tb)
	im = TB_IM(tb)

	# If there is no array specification return the keyword value.
	if (i == 0) {
	    iferr (dval = imgetd (im, S_STRBUF(s)))
		call skeymap_defd (S_STRBUF(s), dval)
	    return (dval)
	}

	# Look for a column.  If there is no column look in header.
	call skeymap_key (S_STRBUF(s), TB_KBUF(tb), TB_LENSTR)
	call tbcfnd1 (tp, TB_KBUF(tb), cptr)
	if (cptr != NULL) {
	    call tbegtd (tp, cptr, i, dval)
	    return (dval)
	} else {
	    iferr (dval = imgetd (im, S_STRBUF(s)))
		call skeymap_defd (S_STRBUF(s), dval)
	    return (dval)
	}
end
