include	<s.h>
include	"tb.h"

# S_ADDR -- Add real parameter.

procedure s_addr (s, key, value)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword
real	value			#I Value

begin
	if (S_IM(s) != NULL) {
	    call imaddr (S_IM(s), key, value)
	    return
	}

	iferr (call tbhadr (TB_TP(S_TB(s)), key, value))
	    ;
	call imaddr (TB_IM(S_TB(s)), key, value)
end
