include	<imset.h>
include	<s.h>

# S_SETI -- Set a spectrum I/O parameter of type integer (or pointer).

procedure s_seti (s, param, value)

pointer s			#I image descriptor
int	param			#I parameter to be set
int	value			#I integer value of parameter

#pointer	fname, s_map()
#errchk	s_map, s_unmap

begin
	if (S_IM(s) != NULL) {
	    call imseti (S_IM(s), param, value)
	    return
	}
end
