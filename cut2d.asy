size(10cm,10cm);

real paletteheight=6cm;

// Take 2D cuts from images datasets in binary format.

// To transform flusi .h5 files to binary, use hdf2binary (which just
// wraps h5dump).

// Specify the contour lines to be drawn:
// asy -f pdf cut2d.asy -u "con=new real[] {-2,2};"

// Specify the legend name via command-line arguments:
// asy -f pdf cut2d.asy -u "legend=\"$v$\""
// (currently deprecated).


import graph;
import palette;
import utils;

// get data size
int nx=getint("nx");
int ny=getint("ny");
int nz=getint("nz");

string legend="";
real[] con={};
string filename="";
usersetting();

string name;
if(filename == "") name=getstring("filename");
else name=filename;
// Select direction of cross-section
string cutdir=getstring("cut direction: x,y,z");
int idir;
if(cutdir != "x" && cutdir != "y" && cutdir != "z") {
  write("Please select x, y, or z.");
  exit();
} else {
  if(cutdir== "x") idir=3;
  if(cutdir== "y") idir=2;
  if(cutdir== "z") idir=1;
}
int c=getint(cutdir+"-height");

real[][][] f=readfile(nx,ny,nz,name);

// Optionally set the field to zero if the mask is not set to zero.
bool usemask=getstring("use mask") =="y";
if(usemask) maskit(f,nx,ny,nz);

real[][][] mask;
real[][] mask2;

bool boundsmask=getstring("use mask for bounds") =="y";
if(boundsmask) {
  string maskname=getstring("mask filename");
  mask=readfile(nx,ny,nz,maskname);
  mask2=cut2(mask,nx,ny,nz,c,idir);
}
  
// Take a 2D cut of the file
real[][] f2=cut2(f,nx,ny,nz,c,idir);

bool submean=getstring("subtract mean value") =="y";
if(submean) {
  real meanval=getreal("mean value");
  for(int i=0; i < f2.length; ++i)
    for(int j=0; j < f2[i].length; ++j) 
      f2[i][j] -= meanval;
}

pair a=(0,0);
pair b=imagedims(cutdir);

// Find bounds for palette:
real f2max=-realMax;
real f2min=realMax;
for(int i=0; i < f2.length; ++i) {
  for(int j=0; j < f2[i].length; ++j) {
    if(!boundsmask ||mask2[i][i]==0.0) {
      if(f2[i][j] > f2max) f2max=f2[i][j];
      if(f2[i][j] < f2min) f2min=f2[i][j];
    }
  }
}
write("range: "+string(f2min)+" "+string(f2max));
real f2absmax=max(abs(f2max),abs(f2min));

// Choose a palette:
//pen[] Palette=BWRainbow();
pen[] Palette=paraview_cooltowarm;

// Draw image and specify colour bar:
bounds range;
bool symbar=getstring("symmetric colour bar (y/n)") =="y";
if(symbar)
  range=image(f2,Range(-f2absmax,f2absmax),a,b,Palette);
else
  range=image(f2,Full,a,b,Palette);  // Full colour bar

import contour;
if(con.length > 0) {
  //draw(contour(f2,a,b,con));
  Label[] Labels=sequence(new Label(int i) {
      return Label(con[i] != 0 ? (string) con[i] : "",
		   Relative(unitrand()),(0,0)
		   ,UnFill(1bp)
		   );
    },con.length);
  draw(Labels,contour(f2,a,b,con));
}

// Draw shape and remove wall region from image:
string shape=getstring("boundary shape");
if(shape == "circle") clipellipse(b.x,b.y,currentpicture);
if(shape == "rectangle") cliprectangle(b.x,b.y,currentpicture);

// Add the palette bar:
picture bar;
string barlegend="";
palette(bar,barlegend,range,(0,0),(0.5cm,paletteheight),Right,Palette,
        PaletteTicks(ptick=linewidth(0.5*linewidth())));
add(bar.fit(),point(E),30E);

//label(legend+", "+"$i_"+cutdir+"$"+"="+string(c),point(N),N);
