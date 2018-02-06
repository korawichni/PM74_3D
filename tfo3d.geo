// geometry of winding and the mesh are ok

mm=1e-3;
ro  = (74-2.5)/2*mm; // outer-most radius
ri1 = (57.5+1.8)/2*mm + 1*mm;  // second-most radius //add to mesh easily
ri2 = (29.5-1)/2*mm; // center-post leg's radius
ri3 = (5.4+0.3)/2*mm; // inner-most hole

h  = (40.7+0.8)*mm; // bobbin height
ho = 59*mm; // Height

ag=3.8*mm;
// initial coordinate of the center of the coil in XY plane, where Y is height
rp = 0.0043/2; interwire_pri = 0.0035;//0.005065; // 0.003;// modified because the cross section shows 5 circles instead of 4 circles
rs = 0.00252/2; interwire_sec = 0.003;//0.003676; //0.003;//
thick_insul = 5e-5;
Np = 4; Ns = 6;
lcs0 = 3*rs;
lcinf = ho*1;


//=============================================================//

SetFactory("OpenCASCADE");


Macro DrawWinding
  // clear arrays
  llspiral() = {}; cable = {};

  // Need detail of the point {x0,y0,z0,lc0} and the radius
  // Need the NoOfTurn
  
  // Straight part: cable(0)
  surf_init(0) =news; Disk(news) = {x0, y0, z0, r};
  aux()   = Extrude{0.,0.,-z0}{ Surface{surf_init(0)}; Layers{_use_layers}; };
  cable(0) = aux(1); // Get the volume from aux(1)
	
	
  // Top extruded surface is aux(0)
  aux_l() = Boundary{ Surface{aux(0)}; }; // Get the line loop 

  llspiral(0) = newll; Line Loop(newll) = aux_l(); // preparing to use thrusection
  For i In {1:section-1}
    aux_l() = Translate{0,-(interwire+r*2+thick_insul*2)*NoOfTurn/(section-1),0}{ Duplicata{ Line{aux_l()}; } };
    Rotate {{0, 1, 0}, {0, 0, 0}, angle/(section-1)} { Line{aux_l()}; }
    llspiral() += newll; Line Loop(newll) = aux_l(); // collect the line loop to use thrusection
  EndFor

  // Spiral part
  For i In {1:#llspiral()-nns+1:nns}
    k =  (i < #llspiral()-nns) ? 0 : 1 ;
	//Printf('i=%f, k=%f, length=%f',i,k,#llspiral());
    cable() += newv; ThruSections(newv) = llspiral({i-1:i-1+nns-k});
  EndFor
  Printf('cable=',cable());
  
  // Ending straight part
  surf_init(1) = news; Plane Surface(news) = llspiral(#llspiral()-1);
  aux() = Extrude{z0,0.,0.}{ Surface{surf_init(1)}; Layers{_use_layers}; };
  cable() += aux(1);

  BooleanFragments{ Volume{cable()}; }{} // for some reasons, it adds the redundant volume of winding_sec0
  
Return

//======================================================================================

//xp0 = -0.022775; yp0 = 0.0141975 + rp; zp0 = 0; lcp = 1*rp;
xp0 = 0.022775; yp0 = 0.0148+0.001; zp0 = 2*ro; lcp = 3*rp;
// xs0 = 0.01781; ys0 = 0.01574; zs0 = 0; lcs0 = 3*rs;
// xs1 = 0.02774; ys1 = 0.01574; zs1 = 0; lcs1 = 3*rs;
xs0 = 0.01781; ys0 = 0.01686; zs0 = 2*ro; lcs0 = 2*rs;
xs1 = 0.02774; ys1 = 0.01686; zs1 = 2*ro; lcs1 = 3*rs;

// The number of section cannot be too low otherwise the spiral will deviate from the path and hit the core


_use_layers = 0;
nns = 10;

//================ Primary winding ===========================//
x0 = xp0; y0 = yp0; z0 = zp0; r = rp;
section = nns*Np; NoOfTurn = Np; interwire = interwire_pri; angle = Pi*(2*Np-0.5);

Call DrawWinding;
winding_pri() = cable();


//================ Secondary winding 0 ===========================//
x0 = xs0; y0 = ys0; z0 = zs0; r = rs;
section = nns*Ns; NoOfTurn = Ns; interwire = interwire_sec; angle = Pi*(2*Ns-0.5);


Call DrawWinding;
winding_sec0() = cable();


//================ Secondary winding 1 ===========================//
x0 = xs1; y0 = ys1; z0 = zs1; r = rs;
section = nns*Ns; NoOfTurn = Ns; interwire = interwire_sec; angle = Pi*(2*Ns-0.5);

Call DrawWinding;
winding_sec1() = cable();


all_vol() = Volume '*';
Characteristic Length { PointsOf{ Volume{all_vol()}; } } = lcs0;
  Printf('all_vol=',all_vol());
Printf('pri=',winding_pri());
Printf('sec0=',winding_sec0());
all_vol() -= {winding_pri(),winding_sec0(), winding_sec1()}; // to find the redundant volume = all - needed volumes
  Printf('all_vol_after1=',all_vol());
Recursive Delete { Volume{all_vol()}; } // get rid of the redundant volume
  Printf('all_vol_after2=',all_vol());

  //winding_pri() = BooleanUnion{ Volume{winding_sec0()}; }{};
  
Recursive Color Red  { Volume{winding_pri()};}
Recursive Color Green{ Volume{winding_sec0()};}
Recursive Color Cyan { Volume{winding_sec1()};}


//========================== Core ==================================//
If (0)

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
Characteristic Length { PointsOf{ Volume{vC()}; } } = lcs0*2;

EndIf

//================= Air Around ===================================//
//pri() = BooleanUnion{ Volume{winding_pri()}; }{};
air_around = newv;
zs0 = zs0*1.5;
Box(air_around) = {-zs0, -zs0, zs0, 2*zs0, 2*zs0, -2*zs0};
//Characteristic Length { PointsOf{ Volume{air_around}; } } = lcs0;
//air() = BooleanDifference{ Volume{air_around()}; Delete;}{ Volume{vC()}; };

//air() = BooleanDifference{ Volume{air_around}; Delete;}{ Volume{winding_pri()}; };  // cannot use boolean difference
//air() = BooleanDifference{ Volume{air()}; Delete;}{ Volume{winding_sec0()}; };
//,winding_pri(),winding_sec0(),winding_sec1()
// vol_model() = BooleanDifference{ Volume{air_around}; Delete; }{ Volume{vC(),winding_pri(),winding_sec0(),winding_sec1()}; Delete; };

BooleanFragments{ Volume{air_around,winding_sec0(),winding_sec1(),winding_pri()}; Delete; }{}

//Printf("winding_pri", winding_pri()); //0:20 1:21 2:22 3:23




