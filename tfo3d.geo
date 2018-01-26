mm=1e-3;
ro  = 37*mm; // outer-most radius
ri1 = (57.5+1.8)/2*mm;  // second-most radius 
ri2 = (29.5-1)/2*mm; // center-post leg's radius
ri3 = (5.4+0.3)/2*mm; // inner-most hole

h  = 40.7*mm; // bobbin height
ho = 59*mm; // Height

ag=3.8*mm;


//=============================================================//
SetFactory("OpenCASCADE");

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


Printf("", vC()); //0:20 1:21 2:22 3:23

//new_vol() = BooleanFragments{ Volume{vC()}; Delete; }{};
// all_vol() = vC(); //Volume{vc()};
// Printf("all_vol=", all_vol());
// new_vol() = BooleanFragments{ Volume{all_vol()}; Delete; }{};
// Printf("new_vol=", new_vol());

tol = ag/2;
pts_ag() = Point In BoundingBox {
    -ri2-tol,  -ag/2-tol,   -ri2-tol,
    2*(ri2+tol), 2*(ag/2+tol), 2*(ri2+tol)};


//Characteristic Length { pts_ag() } =  ag/4 ;
Characteristic Length { PointsOf{ Volume{26,27}; } } =  (ri3)/4;

//SetFactory("Built-in");
//Circle
// initial coordinate of the center of the coil in XY plane, where Y is height
rp = 0.0043/2; interwire_pri = 0.005065;
rs = 0.00252/2; interwire_sec = 0.003676;
thick_insul = 5e-5;
Np = 1; Ns = 2;


xp0 = 0.022775; yp0 = 0.0141975; zp0 = 0; lcp = 2*rp;
xs0 = 0.01781; ys0 = 0.01574; zs0 = 0; lcs0 = 2*rs;
xs1 = 0.02774; ys1 = 0.01574; zs1 = 0; lcs1 = 2*rs;

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

	//llcir~{1} = newll; 
	llcir[] += newll; Line Loop(newll) = l~{1}();

	//Printf("l_1 = ", l_1()); 

	section = DefineNumber[10*NoOfTurn, Name "Parameters/Number of slices", Min 2, Max 10, Step 1];
	//angle = DefineNumber[2*Pi*Np, Name "Parameters/Angle", Min 0, Max 2*Pi, Step 0.1];
	For i In {2:section}
	  l~{i}() = Translate{0,-(interwire+r*2+thick_insul*2)*Np/(section-1),0}{ Duplicata{ Line{l~{i-1}()}; } };
	  Rotate {{0, 1, 0}, {0, 0, 0}, angle/(section-1)} { Line{l~{i}()}; }
	  //Line Loop(i) = l~{i}();
	  //llcir~{i} = newll; 
	  llcir[] += newll;
	  Line Loop(newll) = l~{i}();
	  //Printf("ll_i = ", newll ); 
	EndFor
	//Printf("ll_1 = ", newll); 


Return

//================ Primary winding ===========================//

x0 = xp0; y0 = yp0; z0 = zp0; lc0 = lcp; r = rp;
NoOfTurn = Np; interwire = interwire_pri; angle = 2*Pi*Np;
llcir[] = {};
Call DrawWinding;
winding_pri = newv;
ThruSections(winding_pri) = llcir[];
//lcp2 = 2*rp;


	//Printf("ll_1 = ", llcir[]);
//================ Secondary winding 0 ===========================//
x0 = xs0; y0 = ys0; z0 = zs0; lc0 = lcs0; r = rs;
NoOfTurn = Ns; interwire = interwire_sec; angle = -2*Pi*Ns;
llcir[] = {};
Call DrawWinding;
winding_sec0 = newv;
ThruSections(winding_sec0) = llcir[];
	
//================ Secondary winding 1 ===========================//
x0 = xs1; y0 = ys1; z0 = zs1; lc0 = lcs1; r = rs;
NoOfTurn = Ns; interwire = interwire_sec; angle = -2*Pi*Ns;
llcir[] = {};
Call DrawWinding;
winding_sec1 = newv;
ThruSections(winding_sec1) = llcir[];
	
	
Characteristic Length { PointsOf{ Volume{winding_pri}; } } = lcp;
Characteristic Length { PointsOf{ Volume{winding_sec0}; } } = lcs0;
Characteristic Length { PointsOf{ Volume{winding_sec1}; } } = lcs1;
	


