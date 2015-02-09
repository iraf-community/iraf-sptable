include	<s.h>
include	"tb.h"


# S_GP3R -- Put section.

pointer procedure s_ps3r (s, c1, c2, l1, l2, b1, b2)

pointer	s			#I Spectrum I/O pointer
int	c1, c2			#I Columns
int	l1, l2			#I Lines
int	b1, b2			#I Bands

pointer	imps3r()
errchk	imps3r

begin	
	if (S_IM(s) != NULL)
	    return (imps3r (S_IM(s), c1, c2, l1, l2, b1, b2))

	call error (1, "SPS3R: Not implemented")
end
