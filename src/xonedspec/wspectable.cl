# WSPECTABLE -- Write a 1D image spectrum as an ascii table file.
# This simply uses HFIX/WTABHDR to write the header and
# formats the wavelength/flux data using IMTAB.

procedure wspectable (input, output)

string	input			{prompt="Input list of image spectra"}
string	output			{prompt="Output list of text tables"}
bool	header = yes		{prompt="Include header?"}
string	wformat = ""		{prompt="Wavelength format"}

begin
    int		ndim
    file	tmp
    string	units, spec, specin, specout, spectmp

    spec = mktemp ("wspectable")
    specin = spec // "in.tmp"
    specout = spec // "out.tmp"
    spectmp = spec // ".tmp"

    # Expand the input and output image templates and include naxis.
    hselect (input, "$I,naxis", yes, > specin)
    sections (output, option="fullname", > specout)
    join (specin, specout, output=spec, delim=" ", shortest=yes, verbose=yes)
    delete (specin, verify=no)
    delete (specout, verify=no)

    # For each input spectrum check the dimensionality.  Extract the header
    # with HFIX+WTABHDR if desired and then use IMTAB to extract the
    # wavelengths and fluxes.

    list = spec
    while (fscan (list, specin, ndim, specout) != EOF) {
	if (ndim != 1) {
	    print ("WARNING: "//specin//" is not one dimensional")
	    next
	}
	if (strstr (".fits", specout) > 0) {
	    if (header)
		hfix (specin, command="wtabhdr $fname "//spectmp, update-)
	    imtab (specin, spectmp, "flux", pname="wave", wcs="world",
		formats="", tbltype="default")
	    tcopy (spectmp, specout, v-)
	    delete (spectmp, v-)
	} else {
	    if (header)
		hfix (specin, command="wtabhdr $fname "//specout, update-)
	    imtab (specin, specout, "flux", pname="wave", wcs="world",
		formats="", tbltype="default")
	}

	# Try and set the units.
	units = ""
	hselect (specin, "WAT1*", yes) | translit ("STDIN", '"', del+) |
	    words | match ("units", stop-) | scan (units)
	if (units != "") {
	    units = substr (units, stridx("=",units)+1, 99)
	    tchcol (specout, "wave1", "", "", units, v-)
	}
    }
    list=""; delete (spec, verify=no)
end
