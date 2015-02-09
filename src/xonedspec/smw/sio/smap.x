include <error.h>
include	<syserr.h>


# S_MAP -- Map a spectrum file.
# This procedure is the entry point to various data formats.
# Currently this includes images and tables.

pointer procedure s_map (fname, mode, arg)

char	fname[ARB]		#I Spectrum file specification
int	mode			#I Spectrum access mode
int	arg			#I Procedure argument
pointer	s			#O spectrum I/O pointer

bool	selector
int	i, skeymap, stridxs(), errcode(), errget()
pointer	err, err1, s_mapim(), s_maptb()
errchk	s_mapim, s_maptb

data	skeymap /NO/

begin	
#call eprintf ("s_map (%s, %d, %d)\n")
#call pargstr (fname)
#call pargi (mode)
#call pargi (arg)
	# Open keyword translation symbol table if needed.
	if (skeymap == NO) {
	    iferr (call skeymap_open ("skeymap"))
		;
	    skeymap = YES
	}

	# Check for an image.
	selector = false
	i = stridxs (":", fname)
	if (i > 0)
	    selector = (fname[i-1]=='c'||fname[i-1]=='r')

	if (!selector) {
	    ifnoerr (s = s_mapim (fname, mode, arg))
		return (s)
	    else {
	        i = errcode ()
		switch (i) {
		case 2, SYS_IKIOPEN:
		    ;
		default:
		     call eprintf ("ERROR CODE: %d\n")
		         call pargi (i)
		    call erract (EA_ERROR)
		}
	    }
	}

	# Map a table.
	ifnoerr (s = s_maptb (fname, mode, arg))
	    return (s)

	# Return an error.
	#call erract (EA_WARN)
	call salloc (err, SZ_LINE, TY_CHAR)
	call salloc (err1, SZ_LINE, TY_CHAR)
	i = errget (Memc[err1], SZ_LINE)
	call sprintf (Memc[err], SZ_LINE,
	    "Cannot open spectrum (%s)\n  %s")
	    call pargstr (fname)
	    call pargstr (Memc[err1])
	call error (1, Memc[err])
end
