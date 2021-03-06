thick_insul = 5e-5;
Np = 4; Ns = 6;

mm=1e-3;
ro  = (74-2.5)/2*mm; // outer-most radius
ri1 = (57.5+1.8)/2*mm + 1*mm;  // second-most radius //add to mesh easily
ri2 = (29.5-1)/2*mm; // center-post leg's radius
ri3 = (5.4+0.3)/2*mm; // inner-most hole

ro_clip = (4+1)/2*mm;


h  = (40.7+0.8)*mm; // bobbin height
ho = 59*mm; // Height

ag=3.8*mm;


// initial coordinate of the center of the coil in XY plane, where Y is height
rp = 0.0043/2; interwire_pri = 0.0035;//0.005065; // 0.003;// modified because the cross section shows 5 circles instead of 4 circles
rs = 0.00252/2; interwire_sec = 0.003;//0.003676; //0.003;//


xp0 = 0.022775; yp0 = 0.0148+0.001; zp0 = 2*ro; lcp = 3*rp;
xs0 = 0.01781; ys0 = 0.01686; zs0 = 2*ro; lcs0 = 2*rs;
xs1 = 0.02774; ys1 = 0.01686; zs1 = 2*ro; lcs1 = 3*rs;

// GetDP parameters
// RMS current
IA_pri = 10;
IA_sec = 0;
sigma_cu = 6e7;
SymmetryFactor = 1;

// Physical numbers...
// Volume
PRIMARY    = 1000;
SECONDARY0 = 2000;
SECONDARY1 = 2100;
CORE = 3000;

AIR = 5000;

// Surface
IN_PRI  = 11111;
OUT_PRI = 11112;
IN_SEC0  = 11113;
OUT_SEC0 = 11114;
IN_SEC1  = 11115;
OUT_SEC1 = 11116;

SURF_AIROUT = 11121;
