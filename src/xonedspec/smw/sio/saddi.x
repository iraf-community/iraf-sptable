include	<error.h>
include	<s.h>
include	"tb.h"

# S_ADDI -- Add integer parameter.

procedure s_addi (s, key, value)

pointer	s			#I Spectrum I/O pointer
char	key[ARB]		#I Keyword
int	value			#I Value

begin
	if (S_IM(s) != NULL) {
	    call imaddi (S_IM(s), key, value)
	    return
	}

#if (key[1] == 'D' && key[2] == 'C') {
#call eprintf ("s_addi (s, %s, %d)\n")
#call pargstr (key)
#call pargi (value)
#}
	iferr (call tbhadi (TB_TP(S_TB(s)), key, value))
	    ;
	call imaddi (TB_IM(S_TB(s)), key, value)
end
