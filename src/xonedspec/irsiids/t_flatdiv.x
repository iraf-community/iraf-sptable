include	<imhdr.h>
include	<smw.h>
include	<error.h>

define	MAX_NR_BEAMS	100	# Max number of instrument apertures

# T_FLATDIV -- Divide by a flat field spectrum. This is basically
#  a simple division of two vectors but with the following
#  additional functions:
#
#	1. Check the processing flag of the input spectra to avoid
#	   double processing, and set the flag if the processing is
#	   performed.
#	2. Trap division by zero errors
#	3. Optionally apply coincidence corrections

procedure t_flatdiv ()

int	root, start_rec
int	nrecs
int	len_flat
int	ccmode, qd_flag
real	dtime
real	power
bool	coincidence
pointer	sp, image, str, ofile, flat, recs, bstat, flatsp, im

int	clpopni(), clgeti(), clgwrd(), s_geti()
int	get_next_image(), decode_ranges()
real	clgetr()
bool	clgetb()
pointer	s_map()
errchk	get_flatsp

begin
	call smark (sp)
	call salloc (image, SZ_FNAME, TY_CHAR)
	call salloc (str, SZ_LINE, TY_CHAR)
	call salloc (ofile, SZ_FNAME, TY_CHAR)
	call salloc (flat, SZ_FNAME, TY_CHAR)
	call salloc (recs, 300, TY_INT)
	call salloc (bstat, MAX_NR_BEAMS, TY_INT)

	# Open input file name template
	root   = clpopni ("input")

	# Get range specification if any
	call clgstr ("records", Memc[str], SZ_LINE)
	if (decode_ranges (Memc[str], Memi[recs], 100, nrecs) == ERR)
	    call error (0, "Bad range specification")

	# Get rootname for output files and starting record
	# Subtract 1 from start_rec because 1 will be added later.
	call clgstr ("output", Memc[ofile], SZ_FNAME)
	start_rec = clgeti ("start_rec") - 1

	# Get flat field spectrum root name
	call clgstr ("flat_file", Memc[flat], SZ_FNAME)

	# Apply coincidence corrections?
	coincidence = clgetb ("coincor")
	if (coincidence) {
	    ccmode = clgwrd ("ccmode", Memc[str], SZ_LINE, ",photo,iids,")
	    dtime  = clgetr ("deadtime")
	    power = clgetr ("power")
	}

	# Initialize beam number status
	call init_bs (Memi[bstat])

	# Initialize range decoder
	call reset_next_image ()

	# Loop over all input images - divide and make new image.
	# The output record number is incremented in all cases.
	while (get_next_image (root, Memi[recs], nrecs, Memc[image],
	    SZ_FNAME) != EOF) {
	    start_rec = start_rec + 1

	    # Open image
	    iferr (im = s_map (Memc[image], READ_ONLY, 0)) {
		call erract (EA_WARN)
		next
	    }

	    # Get header
	    iferr (qd_flag = s_geti (im, "QD-FLAG"))
		qd_flag = -1
	    
	    # Verify divide flag
	    if (qd_flag != 0) {

		# Get flat field spectrum if needed
		call get_flatsp (im, flatsp, Memc[flat], Memi[bstat], len_flat)

		# Calibrate the current spectrum and make a calibrated version
		call divide (im, flatsp, len_flat, Memc[image], Memc[ofile],
		    start_rec, coincidence, ccmode, dtime, power)

	    } else {
		call eprintf ("[%s] already divided - ignored\n")
		    call pargstr (Memc[image])
	    }
	}

	# Update record number
	call clputi ("next_rec", start_rec)

	# Free space
	call sfree (sp)
	call clpcls (root)
end

# GET_FLATSP -- Load flat field spectrum for the current beam number

procedure get_flatsp (im, sp, flat_file, beam_stat, len_flat)

pointer	im, sp
char	flat_file[SZ_FNAME]
int	beam_stat[ARB], len_flat

int	i
int	beam, len[MAX_NR_BEAMS]
char	sfname[SZ_FNAME]
pointer	flatsp[MAX_NR_BEAMS], imflat

int	strlen(), s_geti()
pointer	s_gsr(), s_map()
errchk	s_map

