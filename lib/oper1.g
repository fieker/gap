#############################################################################
##
#W  oper1.g                     GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  Functions moved from oper.g, so as to be compiled in the default kernel
##
Revision.oper1_g :=
    "@(#)$Id$";


#############################################################################
##
#F  RunImmediateMethods( <obj>, <flags> )
##
##  applies immediate  methods  for the   object <obj>  for that  the  `true'
##  position in the Boolean list <flags> mean  that the corresponding filters
##  have been discovered recently.
##  So possible consequences of other filters are not checked.
##
RUN_IMMEDIATE_METHODS_CHECKS := 0;
RUN_IMMEDIATE_METHODS_HITS   := 0;

BIND_GLOBAL( "RunImmediateMethods", function ( obj, flags )

    local   flagspos,   # list of `true' positions in `flags'
            tried,      # list of numbers of methods that have been used
            type,       # type of `obj', used to notice type changes
            j,          # loop over `flagspos'
            imm,        # immediate methods for filter `j'
            i,          # loop over `imm'
            res,        # result of an immediate method
            newflags;   # newly  found filters

    # Avoid recursive calls from inside a setter, permit coplete switch-off
    # of immediate methods, ignore immediate methods for objects which have
    # it turned off.
    if IGNORE_IMMEDIATE_METHODS then return; fi;

    # intersect the flags with those for which immediate methods
    # are installed.
    if IS_SUBSET_FLAGS( IMM_FLAGS, flags ) then return; fi;
    flags := SUB_FLAGS( flags, IMM_FLAGS );

    flagspos := SHALLOW_COPY_OBJ(TRUES_FLAGS(flags));
    tried    := [];
    type     := TYPE_OBJ( obj );
    flags    := type![2];

    # Check the immediate methods for all in `flagspos'.
    # (Note that new information is handled via appending to that list.)
    for j  in flagspos  do

        # Loop over those immediate methods
        # - that require `flags[j]' to be `true',
        # - that are applicable to `obj',
        # - whose result is not yet known to `obj',
        # - that have not yet been tried in this call of
        #   `RunImmediateMethods'.

        if IsBound( IMMEDIATES[j] ) then
#T  the `if' statement can disappear when `IMM_FLAGS' is improved ...
            imm := IMMEDIATES[j];
            for i  in [ 0, 7 .. LEN_LIST(imm)-7 ]  do

                if        IS_SUBSET_FLAGS( flags, imm[i+4] )
                  and not IS_SUBSET_FLAGS( flags, imm[i+3] )
                  and not imm[i+6] in tried
                then

                    # Call the method, and store that it was used.
                    res := IMMEDIATE_METHODS[ imm[i+6] ]( obj );
                    ADD_LIST( tried, imm[i+6] );
                    RUN_IMMEDIATE_METHODS_CHECKS :=
                        RUN_IMMEDIATE_METHODS_CHECKS+1;
                    if TRACE_IMMEDIATE_METHODS  then
                        Print( "#I  immediate: ", imm[i+7], "\n" );
                    fi;

                    if res <> TRY_NEXT_METHOD  then

                        # Call the setter, without running immediate methods.
                        IGNORE_IMMEDIATE_METHODS := true;
                        imm[i+2]( obj, res );
                        IGNORE_IMMEDIATE_METHODS := false;
                        RUN_IMMEDIATE_METHODS_HITS :=
                            RUN_IMMEDIATE_METHODS_HITS+1;

                        # If `obj' has noticed the new information,
                        # add the numbers of newly known filters to
                        # `flagspos', in order to call their immediate
                        # methods later.
                        if not IS_IDENTICAL_OBJ( TYPE_OBJ(obj), type ) then

                          type := TYPE_OBJ(obj);

                          newflags := SUB_FLAGS( type![2], IMM_FLAGS );
                          newflags := SUB_FLAGS( newflags, flags );
                          APPEND_LIST_INTR( flagspos,
                                            TRUES_FLAGS( newflags ) );

                          flags := type![2];

                        fi;
                    fi;
                fi;
            od;

        fi;
    od;
end );

