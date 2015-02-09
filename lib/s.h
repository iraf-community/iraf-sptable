# Spectrum I/O definitions.

define  S_MAXDIM                3

define	S_LENSTR	99		# Lengths of strings
define	S_LEN		214		# Length of SIO structure

define	S_FILE		Memc[P2C($1)]	# Spectrum file name
define	S_TBCOLS	Memc[P2C($1+50)]# Table columns
define  S_TITLE        	Memc[P2C($1+100)]# Spectrum file title
define  S_STRBUF       	Memc[P2C($1+150)]# String buffer
define	S_NDIM		Memi[$1+200]	# Logical dim of spectrum file
define	S_PDIM		Memi[$1+201]	# Physical dim of spectrum file
define	S_NDISP		Memi[$1+202]	# Number of dispersion points
define	S_NSPEC		Memi[$1+203]	# Number of spectra
define	S_NAUX		Memi[$1+204]	# Number of auxilary elements
define  S_PIXTYPE       Memi[$1+205]	# Pixel type of spectral data
define  S_DTYPE         Memi[$1+206]	# Dispersion type
define  S_W             Memd[P2D($1+208)]	# Linear wavelength origin
define  S_DW            Memd[P2D($1+210)]	# Linear dispersion

define	S_IM		Memi[$1+212]	# IMIO pointer for images
define	S_TB		Memi[$1+213]	# Table pointer for tables


# This is a temporary procedure mapping for experimenting.

# The following require an image pointer.
#define	s_accf		imaccf
#define	s_addd		imaddd
#define	s_addi		imaddi
#define	s_addr		imaddr
#define	s_astr		imastr
#define	s_delf		imdelf
#define	s_flush		imflush
#define	s_getd		imgetd
#define	s_geti		imgeti
#define	s_getr		imgetr
#define	s_gsr		imgl3r
#define	s_gs3r		imgs3r
#define	s_gstr		imgstr
#define	s_map		immap
#define	s_ofnl		imofnl
#define	s_psr		impl3r
#define	s_ps3r		imps3r
#define	s_seti		imseti
#define	s_unmap		imunmap

# The following do not use an image pointer.
#define	s_access	imaccess
#define	s_delete	imdelete
#define	s_gcluster	imgcluster
#define	s_gimage	imgimage
#define	s_gsection	imgsection
#define s_rename	imrename
#define	s_tclose	imtclose
#define	s_tgetim	imtgetim
#define	s_topen		imtopen
#define	s_topenp	imtopenp
#define	s_trew		imtrew

# The following have a modified argument list.
#define	s_mwopens	mw_openim
#define	s_mwsaves	mw_saveim
#define	s_gnfn		imgnfn
#define	s_cfnl		imcfnl

#define	S_MAXDIM		3
#
#define	S_TITLE		IM_TITLE($1)
#define	S_NDIM		IM_NDIM($1)
#define	S_NDISP		IM_LEN($1,1)
#define	S_NSPEC		IM_LEN($1,2)
#define	S_NAUX		IM_LEN($1,3)
#define	S_PIXTYPE	IM_PIXTYPE($1)
#
#define	S_FILE		IM_HDRFILE($1)
#define	S_PDIM		IM_NPHYSDIM($1)
