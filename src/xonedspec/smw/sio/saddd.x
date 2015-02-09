include	<s.h>
include	"tb.h"

# S_ADDD -- Add double parameter.

procedure s_addd (s, key, value)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword
double	value			#I Value

begin
	if (S_IM(s) != NULL) {
	    call imaddd (S_IM(s), key, value)
	    return
	}

	iferr (call tbhadd (TB_TP(S_TB(s)), key, value))
	    ;
	call imaddd (TB_IM(S_TB(s)), key, value)
end
