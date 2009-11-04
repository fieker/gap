#############################################################################
##
##  PackageInfo.g for the package `FR'                    Laurent Bartholdi
##
## $Id: PackageInfo.g,v 1.32 2009/10/13 09:37:05 gap Exp $
##
SetPackageInfo( rec(
PackageName := "FR",
Subtitle := "Computations with functionally recursive groups",
Version := "1.0.0",
## <#GAPDoc Label="Version">
## 1.0.0
## <#/GAPDoc>
Date := "05/09/2009",
ArchiveURL := Concatenation("http://www.uni-math.gwdg.de/laurent/FR/fr-",~.Version),
ArchiveFormats := ".tar.gz",
Persons := [
  rec(
    LastName      := "Bartholdi",
    FirstNames    := "Laurent",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "laurent.bartholdi@gmail.com",
    WWWHome       := "http://www.uni-math.gwdg.de/laurent",
    PostalAddress := Concatenation( [
                       "Mathematisches Institut\n",
                       "Bunsenstrasse 3-5\n",
                       "D-37073 Goettingen\n",
                       "Germany" ] ),
    Place         := "Goettingen",
    Institution   := "Georg-August Universitaet zu Goettingen"
  )
],

Status := "deposited",
# CommunicatedBy := "Mike Atkinson (St. Andrews)",
# AcceptDate := "08/1999",

README_URL := "http://www.uni-math.gwdg.de/laurent/FR/README.fr",
PackageInfoURL := "http://www.uni-math.gwdg.de/laurent/FR/PackageInfo.g",
AbstractHTML := "The <span class=\"pkgname\">FR</span> package allows \
   GAP to manipulate groups generated by automata, and more generally \
   functionally recursive groups",
PackageWWWHome := "http://www.uni-math.gwdg.de/laurent/FR/",

PackageDoc := rec(
  BookName  := "FR",
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Functionally recursive and automata groups",
  ArchiveURLSubset := ["doc"],
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4.4.10",
  NeededOtherPackages := [["FGA",">=1.1"],
                      ["Polycyclic",">=2.2"],
                      ["GAPDoc",">=1.0"]],
  SuggestedOtherPackages := [["GBNP",">=0.9"],
                      ["NQL",">=0.07"]],
  # additional desired packages: graphviz, display

  # for compilation of the external module, one needs:
  # gcc, gfortran, libcblas, libgsl, javac, appletviewer.
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
                    
BannerString := Concatenation("Loading FR ", String( ~.Version ), " ...\n"),

Autoload := false,
TestFile := "tst/testall.g",
Keywords := ["functionally recursive group", "mealy machine", "automata group"]
));