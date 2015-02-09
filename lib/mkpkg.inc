# Global MKPKG definitions for the NOAO packages.

#$set XFLAGS	= "$(XFLAGS) -p noao -p sptable" 
#$set XVFLAGS	= "$(XVFLAGS) -p noao -p sptable"
#$set LFLAGS	= "$(LFLAGS) -p noao -p sptable"
$set XFLAGS	= "$(XFLAGS) -p sptable -p noao" 
$set XVFLAGS	= "$(XVFLAGS) -p sptable -p noao"
$set LFLAGS	= "$(LFLAGS) -p sptable -p noao"

$ifeq (MACH, linux) then
    $include "sptable$lib/mkpkg.sf.LINUX"
$else $ifeq (MACH, linux64) then
    $include "sptable$lib/mkpkg.sf.LINUX64"
$else $ifeq (MACH, macosx) then
    $include "sptable$lib/mkpkg.sf.MACOSX"
$else $ifeq (MACH, macintel) then
    $include "sptable$lib/mkpkg.sf.MACINTEL"
$end
