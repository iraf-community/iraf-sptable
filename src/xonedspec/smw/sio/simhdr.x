include	<imhdr.h>
include	<imio.h>
include	<tbset.h>


# S_IMHDR -- Create a minimal IMIO header structure.
# Use mfree to free the structure.

pointer procedure s_imhdr (ndim, len_hdr)

int	ndim			#I dimension
int	len_hdr			#I length of user fields
pointer	im			#O IMIO pointer 

int	len_imhdr
errchk	malloc

begin
	# Allocate buffer for descriptor.
	len_imhdr = LEN_IMHDR + max (MIN_LENUSERAREA, len_hdr) / SZ_STRUCT
	call calloc (im, LEN_IMDES + len_imhdr + 1, TY_STRUCT)

	# Initialize the image descriptor structure.
	call strcpy ("imhdr", IM_NAME(im), SZ_IMNAME)
	IM_LENHDRMEM(im) = len_imhdr
	IM_HDRLEN(im) = len_imhdr
	IM_UABLOCKED(im) = -1
	IM_NDIM(im) = ndim
	IM_NPHYSDIM(im) = ndim

	return (im)
end


# S_IM2TB -- Copy image header to table header.

procedure s_im2tb (im, tp)

pointer	im			#I Input image pointer
pointer	tp			#I Output table pointer

int	i, j, list, len
int	ival, imgeti()
double	dval, imgetd()
bool	bval, imgetb()
pointer	sp, key, str
int	imofnlu(), imgnfn(), imgftype(), strncmp(), strlen()

string	exclude	"|DATAMIN|DATAMAX|EXTEND|ORIGIN|DATE|IRAF-TLM|INHERIT|"

begin
	call smark (sp)
	call salloc (key, 8, TY_CHAR)
	call salloc (str, SZ_LINE, TY_CHAR)

	# Copy keywords from the input image header to the table header.
	list = imofnlu (im, "*")
	while (imgnfn (list, Memc[key], 8) != EOF) {
	    # Check for keywords to exclude.
	    bval = false
	    if (strncmp (Memc[key], "i_", 2) == 0)
	        bval = true
	    else {
		len = strlen (Memc[key])
		for (i=2; exclude[i]!=EOS; i=i+1) {
		    if (strncmp (Memc[key], exclude[i], len) == 0 &&
			exclude[i+len] == exclude[1]) {
			bval = true
			break
		    }
		    for (j=i+1; exclude[j]!=exclude[1]; j=j+1) {
		        if (exclude[j] == '*') {
			    if (strncmp (Memc[key], exclude[i], j-i) == 0) {
				bval = true
				break
			    }
			}
		    }
		    if (bval)
		        break
		    i = j
		}
	    }
	    if (bval)
	        next

	    # Add keyword to table header.
	    switch (imgftype (im, Memc[key])) {
	    case TY_INT, TY_LONG:
		ifnoerr (ival = imgeti (im, Memc[key]))
		    call tbhadi (tp, Memc[key], ival)
		else {
		    call imgstr (im, Memc[key], Memc[str], SZ_LINE)
		    call tbhadt (tp, Memc[key], Memc[str])
		}
	    case TY_REAL, TY_DOUBLE:
		ifnoerr (dval = imgetd (im, Memc[key]))
		    call tbhadd (tp, Memc[key], dval)
		else {
		    call imgstr (im, Memc[key], Memc[str], SZ_LINE)
		    call tbhadt (tp, Memc[key], Memc[str])
		}
	    case TY_BOOL:
		ifnoerr (bval = imgetb (im, Memc[key]))
		    call tbhadb (tp, Memc[key], bval)
		else {
		    call imgstr (im, Memc[key], Memc[str], SZ_LINE)
		    call tbhadt (tp, Memc[key], Memc[str])
		}
	    case TY_CHAR:
		call imgstr (im, Memc[key], Memc[str], SZ_LINE)
		call tbhadt (tp, Memc[key], Memc[str])
	    }
	}

	call imcfnl (list)

	call sfree (sp)
end


# S_TB2IM -- Convert table header to image header.

procedure s_tb2im (tp, im)

pointer	tp			#I Table pointer
pointer	im			#I IMIO pointer (previously created)

int	i, j, k, dtype, len
pointer	sp, key, str
int	ival
bool	bval
double	dval

int	strlen(), strncmp()
errchk	tbhgnp, imaddb, imaddi, imaddd, imastr

string	exclude	"|XTENSION|BITPIX|NAXIS*|PCOUNT|GCOUNT|TFIELDS|TFORM*|TDIM*|\
		|TTYPE*|TDISP*|TNULL*|EXTNAME|DATE|INHERIT|END|"

