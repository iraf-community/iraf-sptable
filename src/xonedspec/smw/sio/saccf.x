include	<s.h>
include	"tb.h"

# S_ACCF -- Test if a parameter exists.

int procedure s_accf (s, key)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword
int	stat			#O Status

int	i, imaccf()
pointer	tb, tp, im, cptr
bool	streq()

begin
#call eprintf ("s_accf (%d, %s)\n")
#call pargi (s)
#call pargstr (key)
	# Get keyword and possibly array element.
	call s_gkey (s, key, S_STRBUF(s), i)
#call eprintf ("s_accf 5\n")

	# For an image all array elements are the same as the keyword.
	if (S_IM(s) != NULL) {
#call eprintf ("s_accf 7\n")
	    stat = imaccf (S_IM(s), S_STRBUF(s))
	    if (stat == NO) {
		ifnoerr (call skeymap_defs (S_STRBUF(s), S_STRBUF(s), S_LENSTR))
		    stat = YES
	    }
	    return (stat)
	}

	tb = S_TB(s)
	tp = TB_TP(tb)
	im = TB_IM(tb)

#call eprintf ("s_accf 10\n")
	# If there is no array specification check the header.
	if (i == 0) {
	    stat = imaccf (im, S_STRBUF(s))
	    if (stat == NO) {
		ifnoerr (call skeymap_defs (S_STRBUF(s), S_STRBUF(s), S_LENSTR))
		    stat = YES
	    }
	    return (stat)
	}

#call eprintf ("s_accf 20\n")
	# Look for a column.  If there is no column look in header.
	call skeymap_key (S_STRBUF(s), TB_KBUF(tb), TB_LENSTR)
	call tbcfnd1 (tp, TB_KBUF(tb), cptr)
	if (cptr != NULL)
	    return (YES)
	else {
	    if (streq (S_STRBUF(s), "APNUM"))
		return (YES)
	    else {
		stat = imaccf (im, S_STRBUF(s))
		if (stat == NO) {
		    ifnoerr (call skeymap_defs (S_STRBUF(s), S_STRBUF(s),
			S_LENSTR))
			stat = YES
		}
		return (stat)
	    }
	}
end