#############################################################################
##
#F  INSTALL_METHOD_FLAGS( <opr>, <info>, <rel>, <flags>, <rank>, <method> ) .
##
BIND_GLOBAL( "INSTALL_METHOD_FLAGS",
    function( opr, info, rel, flags, rank, method )
    local   methods,  narg,  i,  k,  tmp, replace, match, j;

    # add the number of filters required for each argument
    if opr in CONSTRUCTORS  then
        if 0 < LEN_LIST(flags)  then
            rank := rank - RankFilter( flags[ 1 ] );
        fi;
    else
        for i  in flags  do
            rank := rank + RankFilter( i );
        od;
    fi;

    # get the methods list
    narg := LEN_LIST( flags );
    methods := METHODS_OPERATION( opr, narg );

    # set the name
    if info = false  then
        info := NAME_FUNC(opr);
    else
        k := SHALLOW_COPY_OBJ(NAME_FUNC(opr));
        APPEND_LIST_INTR( k, ": " );
        APPEND_LIST_INTR( k, info );
        info := k;
        CONV_STRING(info);
    fi;

    # find the place to put the new method
    i := 0;
    while i < LEN_LIST(methods) and rank < methods[i+(narg+3)]  do
        i := i + (narg+4);
    od;

    # Now is a good time to see if the method is already there
    replace := false;
    if REREADING then
        k := i;
        while k < LEN_LIST(methods) and
          rank = methods[k+narg+3] do
            if info = methods[k+narg+4] then

                # ForAll not available
                match := false;
                for j in [1..narg] do
                    match := match and methods[k+j+1] = flags[j];
                od;
                if match then
                    replace := true;
                    i := k;
                    break;
                fi;
            fi;
            k := k+narg+4;
        od;
    fi;
    # push the other functions back
    if not REREADING or not replace then
        methods{[i+1..LEN_LIST(methods)]+(narg+4)}
          := methods{[i+1..LEN_LIST(methods)]};
    fi;

    # install the new method
    if   rel = true  then
        methods[i+1] := RETURN_TRUE;
    elif rel = false  then
        methods[i+1] := RETURN_FALSE;
    elif IS_FUNCTION(rel)  then
        if CHECK_INSTALL_METHOD  then
            tmp := NARG_FUNC(rel);
            if tmp <> AINV(1) and tmp <> narg  then
                Error(NAME_FUNC(opr),": <famrel> must accept ",
		      narg, " arguments");
            fi;
        fi;
        methods[i+1] := rel;
    else
        Error(NAME_FUNC(opr),
	      ": <famrel> must be a function, `true', or `false'" );
    fi;

    # install the filters
    for k  in [ 1 .. narg ]  do
        methods[i+k+1] := flags[k];
    od;

    # install the method
    if   method = true  then
        methods[i+(narg+2)] := RETURN_TRUE;
    elif method = false  then
        methods[i+(narg+2)] := RETURN_FALSE;
    elif IS_FUNCTION(method)  then
        if CHECK_INSTALL_METHOD and not IS_OPERATION( method ) then
            tmp := NARG_FUNC(method);
            if tmp <> AINV(1) and tmp <> narg  then
               Error(NAME_FUNC(opr),": <method> must accept ",
	             narg, " arguments");
            fi;
        fi;
        methods[i+(narg+2)] := method;
    else
        Error(NAME_FUNC(opr),
	      ": <method> must be a function, `true', or `false'" );
    fi;
    methods[i+(narg+3)] := rank;

    methods[i+(narg+4)] := IMMUTABLE_COPY_OBJ(info);

    # flush the cache
    CHANGED_METHODS_OPERATION( opr, narg );
end );


#############################################################################
##
#F  INFO_INSTALL( <level>, ... )
##
##  This will delegate to `InfoWarning' as soon as this is available.
##
BIND_GLOBAL( "INFO_INSTALL", function( arg )
    CALL_FUNC_LIST( Print, arg{ [ 2 .. LEN_LIST( arg ) ] } );
end );



#############################################################################
##
#F  InstallMethod( <opr>[,<info>][,<relation>],<filters>[,<rank>],<method> )
##
BIND_GLOBAL( "InstallMethod",
    function( arg )
    INSTALL_METHOD( arg, true );
    end );