begin	
	call smark (sp)
	call salloc (key, SZ_KEYWORD, TY_CHAR)
	call salloc (str, SZ_PARREC, TY_CHAR)

	do k = 1, ARB {
	    iferr (call tbhgnp (tp, k, Memc[key], dtype, Memc[str]))
		break
	    if (Memc[key] == EOS)
		break

	    # Check for keywords to exclude.
	    bval = false
	    len = strlen (Memc[key])
	    for (i=2; exclude[i]!=EOS; i=i+1) {
		if (strncmp (Memc[key], exclude[i], len) == 0 &&
		    exclude[i+len] == exclude[1]) {
		    bval = true
		    break
		}
		for (j=i+1; exclude[j]!=exclude[1]; j=j+1) {
		    if (exclude[j] == '*') {
			if (strncmp (Memc[key], exclude[i], j-i) == 0) {
			    bval = true
			    break
			}
		    }
		}
		if (bval)
		    break
		i = j
	    }
	    if (bval)
	        next

	    switch (dtype) {
	    case TY_BOOL:
		bval = (Memc[str] == 'T')
		call imaddb (im, Memc[key], bval)
	    case TY_INT, TY_LONG:
		call sscan (Memc[str])
		call gargi (ival)
		call imaddi (im, Memc[key], ival)
	    case TY_REAL, TY_DOUBLE:
		call sscan (Memc[str])
		call gargd (dval)
		call imaddd (im, Memc[key], dval)
	    case TY_CHAR:
		if (Memc[str] == '\'') {
		    Memc[str+strlen(Memc[str])-1] = EOS
		    call imastr (im, Memc[key], Memc[str+1])
		} else
		    call imastr (im, Memc[key], Memc[str])
	    }
	}

	call sfree (sp)
end


# S_IM2IM -- Copy image header to image header.

procedure s_im2im (im1, im2)

pointer	im1			#I Input image pointer
pointer	im2			#I Output image pointer

int	i, j, list, len
int	ival, imgeti()
double	dval, imgetd()
bool	bval, imgetb()
pointer	sp, key, str
int	imofnlu(), imgnfn(), imgftype(), strncmp(), strlen()

string	exclude	"|DATAMIN|DATAMAX|EXTEND|ORIGIN|DATE|IRAF-TLM|"

begin
	call smark (sp)
	call salloc (key, 8, TY_CHAR)
	call salloc (str, SZ_LINE, TY_CHAR)

	# Copy keywords from the input image header to the output image header.
	list = imofnlu (im1, "*")
	while (imgnfn (list, Memc[key], 8) != EOF) {
	    # Check for keywords to exclude.
	    bval = false
	    if (strncmp (Memc[key], "i_", 2) == 0)
	        bval = true
	    else {
		len = strlen (Memc[key])
		for (i=2; exclude[i]!=EOS; i=i+1) {
		    if (strncmp (Memc[key], exclude[i], len) == 0 &&
			exclude[i+len] == exclude[1]) {
			bval = true
			break
		    }
		    for (j=i+1; exclude[j]!=exclude[1]; j=j+1) {
		        if (exclude[j] == '*') {
			    if (strncmp (Memc[key], exclude[i], j-i) == 0) {
				bval = true
				break
			    }
			}
		    }
		    if (bval)
		        break
		    i = j
		}
	    }

	    if (bval) {
		if (strncmp(Memc[key],"i_naxis",7)==0 && Memc[key+7]!=EOS) {
		    i = Memc[key+7] - '0'
		    ival = imgeti (im1, Memc[key])
		    if (ival > 0) {
			call sprintf (Memc[key], 8, "CRMIN%d")
			    call pargi (i)
			call imaddi (im2, Memc[key], 1)
			call sprintf (Memc[key], 8, "CRMAX%d")
			    call pargi (i)
			call imaddi (im2, Memc[key], ival)
		    }
		}
	        next
	    }

	    # Add keyword to table header.
	    switch (imgftype (im1, Memc[key])) {
	    case TY_INT, TY_LONG:
		ifnoerr (ival = imgeti (im1, Memc[key])) {
		    call imaddi (im2, Memc[key], ival)
		} else {
		    call imgstr (im1, Memc[key], Memc[str], SZ_LINE)
		    call imastr (im2, Memc[key], Memc[str])
		}
	    case TY_REAL, TY_DOUBLE:
		ifnoerr (dval = imgetd (im1, Memc[key]))
		    call imaddd (im2, Memc[key], dval)
		else {
		    call imgstr (im1, Memc[key], Memc[str], SZ_LINE)
		    call imastr (im2, Memc[key], Memc[str])
		}
	    case TY_BOOL:
		ifnoerr (bval = imgetb (im1, Memc[key]))
		    call imaddb (im2, Memc[key], bval)
		else {
		    call imgstr (im1, Memc[key], Memc[str], SZ_LINE)
		    call imastr (im2, Memc[key], Memc[str])
		}
	    case TY_CHAR:
		call imgstr (im1, Memc[key], Memc[str], SZ_LINE)
		call imastr (im2, Memc[key], Memc[str])
	    }
	}

	call imcfnl (list)

	call sfree (sp)
end
