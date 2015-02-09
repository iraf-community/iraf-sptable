include	<s.h>
include	"tb.h"

# S_DELF -- Delete a parameter.  It is an error if the field does not exist.

procedure s_delf (s, key)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword

#int	dtype, parnum
pointer	tb

errchk	imdelf

begin
	if (S_IM(s) != NULL) {
	    call imdelf (S_IM(s), key)
	    return
	}

	tb = S_TB(s)
	#call tbhfkr (TB_TP(tb), key, dtype, TB_SBUF(tb), parnum)
	#if (parnum == 0) {
	#    call sprintf (TB_SBUF(tb), TB_LENSTR, "Keyword `%s' not found (%s)")
	#	call pargstr (key)
	#	call pargstr (S_FILE(s))
	#    call error (1, TB_SBUF(tb))
	#}
	#call tbhdel (TB_TP(tb), parnum)
	call imdelf (TB_IM(tb), key)
end
