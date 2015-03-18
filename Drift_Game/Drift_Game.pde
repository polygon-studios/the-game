
// Imports
import gab.opencv.*;
import KinectPV2.*;
import SimpleOpenNI.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.dynamics.joints.*;
import java.awt.Rectangle;

// Constructors
KinectPV2           kinect;
KinectPV2           kinectBall;
OpenCV              opencvBody;
OpenCV              opencvBalloon;
Box2DProcessing     mBox2D;
Flock               flock;

ArrayList<Rectangle> rectangles;
ArrayList<Contour> boundingBox;
Rectangle boundRect;


float polygonFactor = 1;

int threshold = 45;

float maxD = 2.5f;
float minD = 0.5f;


boolean    contourBodyIndex = true;

int lastTimeCheck = 0;
int lastCloudTimeCheck = 0;
int themeChangeTimer = 10000; // in milliseconds
int cloudTimer = 15000; //in milliseconds
int currentTheme = 0;
int nextTheme = 1;
import ddf.minim.*;

AudioPlayer player; 
Minim minim;//audio context
boolean firstRun = true;

PImage bgImg;
PImage fgImg;
PImage mgImg;
PImage skyImg = new PImage();

ArrayList<Theme> themeArray= new ArrayList<Theme>();
ArrayList<Cloud> cloudArray= new ArrayList<Cloud>();

ArrayList<string> mString;
ArrayList<balloon> balloons;

void setup() {
  // Intialize backgound stuff
  size(1280, 720);
  skyImg = loadImage("City/background/city_bg_sky.png");
  background(skyImg);
  
  Theme forest = new Theme("forest.png", skyImg);
  Theme city = new Theme("city.png", skyImg);
  Theme farm = new Theme("farm.png", skyImg);
  Theme mountain = new Theme("mountain.png", skyImg);
  
  updateForest(forest);
  updateCity(city);
  updateFarm(farm);
  updateMountain(mountain);
  //themeArray.add(forest);
  //themeArray.add(city);
  //themeArray.add(farm);
  //themeArray.add(mountain);
  
  minim = new Minim(this);
  player = minim.loadFile("Music.mp3", 2048);
  player.loop();
  
  flock = new Flock();
  for (int i = 0; i < 3; i++) {
    flock.addBird(new Bird(new PVector(width/2,height/2), random(1.0, 6.0) ,0.03));
  }
  smooth();
  
  mString = new ArrayList<string>();
  balloons = new ArrayList<balloon>();
  
  mBox2D = new Box2DProcessing(this);
  mBox2D.createWorld();
  mBox2D.setGravity(0, -40);
  
  // Kinect related setup
  opencvBody = new OpenCV(this, 512, 424);
  kinect = new KinectPV2(this); 
  
  // Enable kinect tracking of following
  kinect.enablePointCloud(true);
  kinect.enableBodyTrackImg(true);
  kinect.enableColorImg(true);
  kinect.enableDepthImg(true);
  
  kinect.init();
}

