include	<error.h>
include	<smw.h>

# COEFS --  Convert IIDS/IRS coeffients to IDENTIFY database entry.

procedure t_coefs ()

int	root			# List of input root names
pointer	database		# Output database directory

int	i, nrecs, ncoefs
real	coef
pointer	sp, image, dtname, recs, im, dt

real	s_getr()
int	clpopni(), s_geti(), get_next_image(), decode_ranges()
pointer	s_map(), dtmap1()
errchk	s_getr, dtmap1

begin
	call smark (sp)
	call salloc (image, SZ_LINE, TY_CHAR)
	call salloc (database, SZ_FNAME, TY_CHAR)
	call salloc (dtname, SZ_FNAME, TY_CHAR)
	call salloc (recs, 300, TY_INT)

	root   = clpopni ("input")
	call clgstr ("records", Memc[image], SZ_LINE)
	call clgstr ("database", Memc[database], SZ_LINE)

	if (decode_ranges (Memc[image], Memi[recs], 100, nrecs) == ERR)
	    call error (0, "Bad range specification")

	# Loop over all input images - print name on STDOUT
	call reset_next_image ()
	while (get_next_image (root, Memi[recs], nrecs, Memc[image],
	    SZ_LINE) != EOF) {
	    iferr (im = s_map (Memc[image], READ_ONLY, 0)) {
		call erract (EA_WARN)
		next
	    }

	    iferr (ncoefs = s_geti (im, "DF-FLAG"))
		ncoefs = -1
	    if (ncoefs > 1) {
		call strcpy ("id", Memc[dtname], SZ_FNAME)
		call imgcluster (Memc[image], Memc[dtname+2], SZ_FNAME)
		dt = dtmap1 (Memc[database], Memc[dtname], APPEND)

		call dtptime (dt)
		call dtput (dt, "begin\tidentify %s\n")
		    call pargstr (Memc[image])
		call dtput (dt, "\tid\t%s\n")
		    call pargstr (Memc[image])
		call dtput (dt, "\ttask\tidentify\n")
		call dtput (dt, "\timage\t%s\n")
		    call pargstr (Memc[image])

		# Convert coefficients
		call dtput (dt, "\tcoefficients\t%d\n")
		    call pargi (ncoefs+4)
		call dtput (dt, "\t\t2\n")
		call dtput (dt, "\t\t%1d\n")
		    call pargi (ncoefs)
		call dtput (dt, "\t\t1\n")
		call dtput (dt, "\t\t1024\n")

		do i = 1, ncoefs {
		    call sprintf (Memc[dtname], SZ_FNAME, "DF%d")
			call pargi (i)
		    coef = s_getr (im, Memc[dtname])
		    call dtput (dt, "\t\t%10.4f\n")
			call pargr (coef)
		}

		call dtput (dt, "\n")
		call dtunmap (dt)
	    }

	    call printf ("[%s] %d coefficients written\n")
		call pargstr (Memc[image])
		call pargi (max (0, ncoefs))
	    call flush (STDOUT)
	    call s_unmap (im)
	}

	call clpcls (root)
	call sfree (sp)
end
