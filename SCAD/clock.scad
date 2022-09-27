use <7segment.scad>

bodyColor = "gray";
segmentColor = "lightgreen";
sizeX = 62;
sizeY = 110;
//teardown = 20;
teardown = 0;
//diffusor = false;
diffusor = true;
digitDistance = 73;
dotsSpace = 30;
width = 15;
heigth = 16;

wall = 1.2;
barrier = 1.2;

legWall = 2.4;
legX = width;
legY = width+5+2*legWall;
legZ = 2*legWall + 6;

glue = 0.2;
screwBox = 14;

standWall = wall;

//elements = 8; // 88:88:88
elements = 5; // 88:88

module APDS9960hole()
{
  translate([-13.7/2,0,-0.9]) cube ([13.7,1,13.5]);
  translate([-3/2,-6,0]) cube ([3,6,4.5]);
}

module digitBottom()
{
  sevenSegment( 
    sizeY = sizeY, 
    sizeX = sizeX, 
    width = width, 
    heigth = 1,
    barrier = barrier,
    gaps = false
  );
  translate([4/2+glue,4/2+glue,1]) sevenSegment(
    tilt = 5,
    corner = 8-4/2,
    sizeY = sizeY-4-2*glue,
    sizeX = sizeX-4-2*glue,
    width = width-4-2*glue,
    barrier = barrier+(4-3),
    heigth = 1.5,
    gaps = false
  );
  translate([sizeX/2-legX/2,-legY,0])
    cube([legX,legY+0.1,1]);
  translate([sizeX/2-legX/2+legWall,-legY,1])
    cube([legX-2*legWall,legY,legWall-1]);
}

module digitMiddle()
{
  translate([0,0,1]) difference()
  {
    union()
    {
      difference()
      {
        sevenSegment( 
          sizeY = sizeY, 
          sizeX = sizeX, 
          width = width, 
          heigth=heigth-1, 
          gaps = false,
          barrier = barrier
        );
        translate([4/2,4/2,-1]) sevenSegment(
          tilt = 5,
          corner = 8-4/2,
          sizeY = sizeY-4,
          sizeX = sizeX-4,
          width = width-4,
          barrier = barrier+(4-3),
          heigth = heigth+1,
          gaps = true
        );
        translate([4/2,4/2,-1]) sevenSegment(
          tilt = 5,
          corner = 8-4/2,
          sizeY = sizeY-4,
          sizeX = sizeX-4,
          width = width-4,
          barrier = barrier+(4-3),
          heigth = 4,
          gaps = false
        );
        translate([3/2,3/2,heigth-1-2]) sevenSegment(
          tilt = 5,
          corner = 8-3/2,
          sizeY = sizeY-3,
          sizeX = sizeX-3,
          width = width-3,
          barrier = barrier,
          heigth = 3,
          gaps = true
        );
      }
      translate([sizeX/2-legX/2,-legY,0])
        cube([legX,legY+0.1,legZ-1]);
      translate([sizeX/2-legX/2-legWall,-legY+legWall,0])
        cube([legX+2*legWall,legWall,legZ-1+legWall]);
    }
    translate([sizeX/2-legX/2+legWall,-legY-legWall,-1])
      cube([legX-2*legWall,legY+2*legWall,legZ-2*legWall+1+1]);
  }
}

module digitTop()
{
  translate([3/2+glue,3/2+glue,heigth-2+glue-0.01]) sevenSegment(
    tilt = 5,
    corner = 8-3/2,
    sizeY = sizeY-3-2*glue,
    sizeX = sizeX-3-2*glue,
    width = width-3-2*glue,
    barrier = barrier+2*glue,
    heigth = 2-glue,
    gaps = true
  );
}

module digit(teardown = 0)
{
  translate([-sizeX/2,0,0])
  {
    color (bodyColor)
    {
      translate([0,0,-teardown]) 
        digitBottom();
      digitMiddle();
    }
    if (diffusor)
      color (segmentColor) 
        translate([0,0,teardown]) 
          digitTop();
  }
}

