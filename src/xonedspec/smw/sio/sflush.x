include	<s.h>


# S_FLUSH -- Flush spectrum I/O.

procedure s_flush (s)

pointer	s				# Spectrum I/O pointer

begin
	if (S_IM(s) != NULL)
	    call imflush (S_IM(s))
end