#############################################################################
##
#F  InstallOtherMethod( <opr>[,<info>][,<relation>],<filters>[,<rank>],
#F                      <method> )
##
BIND_GLOBAL( "InstallOtherMethod",
    function( arg )
    INSTALL_METHOD( arg, false );
    end );


#############################################################################
##
#F  INSTALL_METHOD( <arglist>, <check> )  . . . . . . . . .  install a method
##
Unbind(INSTALL_METHOD);
BIND_GLOBAL( "INSTALL_METHOD",
    function( arglist, check )
    local len,   # length of `arglist'
          opr,   # the operation
          info,
          pos,
          rel,
          filters,
          flags,
          i,
          rank,
          method,
          req, reqs, match, j, k, imp, notmatch;

    # Check the arguments.
    len:= LEN_LIST( arglist );
    if   len < 3 then
      Error( "too few arguments given in <arglist>" );
    fi;

    # The first argument must be an operation.
    opr:= arglist[1];
    if not IS_OPERATION( opr ) then
      Error( "<opr> is not an operation" );
    fi;

    # Check whether an info string is given.
    if IS_STRING( arglist[2] ) then
      info:= arglist[2];
      pos:= 3;
    else
      info:= false;
      pos:= 2;
    fi;

    # Check whether a family predicate (relation) is given.
    if arglist[ pos ] = true or IS_FUNCTION( arglist[ pos ] ) then
      rel:= arglist[ pos ];
      pos:= pos + 1;
    else
      rel:= true;
    fi;

    # Check the filters list.
    if not IsBound( arglist[ pos ] ) or not IS_LIST( arglist[ pos ] ) then
      Error( "<arglist>[", pos, "] must be a list of filters" );
    fi;
    filters:= arglist[ pos ];
    pos:= pos + 1;

    # Compute the flags lists for the filters.
    flags:= [];
    for i in filters do
      ADD_LIST( flags, FLAGS_FILTER( i ) );
    od;

    # Check the rank.
    if not IsBound( arglist[ pos ] ) then
      Error( "the method is missing in <arglist>" );
    elif IS_INT( arglist[ pos ] ) then
      rank:= arglist[ pos ];
      pos:= pos + 1;
    else
      rank:= 0;
    fi;

    # Get the method itself.
    if not IsBound( arglist[ pos ] ) then
      Error( "the method is missing in <arglist>" );
    fi;
    method:= arglist[ pos ];

    # For a property, check whether this in fact installs an implication.
    if     FLAG1_FILTER( opr ) <> 0
       and ( rel = true or rel = RETURN_TRUE )
       and LEN_LIST( filters ) = 1
       and ( method = true or method = RETURN_TRUE ) then
      Error( NAME_FUNC( opr ), ": use `InstallTrueMethod' for <opr>" );
    fi;

    # Test if `check' is `true'.
    if CHECK_INSTALL_METHOD and check then

        # Signal a warning if the operation is only a wrapper operation.
        if opr in WRAPPER_OPERATIONS then
          INFO_INSTALL( 1,
              "a method is installed for the wrapper operation ",
              NAME_FUNC( opr ), "\n",
              "#I  probably it should be installed for (one of) its\n",
              "#I  underlying operation(s)" );
        fi;

        # find the operation
        req := false;
        for i  in [ 1, 3 .. LEN_LIST(OPERATIONS)-1 ]  do
            if IS_IDENTICAL_OBJ( OPERATIONS[i], opr )  then
                req := OPERATIONS[i+1];
                break;
            fi;
        od;
        if req = false  then
            Error( "unknown operation ", NAME_FUNC(opr) );
        fi;

        # do check with implications
        imp := [];
        for i  in flags  do
            ADD_LIST( imp, WITH_HIDDEN_IMPS_FLAGS( i ) );
        od;

        # Check that the requirements of the method match
        # (at least) one declaration.
        j:= 0;
        match:= false;
	notmatch:=0;
        while j < LEN_LIST( req ) and not match do
          j:= j+1;
          reqs:= req[j];
          if LEN_LIST( reqs ) = LEN_LIST( imp ) then
            match:= true;
            for i  in [ 1 .. LEN_LIST(reqs) ]  do
              if not IS_SUBSET_FLAGS( imp[i], reqs[i] )  then
                match:= false;
		notmatch:=i;
                break;
              fi;
            od;
            if match then break; fi;
          fi;
        od;

        if not match then

          # If the requirements do not match any of the declarations
          # then something is wrong or `InstallOtherMethod' should be used.
	  if notmatch=0 then
	    Error("the number of arguments does not match a declaration of ",
	           NAME_FUNC(opr) );
          else
	    Error("required filters ", NamesFilter(imp[notmatch]),"\nfor ",
	          Ordinal(notmatch)," argument do not match a declaration of ",
		   NAME_FUNC(opr) );
          fi;

        else

          # If the requirements match *more than one* declaration
          # then a warning is raised;
          # this is done by calling `INFO_INSTALL',
          # which delegates to `Print' until `InfoWarning' is defined,
          # and delegates to `InfoWarning' (with level 2) afterwards.
          for k in [ j+1 .. LEN_LIST( req ) ] do
            reqs:= req[k];
            if LEN_LIST( reqs ) = LEN_LIST( imp ) then
              match:= true;
              for i  in [ 1 .. LEN_LIST(reqs) ]  do
                if not IS_SUBSET_FLAGS( imp[i], reqs[i] )  then
                  match:= false;
                  break;
                fi;
              od;
              if match then
                INFO_INSTALL( 1,
                      "method installed for ", NAME_FUNC(opr),
                      " matches more than one declaration" );
              fi;
            fi;
          od;

        fi;
    fi;

    # Install the method in the operation.
    INSTALL_METHOD_FLAGS( opr, info, rel, flags, rank, method );
end );


