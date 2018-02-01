mm=1e-3;
ro  = (74-2.5)/2*mm; // outer-most radius
ri1 = (57.5+1.8)/2*mm + 1*mm;  // second-most radius //add to mesh easily
ri2 = (29.5-1)/2*mm; // center-post leg's radius
ri3 = (5.4+0.3)/2*mm; // inner-most hole

h  = (40.7+0.8)*mm; // bobbin height
ho = 59*mm; // Height

ag=3.8*mm;
// initial coordinate of the center of the coil in XY plane, where Y is height
rp = 0.0043/2; interwire_pri = 0.006;//0.005065; // 0.003;// modified because the cross section shows 5 circles instead of 4 circles
rs = 0.00252/2; interwire_sec = 0.004;//0.003676; //0.003;//
thick_insul = 5e-5;
Np = 4; Ns = 6;
lcs0 = 3*rs;
lcinf = ho*1;
// Try changing the order of the fragment to create the space
//=============================================================//
SetFactory("OpenCASCADE");

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

/*

/* 
vC()+=newv; Cylinder(newv) = {0, -ho/2, 0, 0, ho, 0, ro, 2*Pi}; // Outer-most cylinder
vC()+=newv; Cylinder(newv) = {0, -h/2, 0, 0, h, 0, ri1, 2*Pi};  // Second-most cylinder
vC()+=newv; Cylinder(newv) = {0, -h/2, 0, 0, h, 0, ri2, 2*Pi}; // Center-post leg
vC()+=newv; Cylinder(newv) = {0, -ho/2, 0, 0, ho, 0, ri3, 2*Pi}; // hole in the center

// Auxiliary cylinders to cut off the core
aux()+=newv; Cylinder(newv) = {0, -ho/2, 2.6*ro, 0, ho, 0, 2*ro, 2*Pi};
aux()+=newv; Cylinder(newv) = {0, -ho/2, -2.6*ro, 0, ho, 0, 2*ro, 2*Pi};

// Airgap cylinder
vAg()+=newv; Cylinder(newv) = {0, -ag/2, 0, 0, ag, 0, ri2, 2*Pi};

// Cut off the core
vC() = BooleanDifference{ Volume{vC()}; Delete; }{ Volume{aux()}; Delete; };
// Make the airgap
vC() = BooleanDifference{ Volume{vC()}; Delete; }{ Volume{vAg()}; Delete; };

 */
//Printf("", vC()); //0:20 1:21 2:22 3:23

//new_vol() = BooleanFragments{ Volume{vC()}; Delete; }{};
// all_vol() = vC(); //Volume{vc()};
// Printf("all_vol=", all_vol());
// new_vol() = BooleanFragments{ Volume{all_vol()}; Delete; }{};
// Printf("new_vol=", new_vol());

// tol = ag/2;
// pts_ag() = Point In BoundingBox {
    // -ri2-tol,  -ag/2-tol,   -ri2-tol,
    // 2*(ri2+tol), 2*(ag/2+tol), 2*(ri2+tol)};


//Characteristic Length { pts_ag() } =  ag/4 ;
//Characteristic Length { PointsOf{ Volume{26,27}; } } =  (ri3)/4;

//xp0 = -0.022775; yp0 = 0.0141975 + rp; zp0 = 0; lcp = 1*rp;
xp0 = 0.022775; yp0 = 0.0148; zp0 = 2*ro; lcp = 3*rp;
// xs0 = 0.01781; ys0 = 0.01574; zs0 = 0; lcs0 = 3*rs;
// xs1 = 0.02774; ys1 = 0.01574; zs1 = 0; lcs1 = 3*rs;
xs0 = 0.01781; ys0 = 0.01686; zs0 = 2*ro; lcs0 = 2*rs;
xs1 = 0.02774; ys1 = 0.01686; zs1 = 2*ro; lcs1 = 3*rs;

//========================= Primary winding =============================//
Macro DrawWinding
// Need detail of the point {x0,y0,z0,lc0} and the radius
// Need the NoOfTurn
	pnt0[] = {}; lncir[] = {}; // clear array
	pnt0[] += newp; Point(newp) = {x0,y0,z0,lc0}; // center
	pnt0[] += newp; Point(newp) = {x0 + r,y0,z0,lc0};
	pnt0[] += newp; Point(newp) = {x0,y0  + r,z0,lc0};
	pnt0[] += newp; Point(newp) = {x0 - r,y0,z0,lc0};
	pnt0[] += newp; Point(newp) = {x0,y0 - r,z0,lc0};
	lncir[] += newl; Circle(newl) = {pnt0[1],pnt0[0],pnt0[2]};
	lncir[] += newl; Circle(newl) = {pnt0[2],pnt0[0],pnt0[3]};
	lncir[] += newl; Circle(newl) = {pnt0[3],pnt0[0],pnt0[4]};
	lncir[] += newl; Circle(newl) = {pnt0[4],pnt0[0],pnt0[1]};
	//llcir = newll; Line Loop(newll) = lncir[]; 
	//surfcir = news; Plane Surface(news) = newll-1;
	// Same concept from twist.geo using ThruSections

	l~{1}() = lncir[];