begin
	# Determine beam number.

	iferr (beam = s_geti (im, "BEAM-NUM"))
	    beam = 0
	beam = beam + 1

	# Validate beam number
	if (beam < 1 || beam > MAX_NR_BEAMS) {
	    call eprintf (" Beam number out of range: %d - using 0\n")
		call pargi (beam)
	    beam = 1
	}

	# Has this beam already been loaded?
	if (IS_INDEFI (beam_stat[beam])) {

	    # Create file name
	    call strcpy (flat_file, sfname, SZ_FNAME)

	    # Flat field file names have beam number appended
	    call sprintf (sfname[strlen(sfname)+1], SZ_FNAME, ".%04d")
		call pargi (beam-1)

	    # Open spectrum
	    imflat = s_map (sfname, READ_ONLY, 0)

	    # Allocate space for this beam's sensitivity spectrum
	    call salloc (flatsp[beam], S_NDISP(imflat), TY_REAL)

	    # Copy pixels into space
	    call amovr (Memr[s_gsr(imflat,1,1)], Memr[flatsp[beam]],
		S_NDISP(imflat))

	    # Must be careful that no division by zero occurs.
	    do i = 1, S_NDISP(imflat) {
		if (Memr[flatsp[beam]+i-1] == 0.0)
		    Memr[flatsp[beam]+i-1] = 1.0
	    }

	    # Mark this beam accounted for
	    beam_stat[beam] = 1
	    len[beam] = S_NDISP(imflat)

	    call s_unmap (imflat)
	}

	# Point to the spectrum
	sp = flatsp[beam]
	len_flat = len[beam]

end

# DIVIDE -- Perform the division and create new spectrum

procedure divide (im, flat, len_flat, ifile, ofile, rec, 
	coincidence, ccmode, dtime, power)

pointer	im, flat
int	len_flat, rec, ccmode
real	dtime, power
char	ifile[ARB], ofile[ARB]
bool	coincidence

real	itm, s_getr()
int	i, co_flag, s_geti()
int	ncols, nlines
char	calfname[SZ_FNAME], original[SZ_FNAME]
pointer	imcal, rawpix, calpix

pointer	s_map(), s_psr(), s_gsr()

begin
	# Find smallest length of the two possible spectra
	ncols = min (S_NDISP(im), len_flat)

	# Create new spectrum.  Make up a name
	call sprintf (calfname, SZ_FNAME, "%s.%04d")
	    call pargstr (ofile)
	    call pargi (rec)

	call xt_mkimtemp (ifile, calfname, original, SZ_FNAME)
	imcal = s_map (calfname, NEW_COPY, im)

	S_NDIM(imcal) = S_NDIM(im)
	S_NDISP(imcal) = ncols
	S_PIXTYPE(imcal) = TY_REAL

	# Check for 2D spectrum
	if (S_NDIM(im) > 1)
	    nlines = S_NSPEC(im)
	else
	    nlines = 1

	# Copy across the image title
	call strcpy (S_TITLE(im), S_TITLE(imcal), SZ_LINE)

	# Operate on the pixels
	do i = 1, nlines {
	    rawpix = s_gsr (im, i, 1)
	    calpix = s_psr (imcal,i, 1)

	    # Apply coincidence correction if needed
	    co_flag = -1
	    if (coincidence) {
		iferr (co_flag = s_geti (im, "CO-FLAG"))
		    ;
	        if (co_flag < 1) {
		    iferr (itm = s_getr (im, "EXPOSURE"))
			iferr (itm = s_getr (im, "ITIME"))
			    iferr (itm = s_getr (im, "EXPTIME"))
				itm = 1.
		    call coincor (Memr[rawpix], Memr[rawpix], ncols,
			itm, co_flag, dtime, power, ccmode)
		}
	    }

	    call adivr (Memr[rawpix], Memr[flat], Memr[calpix], ncols)
	}

	call s_addi (imcal, "QD-FLAG", 0)
	if (co_flag != -1)
	    call s_addi (imcal, "CO-FLAG", co_flag)

	# Send user report
	call printf ("writing [%s]: %s\n")
	    call pargstr (original)
	    call pargstr (S_TITLE(imcal))
	call flush (STDOUT)

	call s_unmap (im)
	call s_unmap (imcal)
	call xt_delimtemp (calfname, original)
end

# INIT_BS -- Initialize beam status flags

procedure init_bs (beam_stat)

int	beam_stat[ARB]

int	i

begin
	do i = 1, MAX_NR_BEAMS
	    beam_stat[i] = INDEFI
end