/* //========================= Secondary winding =============================//
pnt0[] += newp; Point(newp) = {xp0,yp0,zp0,lc0}; // center
pnt0[] += newp; Point(newp) = {xp0 + rp,yp0,zp0,lc0};
pnt0[] += newp; Point(newp) = {xp0,yp0  + rp,zp0,lc0};
pnt0[] += newp; Point(newp) = {xp0 - rp,yp0,zp0,lc0};
pnt0[] += newp; Point(newp) = {xp0,yp0 - rp,zp0,lc0};
lncir[] += newl; Circle(newl) = {pnt0[1],pnt0[0],pnt0[2]};
lncir[] += newl; Circle(newl) = {pnt0[2],pnt0[0],pnt0[3]};
lncir[] += newl; Circle(newl) = {pnt0[3],pnt0[0],pnt0[4]};
lncir[] += newl; Circle(newl) = {pnt0[4],pnt0[0],pnt0[1]};
//llcir = newll; Line Loop(newll) = lncir[]; 
//surfcir = news; Plane Surface(news) = newll-1;
// Same concept from twist.geo using ThruSections

l~{1}() = lncir[];

//llcir~{1} = newll; 
llcir[] += newll; Line Loop(newll) = l~{1}();

Printf("l_1 = ", l_1()); 

sectionp = DefineNumber[10*Np, Name "Parameters/Number of slices", Min 2, Max 10, Step 1];
//angle = DefineNumber[2*Pi*Np, Name "Parameters/Angle", Min 0, Max 2*Pi, Step 0.1];
For i In {2:sectionp}
  l~{i}() = Translate{0,-(interwire_pri+rp*2+thick_insul*2)*Np/(sectionp-1),0}{ Duplicata{ Line{l~{i-1}()}; } };
  Rotate {{0, 1, 0}, {0, 0, 0}, 2*Pi*Np/(sectionp-1)} { Line{l~{i}()}; }
  //Line Loop(i) = l~{i}();
  //llcir~{i} = newll; 
  llcir[] += newll;
  Line Loop(newll) = l~{i}();
  //Printf("ll_i = ", newll ); 
EndFor
Printf("ll_1 = ", newll); 

winding_pri = newv;
ThruSections(winding_pri) = llcir[];






 */


// out[1] is the volume
// out() = Extrude { {0,-(interwire_pri+rp)*2,0}, {0,1,0} , {0,0,0} , 360*2* Pi / 180 } {
  // Surface{surfcir}; Layers{3}; // Recombine;
// };
// out[] = Extrude {0,0,-2*rp}{
  // Surface{surfcir}; Layers{10}; Recombine;
// };


// Printf("out = ",out());
// vC() = BooleanFragments{ Volume{vC()}; Delete; }{ Volume{out(1)}; Delete; };

// out[] = Extrude {0,-2*Pi*xp0,0}{
  // Surface{surfcir}; Layers{10}; Recombine;
// };

/*
//-------------------------------
Recursive Color SteelBlue {Volume{vC({0,1,2})};}
Recursive Color Red {Volume{vC({3})};}

bnd_vCore() = Unique(Abs(Boundary{Volume{20};}));
Physical Surface(1e4) = bnd_vCore();
*///+
// c0 = newreg; 
// Circle(c0) = {0.022775, 0.0141975, -0, 0.00215, 0, 2*Pi};
// llcir = newll; Line Loop(newll) = c0; 
// surfcir = news; Plane Surface(news) = newll-1;
// pntcir() = PointsOf{ Surface{surfcir}; };
// Printf("",pntcir());

/* pnt0[] += newp; Point(newp) = {xp0,yp0,zp0,lc0}; // center
pnt0[] += newp; Point(newp) = {xp0 + rp,yp0,zp0,lc0};
pnt0[] += newp; Point(newp) = {xp0,yp0  + rp,zp0,lc0};
pnt0[] += newp; Point(newp) = {xp0 - rp,yp0,zp0,lc0};
pnt0[] += newp; Point(newp) = {xp0,yp0 - rp,zp0,lc0};
lncir[] += newl; Circle(newl) = {pnt0[1],pnt0[0],pnt0[2]};
lncir[] += newl; Circle(newl) = {pnt0[2],pnt0[0],pnt0[3]};
lncir[] += newl; Circle(newl) = {pnt0[3],pnt0[0],pnt0[4]};
lncir[] += newl; Circle(newl) = {pnt0[4],pnt0[0],pnt0[1]};


l~{1}() = lncir[];

//llcir~{1} = newll; 
llcir[] += newll; Line Loop(newll) = l~{1}();

Printf("l_1 = ", l_1()); 

sectionp = DefineNumber[10*Np, Name "Parameters/Number of slices", Min 2, Max 10, Step 1];
//angle = DefineNumber[2*Pi*Np, Name "Parameters/Angle", Min 0, Max 2*Pi, Step 0.1];
For i In {2:sectionp}
  l~{i}() = Translate{0,-(interwire_pri+rp*2+thick_insul*2)*Np/(sectionp-1),0}{ Duplicata{ Line{l~{i-1}()}; } };
  Rotate {{0, 1, 0}, {0, 0, 0}, 2*Pi*Np/(sectionp-1)} { Line{l~{i}()}; }
  //Line Loop(i) = l~{i}();
  //llcir~{i} = newll; 
  llcir[] += newll;
  Line Loop(newll) = l~{i}();
  //Printf("ll_i = ", newll ); 
EndFor
Printf("ll_1 = ", newll); 

winding_pri = newv;
ThruSections(winding_pri) = llcir[]; */