module dots(
  width = width,
  tilt = 5,
  sizeY = sizeY,
  heigth = 16
)
{
  translate([sin(tilt)*(1/3 * sizeY),1/3 * sizeY,0]) 
    cylinder(d=width, h=heigth);
  translate([sin(tilt)*(2/3 * sizeY),2/3 * sizeY,0]) 
    cylinder(d=width, h=heigth);
}

module dotsBottom()
{
  hull()
  {
    translate([-legX/2,-0.01,0])
      cube([legX,0.01,1]);
    dots(heigth = 1);
  }
  hull()
  {
      translate([-legX/2+legWall,-0.01,1])
        cube([legX-2*legWall,0.01,1.5]);
      translate([0,0,1]) 
        dots(heigth = 1.5, width = width-2*legWall);
  }

  translate([-legX/2,-legY,0])
    cube([legX,legY+0.1,1]);
  translate([-legX/2+legWall,-legY,1])
    cube([legX-2*legWall,legY,legWall-1]);
}

module dotsMiddle()
{
  translate([0,0,1]) difference()
  {
    union()
    {
      dots(heigth = heigth-1);
      hull()
      {
        dots(heigth = legZ-1);
        translate([-legX/2,-0.01,0])
          cube([legX,0.01,legZ-1]);
      }
      translate([-legX/2,-legY,0])
        cube([legX,legY+0.1,legZ-1]);
      translate([-legX/2-legWall,-legY+legWall,0])
        cube([legX+2*legWall,legWall,legZ-1+legWall]);
    }
    translate([0,0,-1]) dots(heigth = heigth+1, width = width-4);
    translate([0,0,heigth-2-1]) dots(width = width-3, heigth = 3);
    hull()
    {
      translate([0,0,-1]) dots(heigth = legZ-legWall, width=width-2*legWall);
      translate([-legX/2+legWall,-0.01,-1])
        cube([legX-2*legWall,0.01,legZ-2*legWall+1+1]);
    }
    translate([-legX/2+legWall,-legY-legWall,-1])
      cube([legX-2*legWall,legY+2*legWall,legZ-2*legWall+1+1]);
  }
}

module dotsTop()
{
  translate([0,0,heigth-2+glue]) dots(width = width-3.4, heigth = 1.5);
}
module dotsStand(teardown=0)
{
  //translate([width/2,0,0])
  {
    color (bodyColor)
    {
      translate([0,0,-teardown]) 
        dotsBottom();
      dotsMiddle();
    }
    if (diffusor)
      color (segmentColor)
        translate([0,0,teardown]) 
          dotsTop();
  }
}

pos = [
  0,                                        // 8
  digitDistance,                            // 8
  2*digitDistance-sizeX/2+width/2,          // :
  2*digitDistance+2*width,                  // 8
  3*digitDistance+2*width,                  // 8
  4*digitDistance+2*width-sizeX/2+width/2,  // :
  4*digitDistance+4*width,                  // 8
  5*digitDistance+4*width                   // 8
];

cut = [
  (pos[3]+pos[2])/2,
  (pos[5]+pos[6])/2
];

screw = (elements==8)?
  [
    -sizeX/2,
    cut[0]-screwBox,
    cut[0],
    cut[1]-screwBox,
    cut[1],
    pos[7]+sizeX/2-screwBox
  ]
:
  [
    -sizeX/2,
    ((-sizeX/2)+(pos[4]+sizeX/2-screwBox))/2,
    pos[4]+sizeX/2-screwBox
  ];
screws = (elements==8) ? 5 : 2;

