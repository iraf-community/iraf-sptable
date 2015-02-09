include	<s.h>
include	"tb.h"


# S_GNFN -- Get the next parameter name matching the given template from a
# spectrum parameter database. A prior call to S_OFNL to open the list.

int procedure s_gnfn (s, fn, outstr, maxch)

pointer	s			# spectrum descriptor
pointer	fn			# parameter name list descriptor
char	outstr[ARB]		# output string
int	maxch

int	imgnfn()

begin
	return (imgnfn (fn, outstr, maxch))
end


# S_OFNL -- Open an header parameter name list, either sorted or unsorted.
# A template is a list of patterns delimited by commas.

pointer procedure s_ofnl (s, template, sort)

pointer	s			# spectrum descriptor
char	template[ARB]		# parameter name template
int	sort			# sort flag

pointer	imofnl()

begin
	if (S_IM(s) != NULL)
	    return (imofnl (S_IM(s), template, sort))
	else
	    return (imofnl (TB_IM(S_TB(s)), template, sort))
end


# S_CFNL -- Close the spectrum parameter name list and return all associated
# storage.

procedure s_cfnl (s, fn)

pointer	s			# spectrum descriptor
pointer	fn			# parameter name list descriptor

begin
	call imcfnl (fn)
end
