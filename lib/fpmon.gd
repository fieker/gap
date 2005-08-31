#############################################################################
##
#W  fpmon.gd           GAP library        										Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for finitely presented monoids. 
##
Revision.fpmon_gd :=
    "@(#)$Id$";

#############################################################################
##
#C  IsElementOfFpMonoid(<elm>)
##
##	returns true if <elm> is an element of a finitely presented monoid. 
##
DeclareCategory( "IsElementOfFpMonoid",
    IsMultiplicativeElementWithOne and IsAssociativeElement);

#############################################################################
##
#C  IsElementOfFpMonoidCollection(<e>)
##
##  Created now so that lists of things in the category IsElementOfFpMonoid
##  are given the category CategoryCollections(IsElementOfFpMonoid)
##  Otherwise these lists (and other collections) won't create the 
##  collections category. See CollectionsCategory in the manual.
##   
DeclareCategoryCollections("IsElementOfFpMonoid");

#############################################################################
##
#A  IsSubmonoidFpMonoid( <t> )
##  
##	true if <t> is a finitely presented monoid or a 
##	submonoid of a finitely presented monoid 
##	(generally speaking, such a semigroup can be constructed
##	with `Monoid(<gens>)', where <gens> is a list of elements
##	of a finitely presented monoid).
##
##	A submonoid of a monoid has the same identity as the monoid.
##
DeclareSynonymAttr( "IsSubmonoidFpMonoid", 
	IsMonoid and IsElementOfFpMonoidCollection );

#############################################################################
##  
#C  IsElementOfFpMonoidFamily
##
DeclareCategoryFamily( "IsElementOfFpMonoid" );

#############################################################################
##
#F  FactorFreeMonoidByRelations( <f>, <rels> )
##
##  <f> is a free monoid and <rels> is a list of
##  pairs of elements of <f>. Returns the fp monoid which
##  is the quotient of <f> by the least congruence on <f> generated by
##  the pairs in <rels>.
##
DeclareGlobalFunction("FactorFreeMonoidByRelations");

#############################################################################
##  
#O  ElementOfFpMonoid( <fam>, <word> )
##  
##  If <fam> is the elements family of a finitely presented monoid and <word>
##  is a word in the free generators underlying this finitely presented
##  monoid, this operation creates the element with the representative <word>
##  in the free monoid.
##
DeclareOperation( "ElementOfFpMonoid",
    [ IsElementOfFpMonoidFamily, IsAssocWordWithOne ] );

#############################################################################
##
#O  FpMonoidOfElementOfFpMonoid( <elm> )
##
##  returns the fp monoid to which <elm> belongs to
##
DeclareOperation( "FpMonoidOfElementOfFpMonoid",[IsElementOfFpMonoid]);

#############################################################################
##
#P  IsFpMonoid(<m>)
##
##  is a synonym for `IsSubmonoidFpMonoid(<m>)' and 
##  `IsWholeFamily(<m>)' (this is because a submonoid 
##  of a finitely presented monoid is not necessarily finitely presented).
##
DeclareSynonym( "IsFpMonoid",IsSubmonoidFpMonoid and IsWholeFamily);

#############################################################################
## 
#A  FreeGeneratorsOfFpMonoid( <m> )
## 
##  returns the underlying free generators corresponding to the 
##	generators of the finitely presented monoid <m>.  
## 
DeclareAttribute("FreeGeneratorsOfFpMonoid",  IsFpMonoid);

#############################################################################
## 
#A  FreeMonoidOfFpMonoid( <m> )
## 
##	returns the underlying free monoid for the finitely presented 
##	monoid <m>, ie, the free monoid over which <m> is defined 
##	as a quotient
##	(this is the free monoid generated by the free generators provided 
##	by `FreeGeneratorsOfFpMonoid(<m>)').
##
DeclareAttribute("FreeMonoidOfFpMonoid", IsFpMonoid);

############################################################################
##
#A  RelationsOfFpMonoid(<m>)
##
##  returns the relations of the finitely presented monoid <m> as
##  pairs of words in the free generators provided by
##  `FreeGeneratorsOfFpMonoid(<m>)'.
##
DeclareAttribute("RelationsOfFpMonoid",IsFpMonoid);

############################################################################
##
#A  IsomorphismFpMonoid(<m>)
##
##  for a monoid <m> returns an isomorphism from <m> to an fp monoid.
##
DeclareAttribute("IsomorphismFpMonoid",IsMonoid);



#############################################################################
##
#E
