Include "tfo3d_data.geo";

Dir="res/";
ExtGmsh = ".pos";




Group{
  DefineGroup[
	Primary, Secondary0, Secondary1
  ];

Primary = #PRIMARY;
Secondary0 = #SECONDARY0;
Secondary1 = #SECONDARY1;
// Core = CORE;
// Air = AIR;
// In_pri = IN_PRI;
// Out_pri = OUT_PRI;



Domain = Region[ {Primary,Secondary0,Secondary1} ];

}

Function{
	
    // vDir[] = (
      // (Fabs[X[]]<=wcoreE && Z[]>= Lz/2) ? Vector [1, 0, 0]:
      // (Fabs[X[]]<=wcoreE && Z[]<=-Lz/2) ? Vector [ -1, 0, 0]:
      // (Fabs[Z[]]<=Lz/2   && X[]>= wcoreE) ? Vector [ 0, 0, -1]:
      // (Fabs[Z[]]<=Lz/2   && X[]<=-wcoreE) ? Vector [ 0, 0,  1]:
      // (X[]>wcoreE && Z[]>Lz/2)  ? Vector [Sin[Atan2[Z[]-Lz/2,X[]-wcoreE]#1], 0, -Cos[#1]]:
      // (X[]>wcoreE && Z[]<-Lz/2) ? Vector [Sin[Atan2[Z[]+Lz/2,X[]-wcoreE]#1], 0, -Cos[#1]]:
      // (X[]<-wcoreE && Z[]>Lz/2) ? Vector [Sin[Atan2[Z[]-Lz/2,X[]+wcoreE]#1], 0, -Cos[#1]]:
      // Vector [Sin[Atan2[Z[]+Lz/2,X[]+wcoreE]#1], 0, -Cos[#1]] );
    Ap = -(interwire_pri+rp*2+thick_insul*2)*Np/(10*Np-1);
    As = (interwire_sec+rs*2+thick_insul*2)*Ns/(12*Ns-1);
	vDir[Primary] = ( (Y[] >= yp0-rp && Z[] >=0) ? Vector [0,0,-1]:
		(Y[]<=yp0+rp-(interwire_pri+rp*2+thick_insul*2)*Np && X[] >=0) ? Vector [1,0,0]:
		Unit [ Vector [ Z[], -Ap ,-X[] ] ] );
	vDir[Secondary0] = ( (Y[] >= ys0-rs && Z[] >=0) ? Vector [0,0,-1]:
		(Y[]<=ys0+rs-(interwire_sec+rs*2+thick_insul*2)*Ns && X[] >=0) ? Vector [1,0,0]:
		Unit [ Vector [ Z[], -As ,-X[] ] ] );
    vDir[Secondary1] = ( (Y[] >= ys0-rs && Z[] >=0) ? Vector [0,0,-1]:
		(Y[]<=ys0+rs-(interwire_sec+rs*2+thick_insul*2)*Ns && X[] >=0) ? Vector [1,0,0]:
		Unit [ Vector [ Z[], -As ,-X[] ] ] );		
}


Jacobian {
  { Name Vol ;
    Case { //{ Region DomainInf ; Jacobian VolSphShell {Val_Rint, Val_Rext} ; }
           { Region All ;       Jacobian Vol ; }
    }
  }
  { Name Sur ;
    Case { { Region All ; Jacobian Sur ; }
    }
  }
}

Integration {
  { Name II ;
    Case {
      {
	Type Gauss ;
	Case {
	  { GeoElement Triangle    ; NumberOfPoints  4 ; }
	  { GeoElement Quadrangle  ; NumberOfPoints  4 ; }
	  { GeoElement Tetrahedron ; NumberOfPoints  4 ; }
	  { GeoElement Hexahedron  ; NumberOfPoints  6 ; }
	  { GeoElement Prism       ; NumberOfPoints  21 ; }
	  { GeoElement Line        ; NumberOfPoints  4 ; }
	}
      }
    }
  }
}

Constraint {
  { Name MVP_3D ;
    Case {
      { Region Domain ; Type Assign ; Value 0. ; }
    }
  }
}
FunctionSpace {

  // Magnetic vector potential a (b = curl a)
  { Name Hcurl_a_3D ; Type Form1 ;
    BasisFunction {// a = a_e * s_e
      { Name se ; NameOfCoef ae ; Function BF_Edge ;
        Support Domain ; Entity EdgesOf[ All] ; }
      { Name se2 ; NameOfCoef ae2 ; Function BF_Edge ;
        Support Domain ; Entity EdgesOf[ All ] ; }
    }
    Constraint {
	  { NameOfCoef ae  ; EntityType EdgesOf ; NameOfConstraint MVP_3D ; }
	}
  }
}


Constraint {

  { Name GaugeCondition_a ; Type Assign ;
    Case {
        { Region Domain ; Value 0. ; }
    }
  }
}

Formulation {
	{ Name FindVector ; Type FemEquation ;
	  Quantity {
		{ Name a  ; Type Local ; NameOfSpace Hcurl_a_3D ; }
	  }
	  Equation {
		Galerkin { [Dof{a},{a}] ; In Domain ; Jacobian Vol ; Integration II ;}
	  }
	}
}

Resolution {
	{ Name Analysis ;
	  System {
		  { Name Sys ; NameOfFormulation FindVector ;}
	  }
	  Operation {
		  // CreateDir["res/"];
		  // InitSolution[Sys] ;
		  // Generate[Sys] ; Solve[Sys] ;
		  // SaveSolution[Sys] ;
		  // PostOperation[ShowTangentVector] ;
	  }
	}
}	

PostProcessing {
	{ Name TangentVector ; NameOfFormulation FindVector ;
		PostQuantity {
			{ Name vdir; Value { Term { [ vDir[] ] ; In Domain ; Jacobian Vol ; } } } 
		}	
	}
}


 PostOperation ShowTangentVector UsingPost TangentVector {
// added
   Print[ vdir, OnElementsOf Domain, File StrCat[Dir,"vdir",ExtGmsh] ] ;
 }