void draw() {
  mBox2D.step();
  background(skyImg);
  // KINECT STUFF
  
  noFill(); 
  

  if (contourBodyIndex) {
    opencvBody.loadImage(kinect.getBodyTrackImage());
    opencvBody.gray();
    kinect.getBodyTrackImage().loadPixels();
    opencvBody.threshold(threshold);
    PImage dst = opencvBody.getOutput();
  } else {
    opencvBody.loadImage(kinect.getPointCloudDepthImage());
    opencvBody.gray();
    opencvBody.threshold(threshold);
    PImage dst = opencvBody.getOutput();
  }

    
  ArrayList<Contour> contours = opencvBody.findContours(); 
  if ( (millis() - lastTimeCheck > themeChangeTimer)) {
    lastTimeCheck = millis();
    
    if(firstRun == false){
      currentTheme = calculateThemeCycle(currentTheme);
      nextTheme = calculateThemeCycle(currentTheme);
    }
    
    Theme temp = themeArray.get(currentTheme);
    temp.drawFullImg();
    
    if (contours.size() > 0) {
      for (Contour contour : contours) {
        
        contour.setPolygonApproximationFactor(polygonFactor);
        if (contour.numPoints() < 100 &&  contour.numPoints() > 50) {
          stroke(150, 150, 0);
          //fill(150, 150, 0);
          beginShape();
  
          for (PVector point : contour.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2.5, point.y * 2 );
          }
          endShape();
          
          boundRect = new Rectangle(1280, 720, 0, 0);
          
          noFill();
          stroke(0,0,255);
          strokeWeight(2);
          Rectangle rec = contour.getBoundingBox();
          if(rec.width > boundRect.width && rec.height > boundRect.height){
             boundRect = rec; 
          }
          
          float centerX;
          float centerY;
          
          centerX = boundRect.x + (boundRect.width/2);
          centerY = boundRect.y + (boundRect.height/2);
          
          rect(boundRect.x * 2.5, boundRect.y * 2, boundRect.width * 2.5, boundRect.height * 2);
          
          fill(0,255,0);
          ellipse(centerX * 2.5, centerY * 2, 8,8);
          
        }
        if (contour.numPoints() > 150) {
          stroke(0, 155, 155);
          beginShape();
          fill(255);
          for (PVector point : contour.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2.5, point.y * 2 );
          }
          endShape();
          //print(contour.numPoints() + '\n');
        }
        
      }
    }
    
    for(string thisString : mString){
      thisString.draw();
    }
    
    for(balloon thisCircle : balloons){
      thisCircle.draw();
    }
    
    firstRun = false;
    //println("CURRENTTHEME: " + currentTheme + " NEXTTHEME: " + nextTheme);
  }else{
    Theme temp = themeArray.get(currentTheme);
    
    
    if(temp.checkToFadeOutBg() == true){
      Theme newTemp = themeArray.get(nextTheme);
      newTemp.bgTransFadeIn();
      newTemp.drawBgImgs();
    }
    if(temp.checkToFadeOutMg() == true){
      Theme newTemp = themeArray.get(nextTheme);
      newTemp.mgTransFadeIn();
      newTemp.drawMgImgs();
    }
    if(temp.checkToFadeOutFg() == true){
      Theme newTemp = themeArray.get(nextTheme);
      newTemp.fgTransFadeIn();
      newTemp.drawFgImgs();
    }
    
    temp.drawFullImg();
    
    if (contours.size() > 0) {
      for (Contour contour : contours) {
        
        contour.setPolygonApproximationFactor(polygonFactor);
        if (contour.numPoints() < 100 &&  contour.numPoints() > 50) {
          stroke(150, 150, 0);
          //fill(150, 150, 0);
          beginShape();
  
          for (PVector point : contour.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2.5, point.y * 2 );
          }
          endShape();
          
          boundRect = new Rectangle(1280, 720, 0, 0);
          
          noFill();
          stroke(0,0,255);
          strokeWeight(2);
          Rectangle rec = contour.getBoundingBox();
          if(rec.width > boundRect.width && rec.height > boundRect.height){
             boundRect = rec; 
          }
          
          float centerX;
          float centerY;
          
          centerX = boundRect.x + (boundRect.width/2);
          centerY = boundRect.y + (boundRect.height/2);
          
          rect(boundRect.x * 2.5, boundRect.y * 2, boundRect.width * 2.5, boundRect.height * 2);
          fill(0,255,0);
          ellipse(centerX * 2.5, centerY * 2, 8,8);
        }
        if (contour.numPoints() > 150) {
          stroke(0, 155, 155);
          beginShape();
          fill(255);
          for (PVector point : contour.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2.5, point.y * 2 );
          }
          endShape();
          //print(contour.numPoints() + '\n');
        }
        
      }
    }
    
    for(string thisString : mString){
      thisString.draw();
    }
    
    for(balloon thisCircle : balloons){
      thisCircle.draw();
    }
    
  }
  
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  
  if (mousePressed) {
    for (balloon s: balloons) {
     s.attract(mouseX,mouseY);
    }
  }
  
  flock.run();
  
  
  //Cloud generation
  if ( (millis() - lastCloudTimeCheck > cloudTimer)) {
    lastCloudTimeCheck = millis();
    int cloudNum = int(random(4)) + 1;
    int cloudX = int(random(600));
    
    println(cloudX);
    
    cloudArray.add(new Cloud("lightClouds/cloud" + str(cloudNum) + "_light.png", 2000, (random(5)-2.5), cloudX, int(random(100))));
  }
  for(Cloud cloud : cloudArray){
    cloud.draw();
  }
  
}

// Kinect related
void keyPressed() {
  //change contour finder from contour body to depth-PC
  if( key == 'b'){
   contourBodyIndex = !contourBodyIndex;
   if(contourBodyIndex)
     threshold = 200;
    else
     threshold = 40;
  }
  if( key == 'q'){
     balloons.add(new balloon(new PVector(mouseX, mouseY), 20.0f, true, true, BodyType.DYNAMIC, mBox2D));
  }
  if (key == 'a') {
    threshold+=1;
  }
  if (key == 's') {
    threshold-=1;
  }

  if (key == '1') {
    minD += 0.01;
  }

  if (key == '2') {
    minD -= 0.01;
  }

  if (key == '3') {
    maxD += 0.01;
  }

  if (key == '4') {
    maxD -= 0.01;
  }

  if (key == '5')
    polygonFactor += 0.1;

  if (key == '6')
    polygonFactor -= 0.1;
}


// Add a new boid into the System
void mousePressed() {
  //flock.addBird(new Bird(new PVector(mouseX,mouseY),random(1.0, 6.0),0.05f));

}

