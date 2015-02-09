include	<s.h>
include	"tb.h"

# S_GAP -- Get spectrum index corresponding to the specified aperture.

procedure s_gap (s, ap, index)

pointer	s			#I Spectrum I/O pointer
int	ap			#I Aperture
int	index			#O Index

int	s_geti()
errchk	s_geti

begin
	do index = 1, S_NSPEC(s) {
	    call sprintf (S_STRBUF(s), S_LENSTR, "APNUM[%d]")
		call pargi (index)
	    if (ap == s_geti (s, S_STRBUF(s)))
		return
	}

	call error (2, "Aperture not found")
end
