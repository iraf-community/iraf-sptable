# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<s.h>

# S_MWSAVES -- Save the current MWCS in a spectrum.

procedure s_mwsaves (mw, s)

pointer	mw				#I pointer to MWCS descriptor
pointer	s				#I pointer to spectrum descriptor

begin
#call eprintf ("s_mwsaves: s=%d im=%d\n")
#call pargi (s)
#call pargi (S_IM(s))
	if (S_IM(s) != NULL) {
	    call mw_saveim (mw, S_IM(s))
	    return
	}

	call error (1, "S_MWSAVES: Not yet implemented")
end
