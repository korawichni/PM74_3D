mm=1e-3;
ro  = 37*mm;
ri1 = 28*mm;
ri2 = 17*mm;
ri3 = 2.7*mm;

h  = 40.7*mm;
ho = 59*mm;

ag=3.8*mm;

SetFactory("OpenCASCADE");

vC()+=newv; Cylinder(newv) = {0, -ho/2, 0, 0, ho, 0, ro, 2*Pi};
vC()+=newv; Cylinder(newv) = {0, -h/2, 0, 0, h, 0, ri1, 2*Pi};
vC()+=newv; Cylinder(newv) = {0, -h/2, 0, 0, h, 0, ri2, 2*Pi};
vC()+=newv; Cylinder(newv) = {0, -ho/2, 0, 0, ho, 0, ri3, 2*Pi};


aux()+=newv; Cylinder(newv) = {0, -ho/2, 2.6*ro, 0, ho, 0, 2*ro, 2*Pi};
aux()+=newv; Cylinder(newv) = {0, -ho/2, -2.6*ro, 0, ho, 0, 2*ro, 2*Pi};


vAg()+=newv; Cylinder(newv) = {0, -ag/2, 0, 0, ag, 0, ri2, 2*Pi};

vC() = BooleanDifference{ Volume{vC()}; Delete; }{ Volume{aux()}; Delete; };
vC() = BooleanDifference{ Volume{vC()}; Delete; }{ Volume{vAg()}; Delete; };

Printf("", vC());

all_vol() = Volume {:};
Printf("", all_vol());
new_vol() = BooleanFragments{ Volume{all_vol()}; Delete; }{};

tol = ag/2;
pts_ag() = Point In BoundingBox {
    -ri2-tol,  -ag/2-tol,   -ri2-tol,
    2*(ri2+tol), 2*(ag/2+tol), 2*(ri2+tol)};


Characteristic Length { pts_ag() } =  ag/4 ;
Characteristic Length { PointsOf{ Volume{26,23}; } } =  ri3/4;

//-------------------------------
Recursive Color SteelBlue {Volume{vC({0,1,2})};}
Recursive Color Red {Volume{vC({3})};}


bnd_vCore() = Unique(Abs(Boundary{Volume{20};}));
Physical Surface(1e4) = bnd_vCore();