#############################################################################
##
#M  default attribute getter and setter methods
##
##  The default getter method requires the category part of the attribute's
##  requirements, tests the property getters of the requirements,
##  and --if they are `true' and afterwards stored in the object--
##  calls the attribute operation again.
##  Note that we do *not* install this method for an attribute
##  that requires only categories.
##
##  The default setter method does nothing.
##
LENGTH_SETTER_METHODS_2 := LENGTH_SETTER_METHODS_2 + 6;  # one method

InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )

    local flags, rank, cats, props, i;

    if not IS_IDENTICAL_OBJ( filter, IS_OBJECT ) then

        flags := FLAGS_FILTER( filter );
        rank  := 0;
        cats  := IS_OBJECT;
        props := [];
        for i in [ 1 .. LEN_FLAGS( flags ) ] do
            if ELM_FLAGS( flags, i ) then
                if i in CATS_AND_REPS  then
                    cats := cats and FILTERS[i];
                    rank := rank - RankFilter( FILTERS[i] );
                elif i in NUMBERS_PROPERTY_GETTERS  then
                    ADD_LIST( props, FILTERS[i] );
                fi;
            fi;
        od;

        if 0 < LEN_LIST( props ) then

          # It might be that an object fits to the *first* declaration
          # of the attribute, but that some properties are not yet known.
#T change this, look for *all* declarations of the attribute!
          # If this is the case then we redispatch,
          # otherwise we give up.
          InstallOtherMethod( getter,
              "default method requiring categories and checking properties",
              true,
              [ cats ], rank,
              function ( obj )
              local found, prop;

              found:= false;
              for prop in props do
                if not Tester( prop )( obj ) then
                  found:= true;
                  if not ( prop( obj ) and Tester( prop )( obj ) ) then
                    TryNextMethod();
                  fi;
                fi;
              od;

              if found then
                return getter( obj );
              else
                TryNextMethod();
              fi;
              end );

        fi;
    fi;
    end );

InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )
    InstallOtherMethod( setter,
        "default method, does nothing",
        true,
        [ IS_OBJECT, IS_OBJECT ], 0,
            DO_NOTHING_SETTER );
    end );


