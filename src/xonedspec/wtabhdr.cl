# WTABHDR -- Create an NTTOOLS text table header from an image header.

procedure wtabhdr (input, output)

file	input			{prompt="Input header"}
file	output			{prompt="Output table header"}
file	exclude = "splib$exclude.dat" {prompt="Keywords to exclude"}

struct	*fd

begin
	file	in, out
	struct	rec, key, key1

	in = input
	out = output

	if (out != "STDOUT" && access(out))
	    delete (out, v-)

	fd = in
	while (fscan (fd, rec) != EOF) {
	    key = substr (rec, 1, 8)
	    match (key, exclude) | scan (key1)
	    if (key == key1)
	        next
	    rec = trimr (rec)
	    printf ("#k %s\n", rec, >> out)
	}
	fd = ""
end
