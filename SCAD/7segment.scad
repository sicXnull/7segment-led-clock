
module sevenSegment
(
  tilt = 5,
  corner = 8,
  sizeY = 80,
  sizeX = 46,
  width = 12,
  barrier = 1.7,
  heigth = 16,
  gaps = true,
)
{
  module hd_lb(d=barrier)
  {
    translate([barrier/2+sin(tilt)*(width-corner)+width-corner,width-corner+barrier/2,-1]) cylinder(d=d, h=heigth+2);
  }
  module hd_lh(d=barrier)
  {
    translate([barrier/2+sin(tilt)*(width-corner+(sizeY-3*width)/2)+width-corner,width-corner+(sizeY-3*width)/2-barrier/2,-1]) cylinder(d=d, h=heigth+2); 
  }
  module hd_rh(d=barrier)
  {
    translate([sin(tilt)*(width-corner+(sizeY-3*width)/2)+sizeX-corner-width-barrier/2,width-corner+(sizeY-3*width)/2-barrier/2,-1]) cylinder(d=d, h=heigth+2);
  }
  module hd_rb(d=barrier)
  {
    translate([sin(tilt)*(width-corner)+sizeX-corner-width-barrier/2,width-corner+barrier/2,-1]) cylinder(d=d, h=heigth+2);
  }
  module hh_lb(d=barrier)
  {
    translate([sin(tilt)*(2*width-corner+(sizeY-3*width)/2)+width-corner+barrier/2,2*width-corner+(sizeY-3*width)/2+barrier/2,-1]) cylinder(d=d, h=heigth+2);
  }
  module hh_lh(d=barrier)
  {
    translate([sin(tilt)*(sizeY-corner-width)+width-corner+barrier/2,sizeY-corner-width-barrier/2,-1]) cylinder(d=d, h=heigth+2);
  }
  module hh_rh(d=barrier)
  {
    translate([sin(tilt)*(sizeY-corner-width)+sizeX-corner-width-barrier/2,sizeY-corner-width-barrier/2,-1]) cylinder(d=d, h=heigth+2);
  }
  module hh_rb(d=barrier)
  {
    translate([sin(tilt)*(2*width-corner+(sizeY-3*width)/2)+sizeX-corner-width-barrier/2,2*width-corner+(sizeY-3*width)/2+barrier/2,-1]) cylinder(d=d, h=heigth+2);
  }
  module l_md(d=barrier)
  {
    translate([sin(tilt)*(sizeY/2-corner)+width/3-corner,sizeY/2-corner,-1]) cylinder(d=d, h=heigth+2);
  }
  module r_md(d=barrier)
  {
    translate([sin(tilt)*(sizeY/2-corner)+sizeX-width/3-corner,sizeY/2-corner,-1]) cylinder(d=d, h=heigth+2);
  }

  translate([corner,corner,0])
  {
    difference()
    {
      hull()
      {
        cylinder(r=corner, h=heigth);
        translate([(sizeY-2*corner)*sin(tilt),sizeY-2*corner,0]) cylinder(r=corner, h=heigth);
        translate([(sizeX-2*corner)+(sizeY-2*corner)*sin(tilt),sizeY-2*corner,0]) cylinder(r=corner, h=heigth);
        translate([(sizeX-2*corner),0,0]) cylinder(r=corner, h=heigth);
      }
      hull() { hd_lb(); hd_lh(); hd_rh(); hd_rb(); }
      hull() { hh_lb(); hh_lh(); hh_rh(); hh_rb(); }
      
      if (gaps)
      {
        hull() { hd_lb(); translate([-2*width,-2*width,0]) hd_lb(); }
        hull() { hd_rb(); translate([2*width,-2*width,0]) hd_rb(); }
        hull() { hh_lh(); translate([-2*width,2*width,0]) hh_lh(); }
        hull() { hh_rh(); translate([2*width,2*width,0]) hh_rh(); }

        hull() { hh_lb(); l_md(); }
        hull() { hd_lh(); l_md(); }
        hull() { l_md(); translate([-width*1.5,0,0]) l_md(d=barrier); }
        hull() { hh_rb(); r_md(); }
        hull() { hd_rh(); r_md(); }
        hull() { r_md(); translate([width*1.5,0,0]) r_md(d=barrier); }
      }
    }
  }
}



/*
 *
 * demo code
 * 
 */

translate([-120,0,0]) sevenSegment(sizeY = 80*2, sizeX = 46*2, width = 24);

//color ("black") 

color("lightgrey") translate([(3+1)/2,(3+1)/2,0.01])  sevenSegment(
    tilt = 5,
    corner = 8-(3+1)/2,
    sizeY = 100-3-1,
    sizeX = 55-3-1,
    width = 14-3-1,
    barrier = 1.7+1,
    heigth = 15,
    gaps = true
  );

color ("black") 

translate([70,0,0]) difference()
{
  sevenSegment( sizeY = 100, sizeX = 55, width = 14, heigth = 5,gaps = false);
  translate([3/2,3/2,-1])
  sevenSegment(
    tilt = 5,
    corner = 8-3/2,
    sizeY = 100-3,
    sizeX = 55-3,
    width = 14-3,
    barrier = 1.7,
    heigth = 5+2,
    gaps = true
  );
}

translate([70,0,80]) color("lightgrey") translate([(3+1)/2,(3+1)/2,0.01])  sevenSegment(
    tilt = 5,
    corner = 8-(3+1)/2,
    sizeY = 100-3-1,
    sizeX = 55-3-1,
    width = 14-3-1,
    barrier = 1.7+1,
    heigth = 15,
    gaps = true
  );



//translate([140,0,0]) sevenSegment();
translate([140,0,0]) sevenSegment(sizeY = 80*0.6, sizeX = 46*0.6, width = 8, tilt = 0);
translate([175,0,0]) sevenSegment(sizeY = 80*0.6, sizeX = 46*0.6, width = 8, tilt = 10);
translate([210,0,0]) sevenSegment(sizeY = 80*0.6, sizeX = 46*0.6, width = 8, tilt = 20);
translate([245,0,0]) sevenSegment(sizeY = 80*0.6, sizeX = 46*0.6, width = 8, tilt = 30);

translate([300,0,0]) difference()
{
  sevenSegment( sizeY = 100, sizeX = 55, width = 14, gaps = false);
  translate([4/2,4/2,-1])
  sevenSegment(
    tilt = 5,
    corner = 8-4/2,
    sizeY = 100-4,
    sizeX = 55-4,
    width = 14-4,
    barrier = 1.7,
    heigth = 16+2,
    gaps = true
  );
  translate([3/2,3/2,16-2])
  sevenSegment(
    tilt = 5,
    corner = 8-3/2,
    sizeY = 100-3,
    sizeX = 55-3,
    width = 14-3,
    barrier = 1.7-(4-3),
    heigth = 3,
    gaps = true
  );
}
