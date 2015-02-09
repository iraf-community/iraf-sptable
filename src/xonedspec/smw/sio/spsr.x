include	<s.h>
include	"tb.h"

# S_PSR -- Put spectrum.

pointer procedure s_psr (s, l, b)

pointer	s			#I Spectrum I/O pointer
int	l			#I Spectrum line number
int	b			#I Auxilary number

pointer	impl3r()
errchk	impl3r

begin	
	if (S_IM(s) != NULL)
	    return (impl3r (S_IM(s), l, b))

	call error (1, "S_PSR: Not implemented")
end
