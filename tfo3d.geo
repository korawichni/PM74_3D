// geometry of winding and the mesh are ok

Include "tfo3d_data.geo";

Geometry.NumSubEdges = 100; // nicer display of curve



lcs0 = 3*rs;
lcinf = ho*1;


//=============================================================//

SetFactory("OpenCASCADE");


Macro DrawWinding
  // clear arrays
  llspiral() = {}; cable() = {}; cables() = {};

  // Need detail of the point {x0,y0,z0,lc0} and the radius
  // Need the NoOfTurn

  // Straight part: cable(0)
  surf_init(0) =news; Disk(news) = {x0, y0, z0, r};
  aux()   = Extrude{0.,0.,-z0}{ Surface{surf_init(0)}; Layers{_use_layers}; };
  cable() += aux(1); // Get the volume from aux(1)
	Printf('aux=',aux());

  // Top extruded surface is aux(0)
  aux_l() = Boundary{ Surface{aux(0)}; }; // Get the line loop
//Printf('aux_l=',aux_l());
  llspiral(0) = newll; Line Loop(newll) = aux_l(); // preparing to use thrusection

//Printf('llspiral=',llspiral());

  For i In {1:section-1}
    aux_l() = Translate{0,-(interwire+r*2+thick_insul*2)*NoOfTurn/(section-1),0}{ Duplicata{ Line{aux_l()}; } };
    Rotate {{0, 1, 0}, {0, 0, 0}, angle/(section-1)} { Line{aux_l()}; }
    llspiral() += newll; Line Loop(newll) = aux_l(); // collect the line loop to use thrusection

  EndFor

  // Spiral part
  For i In {1:#llspiral()-nn+1:nn}
    k =  (i < #llspiral()-nn) ? 0 : 1 ;
	//Printf('i=%f, k=%f, length=%f',i,k,#llspiral());
    cable() += newv; ThruSections(newv) = llspiral({i-1:i-1+nn-k});
  EndFor
  Printf('llspiral=',llspiral());
  Printf('length_llspiral=',#llspiral());
  Printf('cable=',cable());


  // Ending straight part
  surf_init(1) = news; Plane Surface(news) = llspiral(#llspiral()-1);
  aux2() = Extrude{z0,0.,0.}{ Surface{surf_init(1)}; Layers{_use_layers}; };
  cable() += aux2(1);
    Printf('cable=',cable());

   vcable() = BooleanFragments{ Volume{cable()}; Delete; }{}; // be careful of cables overlapping with each other
    Printf('cable=',cable());
	    //Printf('cables=',cables());
		Printf('vcable = ',vcable());
  //BooleanUnion{ Volume{cable()}; }{}
  //Delete{ Surface{1}; }
Return

//======================================================================================



// The number of section cannot be too low otherwise the spiral will deviate from the path and hit the core


_use_layers = 0; // cannot be 1
nnp = 10; // for some reason, it cannot be 10
nns = 12;
//================ Primary winding ===========================//
x0 = xp0; y0 = yp0; z0 = zp0; r = rp;
section = nnp*Np; NoOfTurn = Np; interwire = interwire_pri; angle = Pi*(2*Np-0.5);
nn = nnp;
Call DrawWinding;
winding_pri() = vcable();


//================ Secondary winding 0 ===========================//
x0 = xs0; y0 = ys0; z0 = zs0; r = rs;
section = nns*Ns; NoOfTurn = Ns; interwire = interwire_sec; angle = Pi*(2*Ns-0.5);
nn = nns;

Call DrawWinding;
winding_sec0() = vcable();
//BooleanUnion{ Volume{winding_sec0()}; }{}

//================ Secondary winding 1 ===========================//
x0 = xs1; y0 = ys1; z0 = zs1; r = rs;
section = nns*Ns; NoOfTurn = Ns; interwire = interwire_sec; angle = Pi*(2*Ns-0.5);
nn = nns;


Call DrawWinding;
winding_sec1() = vcable();


 //all_vol() = Volume '*';
 //Characteristic Length { PointsOf{ Volume{all_vol()}; } } = lcs0;
 Characteristic Length { PointsOf{ Volume{winding_sec0(),winding_sec1(),winding_pri()}; } } = lcs0;


//========================== Core ==================================//
If (1)

vC_out() +=newv; Cylinder(newv) = {0, -ho/2, 0, 0, ho, 0, ro, 2*Pi}; // Outer-most cylinder
vC_in=newv; Cylinder(newv) = {0, -h/2, 0, 0, h, 0, ri1, 2*Pi};  // Second-most cylinder


vC_out() = BooleanDifference{ Volume{vC_out()}; Delete;}{ Volume{vC_in}; Delete;};
//Characteristic Length { PointsOf{ Volume{vC_out()}; } } = ho;

vC_cen = newv; Cylinder(newv) = {0, -h/2, 0, 0, h, 0, ri2, 2*Pi}; // Center-post leg
//Characteristic Length { PointsOf{ Volume{vC_cen()}; } } = ho;
Printf("vC_cen", vC_cen()); //0:20 1:21 2:22 3:23

// Auxiliary cylinders to cut off the core
// aux()+=newv; Cylinder(newv) = {0, -ho/2, 2.6*ro, 0, ho, 0, 2*ro, 2*Pi};
// aux()+=newv; Cylinder(newv) = {0, -ho/2, -2.6*ro, 0, ho, 0, 2*ro, 2*Pi};
aux_[0] = newv;
Wedge(aux_[0]) = {0, 0, 0, ro*Tan(Pi/3), ro, ho, 0};
Rotate {{-1, 0, 0}, {0, 0, 0}, Pi/2} {Volume{aux_[0]}; }

Translate {0, -ho/2, ro + ri2} {Volume{aux_[0]}; }

//- Atan(ro*Tan(Pi/3)/(ro + ri2))


//Translate {0, -ho/2, ro + ri2} {Volume{aux_[2]}; }
//Printf("aux_=", aux_[]);
aux_[] += Symmetry {1, 0, 0, 0} { Duplicata{ Volume{aux_[0]}; } };
//Printf("aux_=", aux_[]);

aux_[] += Symmetry {0, 0, 1, 0} { Duplicata{ Volume{aux_[]}; } };
Rotate {{0, 1, 0}, {0, 0, 0}, Pi/2*0 - 0.1 + 1*Atan(ro*Tan(Pi/3)/(ro + ri2))} {Volume{aux_()}; }

// Cut off the core
vC_out() = BooleanDifference{ Volume{vC_out()}; Delete; }{ Volume{aux_()}; Delete; }; // Volume{aux_()};

// Airgap cylinder
vAg=newv; Cylinder(newv) = {0, -ag/2, 0, 0, ag, 0, ri2, 2*Pi};
//Characteristic Length { PointsOf{ Volume{vAg}; } } = ag;
// Make the airgap
vC() = BooleanFragments{ Volume{vC_cen}; Delete; }{ Volume{vAg}; Delete; };
Printf("vC_out", vC_out()); //0:20 1:21 2:22 3:23



// Stack the outer part and the central leg
vC() = BooleanFragments{ Volume{vC_out()}; Delete; }{ Volume{vC()}; Delete; };
Printf("vC_cen", vC_cen()); //0:20 1:21 2:22 3:23
Printf("vC", vC()); //0:20 1:21 2:22 3:23

// Make the hole
//hole_cen =newv; Cylinder(newv) = {0, -ho/2, 0, 0, -ho, 0, ri3, 2*Pi}; // hole in the center
hole_cen_up =newv; Cylinder(newv) = {0, ho/2, 0, 0, -(ho-ag)/2, 0, ri3, 2*Pi}; // hole in the center
hole_cen_dn =newv; Cylinder(newv) = {0, -ho/2, 0, 0, (ho-ag)/2, 0, ri3, 2*Pi}; // hole in the center
// Cut off the hole
//vC() = BooleanDifference{ Volume{vC()}; Delete; }{Volume{hole_cen_up,hole_cen_dn}; Delete; };
vC() = BooleanFragments{ Volume{vC()}; Delete; }{Volume{hole_cen_up,hole_cen_dn}; Delete; };

Printf("vC_cen", vC_cen()); //0:20 1:21 2:22 3:23

// Without this the mesh will be too big -> error of self intersecting surface
Characteristic Length { PointsOf{ Volume{vC()}; } } = lcs0;

EndIf

//================= Air Around ===================================//
Printf("newv", newv); //0:20 1:21 2:22 3:23
//pri() = BooleanUnion{ Volume{winding_pri()}; }{};
air_around = newv;
//zs0 = zs0*1.5;
Box(air_around) = {-zs0, -zs0, zs0, 2*zs0, 2*zs0, -2*zs0};
Characteristic Length { PointsOf{ Volume{air_around}; } } = 2*lcs0;


vol_model() = BooleanFragments{ Volume{winding_pri(),winding_sec0(),winding_sec1(),vC(),air_around}; Delete; }{};
vol_model() -= {winding_pri(),winding_sec0(),winding_sec1()};

Printf("volume model", vol_model()); //0:20 1:21 2:22 3:23






nn = #vol_model()-1;
vol_core()= vol_model({1,4,6});
vol_model() -= vol_core();
vol_air() = vol_model();



Physical Volume ("Primary", PRIMARY) = winding_pri();
Physical Volume ("Secondary 0",SECONDARY0) = winding_sec0();
Physical Volume ("Secondary 1", SECONDARY1) = winding_sec1();
Physical Volume ("Air", AIR) = vol_air();
Physical Volume ("Core", CORE) = vol_core();

Physical Surface ("Inner surface primary", IN_PRI) = {93};
Physical Surface ("Outer surface primary", OUT_PRI) = {94};


// For aestetics
Recursive Color SkyBlue { Volume{vol_air()};}
Recursive Color SteelBlue { Volume{vol_core()};}

Recursive Color Red  { Volume{winding_pri()};}
Recursive Color Green{ Volume{winding_sec0()};}
Recursive Color Cyan { Volume{winding_sec1()};}


Cohomology(1) {{PRIMARY},{IN_PRI, OUT_PRI}};
