# Table I/O definitions.

define	TB_LENSTR	199		# Length of strings
define	TB_LEN		(213+$1)

define	TB_TP		Memi[$1]	# Table pointer
define	TB_IM		Memi[$1+1]	# Table header in IMIO pointer
define	TB_BUF		Memi[$1+2]	# Data buffer
define	TB_BUFLEN	Memi[$1+3]	# Data buffer length
define	TB_NULL		Memi[$1+4]	# Data buffer
define	TB_NULLLEN	Memi[$1+5]	# Data buffer
define	TB_KBUF		Memc[P2C($1+6)]	# Keyword buffer
define	TB_SBUF		Memc[P2C($1+106)]	# String buffer

# Column pointers.
define	TB_COORD	Memi[$1+207]	# Coordinate column pointer
define	TB_NROWS	Memi[$1+208]	# Number of rows (1=3D else 2D)
define	TB_NSPEC	Memi[$1+209]	# Number of spectra
define	TB_NASSOC	Memi[$1+210]	# Number of associated spectra
define	TB_NERR		Memi[$1+211]	# Number of error spectra
define	TB_NULL		Memi[$1+212]	# Null flag array
define	TB_SPEC		Memi[$1+$2+212]	# Spectrum array column pointers
