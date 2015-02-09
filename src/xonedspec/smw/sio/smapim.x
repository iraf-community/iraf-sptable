include	<error.h>
include	<imhdr.h>
include	<imio.h>
include	<s.h>
include	"tb.h"

define	CPIM		1	# Make copy from image	
define	CPTB		2	# Make copy from table	

# S_MAPIM -- Map an image spectrum file.

pointer procedure s_mapim (fname, mode, arg)

char	fname[ARB]		#I Spectrum file specification
int	mode			#I Spectrum access mode
int	arg			#I Procedure argument
pointer	s			#O spectrum I/O pointer

int	cptype
pointer	im, im1, tb1, immap()
errchk	immap, s_setnew

begin	
	# Map an image.  Return on an error; e.g. not an image.

#call eprintf ("s_mapim (%s, %d, %d)\n")
#call pargstr (fname)
#call pargi (mode)
#call pargi (arg)
	switch (mode) {
	case NEW_COPY:
#call eprintf ("s_mapim: 10\n")
	    if (arg == NULL)
	        call error (1, "NEW_COPY reference not specified")

#call eprintf ("s_mapim: 20\n")
	    if (S_IM(arg) != NULL)
		cptype = CPIM
	    else if (S_TB(arg) != NULL)
		cptype = CPTB
	    else
		cptype = 0

	    # Right now the two are the same.
	    switch (cptype) {
	    case CPIM:
#call eprintf ("s_mapim: 30 %d\n")
#call pargi (arg)
		im1 = S_IM(arg)
#call eprintf ("s_mapim: 31 %d\n")
#call pargi (im1)
		im = immap (fname, mode, im1)
		if (IM_NDIM(im) == 0)
		    call error (1, "Reference spectrum not found")

#call eprintf ("s_mapim: 35\n")
		# Allocate and set the spectrum I/O pointer.
		call calloc (s, S_LEN, TY_STRUCT)
		call strcpy (fname, S_FILE(s), S_LENSTR)
		call strcpy (IM_TITLE(im), S_TITLE(s), S_LENSTR)
		S_NDIM(s) = IM_NDIM(im)
		S_PDIM(s) = IM_NPHYSDIM(im)
		S_NDISP(s) = IM_LEN(im,1)
		S_NSPEC(s) = IM_LEN(im,2)
		S_NAUX(s) = IM_LEN(im,3)
		S_PIXTYPE(s) = IM_PIXTYPE(im)
		S_IM(s) = im

	    case CPTB:
#call eprintf ("s_mapim: 40\n")
	        tb1 = S_TB(arg)
		im1 = TB_IM(tb1)
		# Using the table image pointer screws things up for a reason
		# I haven't tracked down.
		#im = immap (fname, mode, im1)
		im = immap (fname, NEW_IMAGE, NULL)
		IM_NDIM(im) = S_NDIM(arg)
		IM_NPHYSDIM(im) = S_PDIM(arg)
		IM_LEN(im,1) = S_NDISP(arg)
		IM_LEN(im,2) = S_NSPEC(arg)
		IM_LEN(im,3) = S_NAUX(arg)
		IM_PIXTYPE(im) = S_PIXTYPE(arg)

		# Allocate and set the spectrum I/O pointer.
		call calloc (s, S_LEN, TY_STRUCT)
		call strcpy (fname, S_FILE(s), S_LENSTR)
		call strcpy (IM_TITLE(im), S_TITLE(s), S_LENSTR)
		S_NDIM(s) = IM_NDIM(im)
		S_PDIM(s) = IM_NPHYSDIM(im)
		S_NDISP(s) = IM_LEN(im,1)
		S_NSPEC(s) = IM_LEN(im,2)
		S_NAUX(s) = IM_LEN(im,3)
		S_PIXTYPE(s) = IM_PIXTYPE(im)
		S_IM(s) = im

	    default:
		call error (1, "Unknown copy type")
	    }

	case NEW_IMAGE:
	    im = immap (fname, mode, NULL)
	    call calloc (s, S_LEN, TY_STRUCT)
	    call strcpy (fname, S_FILE(s), S_LENSTR)
	    S_IM(s) = im

	default:
	    im = immap (fname, mode, NULL)
	    if (IM_NDIM(im) == 0) {
	        call imunmap (im)
		call error (2, "Spectrum not found in image")
	    }

	    # Allocate and set the spectrum I/O pointer.
	    call calloc (s, S_LEN, TY_STRUCT)
	    call strcpy (fname, S_FILE(s), S_LENSTR)
	    call strcpy (IM_TITLE(im), S_TITLE(s), S_LENSTR)
	    S_NDIM(s) = IM_NDIM(im)
	    S_PDIM(s) = IM_NPHYSDIM(im)
	    S_NDISP(s) = IM_LEN(im,1)
	    S_NSPEC(s) = IM_LEN(im,2)
	    S_NAUX(s) = IM_LEN(im,3)
	    S_PIXTYPE(s) = IM_PIXTYPE(im)
	    S_IM(s) = im
	}

#call eprintf ("s_mapim: s=%d, im=%d\n")
#call pargi (s)
#call pargi (S_IM(s))
	return (s)
end
