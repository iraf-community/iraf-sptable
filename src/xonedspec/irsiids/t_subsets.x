include	<error.h>
include	<imhdr.h>
include	<smw.h>


# T_SUBSETS -- Sub a series of spectra by pairs. A single spectrum
#  is produced for every pair.
#

procedure t_subsets ()

pointer	image
pointer	recstr, ofile
int	root, start_rec, subset
int	nrecs
int	npts, nrem, ifile, tog
real	expo, wtsum
pointer	sp, recs, im[2], cur_pix, sp_sum

real	s_getr()
int	clpopni(), clgeti()
int	get_next_image(), decode_ranges()
pointer	s_map(), s_gsr()

begin
	call smark (sp)
	call salloc (image, SZ_FNAME, TY_CHAR)
	call salloc (ofile, SZ_FNAME, TY_CHAR)
	call salloc (recstr, SZ_LINE, TY_CHAR)
	call salloc (recs, 300, TY_INT)

	# Open input file name template
	root   = clpopni ("input")

	# Get range specification if any
	call clgstr ("records", Memc[recstr], SZ_LINE)
	if (decode_ranges (Memc[recstr], Memi[recs], 100, nrecs) == ERR)
	    call error (0, "Bad range specification")

	# Get rootname for output files and starting record
	call clgstr ("output", Memc[ofile], SZ_FNAME)
	start_rec = clgeti ("start_rec")

	# Initialize range decoder
	call reset_next_image ()

	#Initialize file counter
	ifile = 0

	# Set weighting value needed by spectrum writer
	wtsum = 1.0

	# Define subset of operation is a pair
	subset = 2

	# Loop over all input images by subsets
	while (get_next_image (root, Memi[recs], nrecs, Memc[image], 
	    SZ_FNAME) != EOF) {

	    # Get toggle value
	    tog = mod (ifile, 2) + 1

	    # Open image
	    iferr (im[tog] = s_map (Memc[image], READ_ONLY, 0)) {
		call erract (EA_WARN)
		next
	    }

	    # Load data
	    cur_pix = s_gsr (im[tog], 1, 1)

	    # Allocate space for the sum
	    if (mod (ifile,2) == 0) {
		npts = S_NDISP(im[tog])
		call calloc (sp_sum, npts, TY_REAL)

		# Zero exposure counter
		expo = 0.0

		# Add first spectrum
	        call amovr (Memr[cur_pix], Memr[sp_sum], npts)

		iferr (expo = s_getr (im[tog], "EXPOSURE"))
		    iferr (expo = s_getr (im[tog], "ITIME"))
			iferr (expo = s_getr (im[tog], "EXPTIME"))
			    expo = 1

	        call printf ("[%s] added\n")
		    call pargstr (Memc[image])
		call flush (STDOUT)

	    } else {
		# Subtract second spectrum
		call asubr (Memr[sp_sum], Memr[cur_pix], Memr[sp_sum], 
		    min (npts, S_NDISP(im[tog])))
		call printf ("[%s] subtracted\n")
		    call pargstr (Memc[image])
		call flush (STDOUT)
		call s_unmap (im[2])

		call wrt_set (Memr[sp_sum], subset, im[1], Memc[ofile],
		    start_rec, expo, wtsum, -1)
		call mfree (sp_sum, TY_REAL)
	    }

	    ifile = ifile + 1
	}
	# Check that there are no remaining spectra in an unfulfilled subset
	nrem = mod (ifile, 2)
	if (nrem != 0) {
	    call mfree (sp_sum, TY_REAL)

	    call eprintf ("Unfulfilled pair ignored\n")
	}

	# Update record number
	call clputi ("next_rec", start_rec)

	# Free space
	call sfree (sp)
	call clpcls (root)
end