#############################################################################
##
#F  KeyDependentOperation( <name>, <dom-req>, <key-req>, <key-test> )
##
##  There are several functions that require as first argument a domain,
##  e.g., a  group, and as second argument something much simpler,
##  e.g., a prime.
##  `SylowSubgroup' is an example.
##  Since its value depends on two arguments, it cannot be an attribute,
##  yet one would like to store the Sylow subgroups once they have been
##  computed.
##
##  The idea is to provide an attribute of the group,
##  called `ComputedSylowSubgroups', and to store the groups in this list.
##  The name implies that the value of this attribute may change in the
##  course of a {\GAP} session,
##  whenever a newly-computed Sylow subgroup is put into the list.
##  Therefore, this is a *mutable attribute*
##  (see~"prg:Creating Attributes and Properties" in ``Programming in GAP'').
##  The list contains primes in each bound odd position and a corresponding
##  Sylow subgroup in the following even position.
##  More precisely, if `<p> = ComputedSylowSubgroups( <G> )[ <even> - 1 ]'
##  then `ComputedSylowSubgroups( <G> )[ <even> ]' holds the value
##  of `SylowSubgroup( <G>, <p> )'.
##  The pairs are sorted in increasing order of <p>,
##  in particular at most one Sylow <p> subgroup of <G> is stored for each
##  prime <p>.
##  This attribute value is maintained by the operation `SylowSubgroup',
##  which calls the operation `SylowSubgroupOp( <G>, <p> )' to do the real
##  work, if the prime <p> cannot be found in the list.
##  So methods that do the real work should be installed
##  for `SylowSubgroupOp' and not for `SylowSubgroup'.
##
##  The same mechanism works for other functions as well, e.g., for `PCore',
##  but also for `HallSubgroup',
##  where the second argument is not a prime but a set of primes.
##
##  `KeyDependentOperation' declares the two operations and the attribute
##  as described above, with names <name>, `<name>Op', and `Computed<name>s'.
##  <dom-req> and <key-req> specify the required filters for the first and
##  second argument of the operation `<name>Op',
##  which are needed to create this operation with `NewOperation'
##  (see~"prg:NewOperation").
##  <dom-req> is also the required filter for the corresponding attribute
##  `Computed<name>s'.
##  The fourth argument <key-test> is in general a function to which the
##  second argument <info> of `<name>(  <D>, <info> )' will be passed.
##  This function can perform tests on <info>,
##  and raise an error if appropriate.
##
##  For example, to set up the three objects `SylowSubgroup',
##  `SylowSubgroupOp', and `ComputedSylowSubgroups' together,
##  the declaration file ``lib/grp.gd'' contains the following line of code.
##  \begintt
##  KeyDependentOperation( "SylowSubgroup", IsGroup, IsPosInt, "prime" );
##  \endtt
##  In this example, <key-test> has the value `"prime"',
##  which is silently replaced by a function that tests whether its argument
##  is a prime integer.
##
##  \beginexample
##  gap> s4 := Group((1,2,3,4),(1,2));;
##  gap> SylowSubgroup( s4, 5 );;  ComputedSylowSubgroups( s4 );
##  [ 5, Group(()) ]
##  gap> SylowSubgroup( s4, 2 );;  ComputedSylowSubgroups( s4 );
##  [ 2, Group([ (3,4), (1,2), (1,3)(2,4) ]), 5, Group(()) ]
##  gap> SylowSubgroup( s4, 6 );
##  Error SylowSubgroup: <p> must be a prime at
##  Error( name, ": <p> must be a prime" );
##  keytest( key ); called from
##  <function>( <arguments> ) called from read-eval-loop
##  Entering break read-eval-print loop, you can 'quit;' to quit to outer \
##  loop,
##  or you can return to continue
##  brk> quit;
##  \endexample
##
##  Thus the prime test need not be repeated in the methods for the operation
##  `SylowSubgroupOp' (which are installed to do the real work).
##  Note that no methods can/need be installed for `SylowSubgroup' and
##  `ComputedSylowSubgroups'.
##
IsPrimeInt := "2b defined";