// Add a new boid into the System
void mouseMoved() {
  flock.addTarget(new PVector(mouseX,mouseY));
}

int calculateThemeCycle(int themeCounter){
  if(themeCounter == 3)
      themeCounter = 0;
    else
      themeCounter ++;
   return themeCounter;
}


/////imagery

//all skies the same
void updateForest(Theme forest){
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_gate.png", 0, themeChangeTimer - 3000, 188, 474, 608, 126)); //image, parallax, lifespan, x, y, w, h
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_grass.png", 0, themeChangeTimer - 3000, 0, 511, 1280, 209));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree1.png", 0, themeChangeTimer - 3000, -47, 309, 223, 248));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree2.png", 0, themeChangeTimer - 3000, 94, 304, 306, 296));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree3.png", 0, themeChangeTimer - 3000, 846, 286, 298,332));
  
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_ground.png", 0, themeChangeTimer - 2000, 0, 514, 1280, 207));
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_tree1.png", -0.5, themeChangeTimer - 2000, 919, 206, 368, 409));
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_tree2.png", 0.5, themeChangeTimer - 2000, -38, 83, 514, 529));
  
  //forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_cloud1.png", 0, 0, 0, 200, 100));
  //forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_cloud2.png", 0, 0, 0, 200, 100));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_ground_long.png", 1, themeChangeTimer - 1000, -200, 600, 1920, 134));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom1.png", 0, themeChangeTimer - 1000, 65, 486, 216, 185));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom2.png", 0, themeChangeTimer - 1000, 209, 590, 96, 90));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom3.png", 0, themeChangeTimer - 1000, 77, 578, 77, 89));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_tree1.png", 0, themeChangeTimer - 1000, 693, -58, 822, 736));
  
  themeArray.add(forest);
}

void updateCity(Theme city){
  city.bgImgs.add(new DisplayImage("City/background/city_bg_grass.png", 0, themeChangeTimer - 3000, 0, 327, 1280, 394));//image, parallax, x, y, w, h
  city.bgImgs.add(new DisplayImage("City/background/city_bg_road.png", 0, themeChangeTimer - 3000, 704, 371, 386, 360));
  city.bgImgs.add(new DisplayImage("City/background/city_bg_post.png", 0, themeChangeTimer - 3000, 761, 292, 73, 113));
 
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_ground.png", 0, themeChangeTimer - 2000, 0, 444, 1280, 276));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_road.png", 0, themeChangeTimer - 2000, 115, 444, 979, 277));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_houseLeft.png", 0, themeChangeTimer - 2000, 50, 114, 401, 485));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_houseRight.png", 0, themeChangeTimer - 2000, 975, 270, 308, 397));
  
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_ground_long.png", 1, themeChangeTimer - 1000, -500, height-60, 1920, 89));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseLeft.png", 0, themeChangeTimer - 1000, 0, 0, 284, 685));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseRight.png", 0, themeChangeTimer - 1000, 1158, 0, 125, 720));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_lamp.png", 0, themeChangeTimer - 1000, 1118, 112, 152, 113));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_wires.png", 0, themeChangeTimer - 1000, 164, 22, 1119, 146));
  
  themeArray.add(city);
}

void updateFarm(Theme farm){
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_grass.png", 0, themeChangeTimer - 3000, 0, 418, 1280, 300));//image, parallax, time, x, y, w, h
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_farmHouse.png", 0, themeChangeTimer - 3000, 330, 328, 487, 275));
 
  farm.mgImgs.add(new DisplayImage("Farm/midground/farm_mg_crops.png", -0.5, themeChangeTimer - 2000, 0, 421, 1683, 280));
  
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_grass.png", 1, themeChangeTimer - 1000, -500, height-91, 1920, 134));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_scareCrow.png", 0, themeChangeTimer - 1000, 900, 325, 369, 403));
   
  themeArray.add(farm);
}

void updateMountain(Theme mountain){
  mountain.bgImgs.add(new DisplayImage("Mountain/background/mountain_bg_mountain.png", 0, themeChangeTimer - 3000, 0, 255, 1280, 465));//image, parallax, x, y, w, h
 
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_grass_short.png", 0, themeChangeTimer - 2000, 0, 522, 1280, 198));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_mountain_long.png", -0.5, themeChangeTimer - 2000, 0, 546, 1920, 540));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_tree1.png", 0, themeChangeTimer - 2000, 999, 175, 281, 430));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_tree2.png", 0, themeChangeTimer - 2000, 1084, 150, 196, 483));
  
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_grass_short.png", 0, themeChangeTimer - 1000, 0, height-90, 1280, 90));
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_tree1.png", 0, themeChangeTimer - 1000, 0, 286, 160, 434));
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_tree2.png", 0, themeChangeTimer - 1000, 935, 7, 345, 710));
  
  themeArray.add(mountain);
}
