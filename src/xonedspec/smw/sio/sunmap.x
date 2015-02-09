include	<s.h>
include	"tb.h"


# S_UNMAP -- Unmap a spectrum file.

procedure s_unmap (s)

pointer	s			#I Spectrum I/O pointer

pointer	im, tp

begin	
	# Close image.
	if (S_IM(s) != NULL)
	    call imunmap (S_IM(s))

	# Close table.
	if (S_TB(s) != NULL) {
	    call tbtclo (TB_TP(S_TB(s)))

	    # Update table header with image header.
	    im = TB_IM(S_TB(s))
	    tp = TB_TP(S_TB(s))
	    #if (im != NULL)
	    #    call s_im2tb (im, tp)

	    # Free memory.
	    call mfree (TB_IM(S_TB(s)), TY_STRUCT)
	    call mfree (TB_BUF(S_TB(s)), TY_REAL)
	    call mfree (TB_NULL(S_TB(s)), TY_INT)
	    call mfree (S_TB(s), TY_STRUCT)
	}

	# Free pointer.
	call mfree (s, TY_STRUCT)
end