BIND_GLOBAL( "KeyDependentOperation",
    function( name, domreq, keyreq, keytest )
    local str, nname, oper, attr;

    if keytest = "prime"  then
      keytest := function( key )
          if not IsPrimeInt( key ) then
            Error( name, ": <p> must be a prime" );
          fi;
      end;
    fi;

    # Create the two-argument operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );

    DeclareOperation( str, [ domreq, keyreq ] );
    oper:= VALUE_GLOBAL( str );

    # Create the mutable attribute and install its default method.
    str:= "Computed";
    APPEND_LIST_INTR( str, name );
    APPEND_LIST_INTR( str, "s" );
    DeclareAttribute( str, domreq, "mutable" );
    attr:= VALUE_GLOBAL( str );

    InstallMethod( attr, "default method", true, [ domreq ], 0, D -> [] );

    # Create the wrapper operation that mainly calls the operation.
    DeclareOperation( name, [ domreq, keyreq ] );
    ADD_LIST( WRAPPER_OPERATIONS, VALUE_GLOBAL( name ) );

    # Install the default method that uses the attribute.
    # (Use `InstallOtherMethod' in order to avoid the warning
    # that is signalled whenever a method is installed for a wrapper.)
    InstallOtherMethod( VALUE_GLOBAL( name ),
        "default method",
        true,
        [ domreq, keyreq ], 0,
        function( D, key )
        local known, i, erg;

        keytest( key );
        known:= attr( D );
        i:= 1;
        while i < LEN_LIST( known ) and known[i] < key do
          i:= i + 2;
        od;

	# Start storing only after the result has been computed.
        # This avoids errors if a calculation had been interrupted.

        if LEN_LIST( known ) < i or known[i] <> key then
	  erg := oper( D, key );
          known{ [ i + 2 .. LEN_LIST( known ) + 2 ] }:=
            known{ [ i .. LEN_LIST( known ) ] };
          known[  i  ]:= key;
          known[ i+1 ]:= erg;
        fi;
        return known[ i+1 ];
        end );
end );


#############################################################################
##
#F  RedispatchOnCondition( <oper>, <fampred>, <reqs>, <cond>, <val> )
##
##  This function installs a method for the operation <oper> under the
##  conditions <fampred> and <reqs> which has absolute value <val>;
##  that is, the value of the filters <reqs> is disregarded.
##  <cond> is a list of filters.
##  If not all the values of properties involved in these filters are already
##  known for actual arguments of the method,
##  they are explicitly tested and if they are fulfilled *and* stored after
##  this test, the operation is dispatched again.
##  Otherwise the method exits with `TryNextMethod'.
##  This can be used to enforce tests like `IsFinite' in situations when all
##  existing methods require this property.
##  The list <cond> may have unbound entries in which case the corresponding
##  argument is ignored for further tests.
##
CallFuncList:="2b defined";
BIND_GLOBAL( "RedispatchOnCondition", function(oper,fampred,reqs,cond,val)
    local re,i;

    # force value 0 (unless offset).
    for i in reqs do
      val:=val-SIZE_FLAGS(WITH_HIDDEN_IMPS_FLAGS(FLAGS_FILTER(i)));
    od;

    InstallOtherMethod( oper,
      "fallback method to test conditions",
      fampred,
      reqs, val,
      function( arg )
        re:= false;
        for i in [1..LEN_LIST(reqs)] do
          re:= re or
            (     IsBound( cond[i] )                  # there is a condition,
              and ( not Tester( cond[i] )( arg[i] ) ) # partially unknown,
              and cond[i]( arg[i] )                   # in fact true (here
                                                      # the test is forced),
              and Tester( cond[i] )( arg[i] ) );      # stored after the test
        od;
        if re then
          # at least one property was found out, redispatch
          return CallFuncList(oper,arg);
        else
          TryNextMethod(); # all filters hold already, go away
        fi;
      end);
end);


#############################################################################
##
#M  ViewObj( <obj> )  . . . . . . . . . . . .  default method uses `PrintObj'
##
InstallMethod( ViewObj,
    "default method using `PrintObj'",
    true,
    [ IS_OBJECT ],
    0,
    PRINT_OBJ );


#############################################################################
##
#E
