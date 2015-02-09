include	<s.h>
include	"tb.h"

include	<error.h>

# S_ASTR -- Add string parameter.

procedure s_astr (s, key, value)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword
char	value[ARB]		#I Value

begin
	if (S_IM(s) != NULL) {
	    call imastr (S_IM(s), key, value)
	    return
	}

	iferr (call tbhadt (TB_TP(S_TB(s)), key, value))
	    ;
	call imastr (TB_IM(S_TB(s)), key, value)
end