module stand(standY=70, standZ=20)
{
  module hole()
  {
    translate([-(legX+2*glue)/2,-9,-(legZ+2*glue)/2])
      cube([legX+2*glue,10,legZ+2*glue]);
  }
  color (bodyColor)
  translate([0,-legY+legWall,0])
  {
    difference()
    {
      union()
      {
        translate([0-sizeX/2,-standZ,-standY/2]) cube([pos[elements-1]+sizeX,standZ,standY]);
      }
      for (i=[0:elements-1])
        translate([pos[i],0,0]) hole();
      translate([0-sizeX/2+standWall,-standZ-2*standWall,-standY/2+standWall]) 
        cube([pos[elements-1]+sizeX-2*standWall,standZ,standY-2*standWall]);
      translate([0,-10-2*standWall,-7.5]) cube([pos[elements-1]+sizeX,10,15]);
      translate([sizeX*2-15,-standWall-2.5,standY/2-standWall-0.2])
        rotate([90,180,0]) 
          render() 
            APDS9960hole();
    }
    translate([pos[elements-1]+sizeX/2-40-wall,-2*standWall-5,-15]) difference()
    {
      cube([40,5,30]);
      translate([-2.5,-5,3]) cube([45,20,24]);
      translate([-2.5,-1-3,2]) cube([45,6,26]);
    }
    render() translate([(pos[elements-2]+pos[elements-2])/2+sizeX/2-(28+6)/2,-2*standWall-5,-(29+6)/2]) difference()
    {
      cube([28+6,7,29+6]);
      translate([3,-5,3]) cube([28,7,29]);
      translate([-2,0,5]) cube([28+6+4,7,29-4]);
      translate([3+2,0,-1]) cube([28-4,7,29+6+2]);
    }
    translate([(pos[0]+pos[1])/2+6,-2*standWall, -15]) rotate([90,0,0]) difference ()
    {
      cylinder(d=7,h=2);
      translate([0,0,-1]) cylinder(d=2,h=4);
    }
    translate([(pos[0]+pos[1])/2-6,-2*standWall, 15]) rotate([90,0,0]) difference ()
    {
      cylinder(d=7,h=2);
      translate([0,0,-1]) cylinder(d=2,h=4);
    }
      
    for (i=[0:screws])
    {
      difference()
      {
        translate ([screw[i],-(standZ/2),standY/2-0.01-screwBox]) cube([screwBox,standZ/2,screwBox]);
        translate ([screw[i]+screwBox/2,+5,standY/2-screwBox/2]) rotate([90,0,0]) cylinder(d=4.8,h=standZ/2+10);
      }
      difference()
      {
        translate ([screw[i],-(standZ/2),-standY/2+0.01]) cube([screwBox,standZ/2,screwBox]);
        translate ([screw[i]+screwBox/2,+5,-standY/2+screwBox/2]) rotate([90,0,0]) cylinder(d=4.8,h=standZ/2+10);
      }
    }
  }
}

module cover(standY=70, standZ=20)
{
  color (bodyColor)
  translate([0,-legY+legWall,0])
  {
    difference()
    {
      union()
      {
        translate([0-sizeX/2+standWall+glue,-standZ,-standY/2+standWall+glue]) 
          difference()
          {
            cube([pos[elements-1]+sizeX-2*(standWall+glue),standZ/4 /*standWall*/,standY-2*(standWall+glue)]);
            translate([standWall, standWall, standWall]) cube([pos[elements-1]+sizeX-4*(standWall+glue),standWall+standZ/2,standY-4*(standWall+glue)]);
          }
        for (i=[0:screws])
        {
          translate ([screw[i]+screwBox/2,-standZ,standY/2-screwBox/2]) rotate([-90,0,0]) cylinder(d=screwBox-2*(standWall+glue),h=standZ/2);
          translate ([screw[i]+screwBox/2,-standZ,-standY/2+screwBox/2]) rotate([-90,0,0]) cylinder(d=screwBox-2*(standWall+glue),h=standZ/2);
        }
      }
      for (i=[0:screws])
      {
        translate ([screw[i]+screwBox/2,-standZ-5,standY/2-screwBox/2]) rotate([-90,0,0]) cylinder(d=3.3,h=20);
        translate ([screw[i]+screwBox/2,-standZ-5,-standY/2+screwBox/2]) rotate([-90,0,0]) cylinder(d=3.3,h=20);
      }
      for (i=[0:screws])
      {
        translate ([screw[i]+screwBox/2,-standZ-4,standY/2-screwBox/2]) rotate([-90,0,0]) cylinder(d=7,h=8);
        translate ([screw[i]+screwBox/2,-standZ-4,-standY/2+screwBox/2]) rotate([-90,0,0]) cylinder(d=7,h=8);
      }
    }
  }  
}

