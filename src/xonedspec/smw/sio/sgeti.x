include	<s.h>
include	"tb.h"

# S_GETI -- Get integer parameter.

int procedure s_geti (s, key)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword

int	i, ival, imgeti()
pointer	tb, tp, im, cptr
bool	streq()
errchk	s_gkey, skeymap_defi, tbcfnd1, tbegti

begin
#if (streq (key, "DC-FLAG")) {
#call eprintf ("s_geti (s, %s)\n")
#call pargstr (key)
#}
	# Get keyword and possibly array element.
	call s_gkey (s, key, S_STRBUF(s), i)

	# For an image all array elements are the same as a keyword.
	if (S_IM(s) != NULL) {
	    iferr (ival = imgeti (S_IM(s), S_STRBUF(s)))
		call skeymap_defi (S_STRBUF(s), ival)
	    return (ival)
	}

	tb = S_TB(s)
	tp = TB_TP(tb)
	im = TB_IM(tb)

	# If there is no array specification return the keyword value.
	if (i == 0) {
	    iferr (ival = imgeti (im, S_STRBUF(s)))
		call skeymap_defi (S_STRBUF(s), ival)
#if (streq (key, "DC-FLAG")) {
#call eprintf ("s_geti (s, %s) = %d\n")
#call pargstr (key)
#call pargi (ival)
#}
	    return (ival)
	}

	# Look for a column.  If there is no column look in the header.
	call skeymap_key (S_STRBUF(s), TB_KBUF(tb), TB_LENSTR)
	call tbcfnd1 (tp, TB_KBUF(tb), cptr)
	if (cptr != NULL) {
	    call tbegti (tp, cptr, i, ival)
	    return (ival)
	} else {
	    if (streq (S_STRBUF(s), "APNUM"))
		return (i)
	    else {
		iferr (ival = imgeti (im, S_STRBUF(s)))
		    call skeymap_defi (S_STRBUF(s), ival)
		return (ival)
	    }
	}
end
