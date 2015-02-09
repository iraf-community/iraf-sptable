include	<error.h>
include	<imhdr.h>
include	<smw.h>


# T_COINCOR -- Apply coincidence corrections to spectra

procedure t_coincor ()

int	root, start_rec, ccmode, npts, nrecs, coflag
real	dtime, power, expo
pointer	sp, image, ofile, str, recs, imin, imout, pixin, pixout

int	clpopni(), clgeti(), clgwrd(), s_geti()
int	get_next_image(), decode_ranges()
real	clgetr(), s_getr()
pointer	s_map(), s_gsr(), s_psr()
errchk	coincor

begin
	# Allocate memory
	call smark (sp)
	call salloc (image, SZ_FNAME, TY_CHAR)
	call salloc (ofile, SZ_FNAME, TY_CHAR)
	call salloc (str, SZ_LINE, TY_CHAR)
	call salloc (recs, 300, TY_INT)

	# Get parameters
	root   = clpopni ("input")
	call clgstr ("output", Memc[ofile], SZ_FNAME)
	if (Memc[ofile] != EOS)
	    start_rec = clgeti ("start_rec")
	ccmode = clgwrd ("ccmode", Memc[str], SZ_LINE, ",photo,iids,")
	dtime = clgetr ("deadtime")
	power = clgetr ("power")
	call clgstr ("records", Memc[str], SZ_LINE)

	# Initialize
	if (decode_ranges (Memc[str], Memi[recs], 100, nrecs) == ERR)
	    call error (0, "Bad range specification")
	call reset_next_image ()

	# Loop over all input images by subsets
	while (get_next_image (root, Memi[recs], nrecs, Memc[image],
	    SZ_FNAME) != EOF) {

	    # Open input image and check coincidence flag
	    iferr (imin = s_map (Memc[image], READ_WRITE, 0)) {
		call erract (EA_WARN)
	        start_rec = start_rec + 1
		next
	    }
	    iferr (coflag = s_geti (imin, "CO-FLAG"))
		coflag = -1
	    if (coflag > 0) {
		call printf ("[%s] already coincidence corrected\n")
		    call pargstr (S_FILE(imin))
		call flush (STDOUT)
		call s_unmap (imin)
		next
	    }

	    # Open output image
	    if (Memc[ofile] != EOS) {
		call sprintf (Memc[str], SZ_LINE, "%s.%04d")
		    call pargstr (Memc[ofile])
		    call pargi (start_rec)
		start_rec = start_rec + 1

		imout = s_map (Memc[str], NEW_COPY, imin)
		S_PIXTYPE (imout) = TY_REAL
	    } else
		imout = imin

	    # Apply coincidence correction
	    pixin = s_gsr (imin, 1, 1)
	    pixout = s_psr (imout, 1, 1)
	    npts = S_NDISP(imin)
	    iferr (expo = s_getr (imin, "EXPOSURE"))
		iferr (expo = s_getr (imin, "ITIME"))
		    iferr (expo = s_getr (imin, "EXPTIME"))
			expo = 1
	    call coincor (Memr[pixin], Memr[pixout], npts, expo, coflag,
		dtime, power, ccmode)

	    # Update flag and write status
	    call s_addi (imout, "CO-FLAG", coflag)
	    call printf ("[%s] --> [%s] %s\n")
		call pargstr (S_FILE(imin))
		call pargstr (S_FILE(imout))
		call pargstr (S_TITLE(imout))
	    call flush (STDOUT)

	    # Close images
	    if (imout != imin)
		call s_unmap (imout)
	    call s_unmap (imin)
	}

	call clputi ("next_rec", start_rec)
	call clpcls (root)
	call sfree (sp)
end