module stand_1of_3(standY=70, standZ=20)
{
  intersection()
  {
    stand(standY, standZ);
    translate([-sizeX,-(standZ+2*legZ+10),-(standY+10)/2]) 
      cube ([sizeX+cut[0],standZ+2*legZ+10,standY+10]);
  }
}

module stand_2of_3(standY=70, standZ=20)
{
  intersection()
  {
    stand(standY, standZ);
    translate([cut[0],-(standZ+2*legZ+10),-(standY+10)/2]) 
      cube ([cut[1]-cut[0],standZ+2*legZ+10,standY+10]);
  }
}

module stand_3of_3(standY=70, standZ=20)
{
  intersection()
  {
    stand(standY, standZ);
    translate([cut[1],-(standZ+2*legZ+100),-(standY+100)/2]) 
      cube ([sizeX+pos[7]-cut[1],standZ+2*legZ+100,standY+100]);
  }
}

module cover_1of_3(standY=70, standZ=20)
{
  intersection()
  {
    cover(standY, standZ);
    translate([-sizeX,-(standZ+2*legZ+10),-(standY+10)/2]) 
      cube ([sizeX+cut[0],standZ+2*legZ+20,standY+20]);
  }
}

module cover_2of_3(standY=70, standZ=20)
{
  intersection()
  {
    cover(standY, standZ);
    translate([cut[0],-(standZ+2*legZ+10),-(standY+10)/2]) 
      cube ([cut[1]-cut[0],standZ+2*legZ+10,standY+10]);
  }
}

module cover_3of_3(standY=70, standZ=20)
{
  intersection()
  {
    cover(standY, standZ);
    translate([cut[1],-(standZ+2*legZ+10),-(standY+10)/2]) 
      cube ([sizeX+pos[7]-cut[1],standZ+2*legZ+10,standY+10]);
  }
}

module ledStripMockup(w=10, leds_m=60, leds=1)
{
  fragment = 1000/leds_m;
  shift = fragment*(leds-1)/2;
  //color("lightgray")
    translate([-fragment*leds/2,-10/2,0]) 
      cube([fragment*leds,10,0.4]);
  for(i=[0:leds-1])
    color("red")
      translate([i*fragment-5/2-shift,-5/2,0.15]) 
        cube([5,5,2]);
}

rotate([90,0,0])
{
  if (elements == 8)
  {
    translate([-teardown,-glue-teardown,0]) stand_1of_3();
    translate([0,-glue-teardown,0]) stand_2of_3();
    translate([+teardown,-glue-teardown,0]) stand_3of_3();

    translate([-teardown,-glue-2*teardown,0]) cover_1of_3();
    translate([0,-glue-2*teardown,0]) cover_2of_3();
    translate([+teardown,-glue-2*teardown,0]) cover_3of_3();
  }
  else
  {
    translate([0,-glue-teardown,0]) stand();
    translate([0,-glue-4*teardown,0]) cover();
  }  


  translate([0,0,-legZ/2])
  {
    translate([pos[0],0,0]) digit(teardown=teardown);
    translate([pos[1],0,0]) digit(diffusor =(teardown == 0));
    translate([pos[2],0,0]) dotsStand(teardown=teardown);
    translate([pos[3],0,0]) digit();
    translate([pos[4],0,0]) digit();
    if (elements > 5)
    {
      translate([pos[5],0,0]) dotsStand();
      translate([pos[6],0,0]) digit();
      translate([pos[7],0,0]) digit();
    }
    
    translate([pos[0],width/2,2.5-teardown]) ledStripMockup(leds=1);
    translate([pos[1],width/2,2.5]) ledStripMockup(leds=1);
  }
}

//digit(teardown=teardown);
//translate([0,width/2,1.5-teardown]) ledMockup(leds=2);