include	<error.h>
include	<syserr.h>

define	DEBUG		false


# Symbol table definitions.
define	LEN_INDEX	32		# Length of symtab index
define	LEN_STAB	2048		# Length of symtab string buffer
define	SZ_SBUF		128		# Size of symtab string buffer

define	SZ_KEY		2047		# Size of translation symbol name
define	SZ_RNG		79		# Size of default string
define	SYMLEN		200		# Length of symbol structure

# Symbol table entry structure.
define	INSTID		Memc[P2C($1)]		# ID
define	DISP		Memc[P2C($1)+40]	# Dispersion range list
define	SPEC		Memc[P2C($1)+80]	# Primary spectrum range list
define	ERR		Memc[P2C($1)+120]	# Error range list
define	ASSOC		Memc[P2C($1)+160]	# Associated range list


# INSTMAP_OPEN -- Open instrument file and map to a symbol table.

procedure instmap_open ()

int	fd, open(), fscan(), nscan(), errcode(), stpstr()
pointer	sym, stopen(), stenter(), strefsbuf(), 

pointer	stp			# Symbol table
pointer	key			# String buffer
data	stp/NULL/
common	/instmapcom/ stp, key

begin
	# Return if symbol table is already open.
	if (stp != NULL)
	    return

	# Create an empty symbol table.  The key pointer may be used
	# even if no instrument map file is found.

	call malloc (key, SZ_KEY, TY_CHAR)
	call clgstr ("sptabledb", Memc[key], SZ_KEY)
	stp = stopen (Memc[key], LEN_INDEX, LEN_STAB, SZ_SBUF)

	# Return if file not found.
	iferr (fd = open (Memc[key], READ_ONLY, TEXT_FILE)) {
	    call stclose (stp)
	    if (errcode () != SYS_FNOFNAME)
		call erract (EA_ERROR)
	    return
	}

	# Read the file and enter the translations in the symbol table.
	while (fscan(fd) != EOF) {
	    call gargwrd (Memc[key], SZ_KEY)
	    if ((nscan() == 0) || (Memc[key] == '#'))
		next
	    call strupr (Memc[key])
	    sym = stenter (stp, Memc[key], SYMLEN)
	    call gargwrd (INSTID(sym), SZ_RNG)
	    call gargwrd (DISP(sym), SZ_RNG)
	    call gargwrd (SPEC(sym), SZ_RNG)
	    call gargwrd (ERR(sym), SZ_RNG)
	    call gargwrd (ASSOC(sym), SZ_RNG)
	}

	# Allocate space for converting strings to upper case.
	call mfree (key, TY_CHAR)
	key = strefsbuf (stp, stpstr (stp, "", SZ_KEY))

	call close (fd)
end


# INSTMAP_CLOSE -- Close the symbol table.

procedure instmap_close ()

pointer	stp			# Symbol table pointer
pointer	key			# String buffer
common	/instmapcom/ stp, key

begin
	if (stp != NULL)
	    call stclose (stp)
	stp = NULL
end


# INSTMAP -- Return the range lists.  These must be freed externally.

procedure instmap (instkey, instid, max_char, ncols, disp, spec, err, assoc)

char	instkey[ARB]		#I Parameter name
char	instid[max_char]	#O Instrument ID
int	max_char		#I Maximum characters in string
int	ncols			#I Number of columns
pointer	disp			#O Dispersion range string
pointer	spec			#O Spectrum range string
pointer	err			#O Error range string
pointer	assoc			#O Assoc range string

bool	streq()
pointer	sym, stfind(), rg_ranges()

pointer	stp			#I Symbol table pointer
pointer	key			# String buffer
common	/instmapcom/ stp, key

errchk	rg_ranges ()

begin
	if (stp != NULL) {
	    call strcpy (instkey, Memc[key], SZ_KEY)
	    call strupr (Memc[key])
	    sym = stfind (stp, Memc[key])
	} else
	    sym = NULL

	if (sym != NULL) {
#if (DEBUG) {
#call eprintf ("%s: %s %s %s %s\n")
#call pargstr (INSTID(sym))
#call pargstr (DISP(sym))
#call pargstr (SPEC(sym))
#call pargstr (ERR(sym))
#call pargstr (ASSOC(sym))
#}
	    call strcpy (INSTID(sym), instid, max_char)
	    if (streq (DISP(sym), "NULL"))
		disp = rg_ranges ("", 1, ncols)
	    else
		disp = rg_ranges (DISP(sym), 1, ncols)
	    if (streq (SPEC(sym), "NULL"))
		spec = rg_ranges ("", 1, ncols)
	    else
		spec = rg_ranges (SPEC(sym), 1, ncols)
	    if (streq (ERR(sym), "NULL"))
		err = rg_ranges ("", 1, ncols)
	    else
		err = rg_ranges (ERR(sym), 1, ncols)
	    if (streq (ASSOC(sym), "NULL"))
		assoc = rg_ranges ("", 1, ncols)
	    else
		assoc = rg_ranges (ASSOC(sym), 1, ncols)
	} else {
	    call strcpy ("unknown", instid, max_char)
	    call clgstr ("tbdisp", Memc[key], SZ_KEY)
	    disp = rg_ranges (Memc[key], 1, ncols)
	    call clgstr ("tbspec", Memc[key], SZ_KEY)
	    spec = rg_ranges (Memc[key], 1, ncols)
	    call clgstr ("tberr", Memc[key], SZ_KEY)
	    err = rg_ranges (Memc[key], 1, ncols)
	    call clgstr ("tbassoc", Memc[key], SZ_KEY)
	    assoc = rg_ranges (Memc[key], 1, ncols)
	}
end
