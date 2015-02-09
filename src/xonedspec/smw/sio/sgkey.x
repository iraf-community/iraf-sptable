include	<s.h>


# S_GKEY -- Parse keyword for array element.
# Return element of 0 if there is no array element.

procedure s_gkey (s, key, keyroot, element)

pointer	s			#I Spectrum pointer
char	key[ARB]		#I Keyword
char	keyroot[ARB]		#O Keyword root name
int	element			#O Element

int	i, j, ctoi()
pointer	err

begin
	element = 0
	for (i=1; key[i]!=EOS; i=i+1) {
	    if (key[i] == '[') {
		j = i + 1
		if (ctoi (key, j, element) == 0) {
		    call salloc (err, SZ_LINE, TY_CHAR)
		    call sprintf (Memc[err], SZ_LINE,
			"Syntax error in keyword (%s)")
			call pargstr (key)
		    call error (1, Memc[err])
		}
		break
	    }
	    keyroot[i] = key[i]
	}
	keyroot[i] = EOS

	if (element < 0 || element > S_NSPEC(s)) {
	    call salloc (err, SZ_LINE, TY_CHAR)
	    call sprintf (Memc[err], SZ_LINE, "Keyword not found (%s)")
		call pargstr (key)
	    call error (2, Memc[err])
	}
end