Printf("pnt0=", pnt0[]);	
	//llcir~{1} = newll; 
	llcir[] += newll; Line Loop(newll) = l~{1}();

	//section = DefineNumber[20*NoOfTurn, Name "Parameters/Number of slices", Min 2, Max 10, Step 1];
	//angle = DefineNumber[2*Pi*Np, Name "Parameters/Angle", Min 0, Max 2*Pi, Step 0.1];

	For i In {2:section_straight}
	  l~{i}() = Translate{0,0,-z0/(section_straight-1)}{ Duplicata{ Line{l~{i-1}()}; } };

	  llcir[] += newll;
	  Line Loop(newll) = l~{i}();
	EndFor


	llcir2[] += newll; Line Loop(newll) = l~{section_straight}();
	l2~{1}() = l~{section_straight}();
	
		//For i In {section_straight+1:section_straight+section-1}
	For i In {2:section}
	  l2~{i}() = Translate{0,-(interwire+r*2+thick_insul*2)*NoOfTurn/(section-1),0}{ Duplicata{ Line{l2~{i-1}()}; } };
	  Rotate {{0, 1, 0}, {0, 0, 0}, angle/(section-1)} { Line{l2~{i}()}; }
	  //Line Loop(i) = l~{i}();
	  //llcir~{i} = newll; 
	  llcir2[] += newll;
	  Line Loop(newll) = l2~{i}();
	EndFor

	llcir3[] += newll; Line Loop(newll) = l2~{section}();
	l3~{1}() = l2~{section}();
	
	For i In {2:section_straight}
	  l3~{i}() = Translate{z0/(section_straight-1),0,0}{ Duplicata{ Line{l3~{i-1}()}; } };

	  llcir3[] += newll;
	  Line Loop(newll) = l3~{i}();
	EndFor
//Printf("llcir_for=", l_1());	

/* 	For i In {section_straight+1:section_straight+section-1}
	//For i In {2:section-1}
	  l~{i}() = Translate{0,-(interwire+r*2+thick_insul*2)*NoOfTurn/(section-1),0}{ Duplicata{ Line{l~{i-1}()}; } };
	  Rotate {{0, 1, 0}, {0, 0, 0}, angle/(section-1)} { Line{l~{i}()}; }
	  //Line Loop(i) = l~{i}();
	  //llcir~{i} = newll; 
	  llcir[] += newll;
	  Line Loop(newll) = l~{i}();
	EndFor */



Return

// The number of section cannot be too low otherwise the spiral will deviate from the path and hit the core
section_straight = 5;
//================ Primary winding ===========================//
If (1)
x0 = xp0; y0 = yp0; z0 = zp0; lc0 = lcp; r = rp;
section = 15*Np; NoOfTurn = Np; interwire = interwire_pri; angle = Pi*(2*Np-0.5);
llcir[] = {};
llcir2[] = {};
llcir3[] = {};
Printf("llcir=", llcir());
Call DrawWinding;
Printf("llcir=", llcir());
winding_pris = newv;
ThruSections(winding_pris) = llcir[];
winding_pric = newv;
ThruSections(winding_pric) = llcir2[];
winding_prie = newv;
ThruSections(winding_prie) = llcir3[];

//Printf("winding_pri=", winding_pri());
EndIf

If (1)
//================ Secondary winding 0 ===========================//
x0 = xs0; y0 = ys0; z0 = zs0; lc0 = lcs0; r = rs;

//Ns = 4;
section = 15*Ns; NoOfTurn = Ns; interwire = interwire_sec; angle = Pi*(2*Ns-0.5);
llcir[] = {};
llcir2[] = {};
llcir3[] = {};
Call DrawWinding;
//winding_sec0 = newv;
winding_secs0 = newv;
ThruSections(winding_secs0) = llcir[];
winding_secc0 = newv;
ThruSections(winding_secc0) = llcir2[];
winding_sece0 = newv;
ThruSections(winding_sece0) = llcir3[];

