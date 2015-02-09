include	<error.h>
include	<syserr.h>


# Symbol table definitions.
define	LEN_INDEX	32		# Length of symtab index
define	LEN_STAB	1024		# Length of symtab string buffer
define	SZ_SBUF		128		# Size of symtab string buffer

define	SZ_NAME		79		# Size of translation symbol name
define	SZ_DEFAULT	79		# Size of default string
define	SYMLEN		80		# Length of symbol structure

# Symbol table entry structure.
define	NAME		Memc[P2C($1)]		# Translation name for symbol
define	DEFAULT		Memc[P2C($1+40)]	# Default value of parameter


# SKEYMAP_OPEN -- Open keyword translation file and map to a symbol table.

procedure skeymap_open (fname)

char	fname[ARB]		#I Image header map file

int	fd, open(), fscan(), nscan(), errcode(), stpstr()
pointer	sym, stopen(), stenter(), strefsbuf(), 

pointer	stp			# Symbol table
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	# Create an empty symbol table.  The name pointer may be used
	# even if not definition file is found.

	stp = stopen (fname, LEN_INDEX, LEN_STAB, SZ_SBUF)
	call malloc (name, SZ_NAME, TY_CHAR)

	# Return if file not found.
	iferr (fd = open (fname, READ_ONLY, TEXT_FILE)) {
	    call stclose (stp)
	    if (errcode () != SYS_FNOFNAME)
		call erract (EA_ERROR)
	    return
	}


	# Read the file and enter the translations in the symbol table.
	while (fscan(fd) != EOF) {
	    call gargwrd (Memc[name], SZ_NAME)
	    if ((nscan() == 0) || (Memc[name] == '#'))
		next
	    call strupr (Memc[name])
	    sym = stenter (stp, Memc[name], SYMLEN)
	    call gargwrd (NAME(sym), SZ_NAME)
	    call strupr (NAME(sym))
	    call gargwrd (DEFAULT(sym), SZ_DEFAULT)
	}

	# Allocate space for converting strings to upper case.
	call mfree (name, TY_CHAR)
	name = strefsbuf (stp, stpstr (stp, "", SZ_NAME))

	call close (fd)
end


# SKEYMAP_CLOSE -- Close the symbol table.

procedure skeymap_close ()

pointer	stp			# Symbol table pointer
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	if (stp != NULL)
	    call stclose (stp)
end


# SKEYMAP_KEY -- Return the translated keyword.

procedure skeymap_key (parameter, str, max_char)

char	parameter[ARB]		#I Parameter name
char	str[max_char]		#I String containing mapped parameter name
int	max_char		#I Maximum characters in string

pointer	sym, stfind()

pointer	stp			#I Symbol table pointer
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	if (stp != NULL) {
	    call strcpy (parameter, Memc[name], SZ_NAME)
	    call strupr (Memc[name])
	    sym = stfind (stp, Memc[name])
	} else
	    sym = NULL

	if (sym != NULL)
	    call strcpy (NAME(sym), str, max_char)
	else
	    call strcpy (parameter, str, max_char)
end


# SKEYMAP_INV -- Return the inverse translation.

procedure skeymap_inv (parameter, str, max_char)

char	parameter[ARB]		# Parameter name
char	str[max_char]		# String containing mapped parameter name
int	max_char		# Maximum characters in string

pointer	sym, sthead(), stnext, stname()
bool	streq()

pointer	stp			#I Symbol table pointer
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	if (stp != NULL) {
	    call strcpy (parameter, Memc[name], SZ_NAME)
	    call strupr (Memc[name])
	    for (sym=sthead(stp); sym!=NULL; sym=stnext(stp,sym)) {
		if (streq (Memc[name], NAME(sym)))
		    break
	    }
	} else
	    sym = NULL

	if (sym != NULL)
	    call strcpy (Memc[stname(stp,sym)], str, max_char)
	else
	    call strcpy (parameter, str, max_char)
end


# SKEYMAP_DEFS -- Get the default value as a string (null string if none).

procedure skeymap_defs (parameter, str, max_char)

char	parameter[ARB]		# Parameter name
char	str[max_char]		# String containing default value
int	max_char		# Maximum characters in string

pointer	sym, stfind()

pointer	stp			#I Symbol table pointer
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	if (stp != NULL) {
	    call strcpy (parameter, Memc[name], SZ_NAME)
	    call strupr (Memc[name])
	    sym = stfind (stp, Memc[name])
	} else
	    sym = NULL

	if (sym != NULL)
	    call strcpy (DEFAULT(sym), str, max_char)
	else {
	    call sprintf (Memc[name], SZ_NAME, "No default value (%s)")
		call pargstr (parameter)
		call error (1, Memc[name])
	}
end


# SKEYMAP_DEFI -- Get the default value as a integer.

procedure skeymap_defi (parameter, ival)

char	parameter[ARB]		#I Parameter name
int	ival			#O Value

int	i, ctoi()
errchk	skeymap_defs

pointer	stp			#I Symbol table pointer
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	call skeymap_defs (parameter, Memc[name], SZ_NAME)

	i = 1
	if (ctoi (Memc[name], i, ival) == 0) {
	    call sprintf (Memc[name], SZ_NAME, "No default value (%s)")
		call pargstr (parameter)
		call error (1, Memc[name])
	}
end


# SKEYMAP_DEFR -- Get the default value as a real.

procedure skeymap_defr (parameter, rval)

char	parameter[ARB]		#I Parameter name
real	rval			#O Value

int	i, ctor()
errchk	skeymap_defs

pointer	stp			#I Symbol table pointer
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	call skeymap_defs (parameter, Memc[name], SZ_NAME)

	i = 1
	if (ctor (Memc[name], i, rval) == 0) {
	    call sprintf (Memc[name], SZ_NAME, "No default value (%s)")
		call pargstr (parameter)
		call error (1, Memc[name])
	}
end


# SKEYMAP_DEFD -- Get the default value as a double.

procedure skeymap_defd (parameter, dval)

char	parameter[ARB]		#I Parameter name
double	dval			#O Value

int	i, ctod()
errchk	skeymap_defs

pointer	stp			#I Symbol table pointer
pointer	name			# String buffer
common	/skymap/ stp, name

begin
	call skeymap_defs (parameter, Memc[name], SZ_NAME)

	i = 1
	if (ctod (Memc[name], i, dval) == 0) {
	    call sprintf (Memc[name], SZ_NAME, "No default value (%s)")
		call pargstr (parameter)
		call error (1, Memc[name])
	}
end
