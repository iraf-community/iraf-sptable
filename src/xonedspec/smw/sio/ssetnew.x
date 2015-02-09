include	<error.h>
include	<imhdr.h>
include	<imio.h>
include	<s.h>

define	CPIM		1	# Make copy from image	
define	CPTB		2	# Make copy from table	

# S_SETNEW -- Set new spectrum.
# This is used when a "NEW_IMAGE" has been opened.

pointer procedure s_setnew (s)

pointer	s			#I spectrum I/O pointer

pointer	im

begin	
	# For now this is just for an image.

	if (S_IM(s) == NULL)
	    return

	im = S_IM(s)
	IM_NDIM(im) = S_NDIM(s)
	IM_NPHYSDIM(im) = S_PDIM(s)
	IM_LEN(im,1) = S_NDISP(s)
	IM_LEN(im,2) = S_NSPEC(s)
	IM_LEN(im,3) = S_NAUX(s)
	IM_PIXTYPE(im) = S_PIXTYPE(s)
end