//Characteristic Length { PointsOf{ Volume{winding_sec0}; } } = lcs0*1;
EndIf 
	
//================ Secondary winding 1 ===========================//
x0 = xs1; y0 = ys1; z0 = zs1; lc0 = lcs0; r = rs;

//NoOfTurn = Ns; interwire = interwire_sec; angle = -2*Pi*Ns;
//Ns = 4;
section = 15*Ns; NoOfTurn = Ns; interwire = interwire_sec; angle = Pi*(2*Ns-0.5);
llcir[] = {};
llcir2[] = {};
llcir3[] = {};
Call DrawWinding;
//winding_sec1 = newv;
//ThruSections(winding_sec1) = llcir[];
winding_secs1 = newv;
ThruSections(winding_secs1) = llcir[];
winding_secc1 = newv;
ThruSections(winding_secc1) = llcir2[];
winding_sece1 = newv;
ThruSections(winding_sece1) = llcir3[];

winding_pri() = BooleanFragments{ Volume{winding_pris,winding_pric,winding_prie}; Delete;}{};
winding_sec0() = BooleanFragments{ Volume{winding_secs0,winding_secc0,winding_sece0}; Delete;}{};
winding_sec1() = BooleanFragments{ Volume{winding_secs1,winding_secc1,winding_sece1}; Delete;}{};
Printf("winding_sec1=", winding_sec1());
Printf("winding_sece1=", winding_sece1);
Characteristic Length { PointsOf{ Volume{winding_pri()}; } } = 2*lcs0;
Characteristic Length { PointsOf{ Volume{winding_sec0()}; } } = 3*lcs0;
Characteristic Length { PointsOf{ Volume{winding_sec1()}; } } = 3*lcs0;
Characteristic Length { PointsOf{ Volume{winding_sece1()}; } } = 2*lcs0;

	
//Characteristic Length { PointsOf{ Volume{winding_pri()}; } } = lcp;




// out[1] is the volume
// out() = Extrude { {0,-(interwire_pri+rp)*2,0}, {0,1,0} , {0,0,0} , 360*2* Pi / 180 } {
  // Surface{surfcir}; Layers{3}; // Recombine;
// };
// out[] = Extrude {0,0,-2*rp}{
  // Surface{surfcir}; Layers{10}; Recombine;
// };


// Printf("out = ",out());
//Printf("vC=", vC()); //0:20 1:21 2:22 3:23
//airbnd = newv;
//Sphere(airbnd) = {0, 0, 0, 0.3/2, -Pi/2, Pi/2, 2*Pi};
//Box(1311) = {-zs0, -zs0, zs0, 2*zs0, 2*zs0, -2*zs0};
//Characteristic Length { PointsOf{ Volume{airbnd}; } } = lcinf;
//vC() = BooleanFragments{ Volume{vC()}; Delete; }{ Volume{winding_pri}; Delete; };
//vC() = BooleanFragments{ Volume{vC()}; Delete; }{ Volume{winding_sec1}; Delete; };
//air() = BooleanDifference{ Volume{airbnd()}; Delete;}{ Volume{vC(),winding_pri}; };
//air() = BooleanDifference{ Volume{airbnd()}; Delete;}{ Volume{winding_sec0}; };
//air() = BooleanDifference{ Volume{airbnd()}; Delete;}{ Volume{winding_sec1}; };
//Printf("vC2=", vC()); //0:20 1:21 2:22 3:23
//Printf("vC_cen", vC_cen()); //0:20 1:21 2:22 3:23
//Printf("air=", air());

// vC() = BooleanFragments{ Volume{vC()}; Delete; }{ Volume{winding_pri}; Delete; };
// Printf("vc = ", vC()); 
// out[] = Extrude {0,-2*Pi*xp0,0}{
  // Surface{surfcir}; Layers{10}; Recombine;
// };





/* 
//-------------------------------
Recursive Color SteelBlue {Volume{vC({0,1,2})};}
Recursive Color Red {Volume{vC({3})};}

bnd_vCore() = Unique(Abs(Boundary{Volume{20};}));
Physical Surface(1e4) = bnd_vCore(); */



// c0 = newreg; 
// Circle(c0) = {0.022775, 0.0141975, -0, 0.00215, 0, 2*Pi};
// llcir = newll; Line Loop(newll) = c0; 
// surfcir = news; Plane Surface(news) = newll-1;
// pntcir() = PointsOf{ Surface{surfcir}; };
// Printf("",pntcir());


//+


