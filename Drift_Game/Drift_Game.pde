import gab.opencv.*;
//import KinectPV2.*;
import SimpleOpenNI.*;

//KinectPV2 kinect;
//KinectPV2 kinectBall;
OpenCV opencvBody;
OpenCV opencvBalloon;

Flock flock;

float polygonFactor = 1;

int threshold = 45;

float maxD = 4.0f;
float minD = 0.5f;


boolean    contourBodyIndex = true;

int lastTimeCheck = 0;
int themeChangeTimer = 15000; // in milliseconds
int themeCounter = 0;
import ddf.minim.*;

AudioPlayer player;
Minim minim;//audio context
boolean firstRun = true;

PImage bgImg;
PImage fgImg;
PImage mgImg;
PImage skyImg = new PImage();

ArrayList<Theme> themeArray= new ArrayList<Theme>();

void setup() {
  size(1280, 720);
  skyImg = loadImage("City/background/city_bg_sky.png");
  background(skyImg);
  
  Theme forest = new Theme("forest.png", skyImg);
  Theme city = new Theme("city.png", skyImg);
  Theme farm = new Theme("farm.png", skyImg);
  Theme mountain = new Theme("mountain.png", skyImg);
  
  updateForest(forest);
  updateCity(city);
  //updateFarm(farm);
  //updateMountain(mountain);
  //themeArray.add(city);
  themeArray.add(farm);
  themeArray.add(mountain);
  
  //getForestImages();
  minim = new Minim(this);
  player = minim.loadFile("Music.mp3", 2048);
  player.loop();
  
  flock = new Flock();
  for (int i = 0; i < 3; i++) {
    flock.addBird(new Bird(new PVector(width/2,height/2), random(1.0, 6.0) ,0.03));
  }
  smooth();
  
 /*   // Kinect related setup
    opencvBody = new OpenCV(this, 512, 424);
    kinect = new KinectPV2(this); 
    
    // Enable kinect tracking of following
    kinect.enablePointCloud(true);
    kinect.enableBodyTrackImg(true);
    kinect.enableColorImg(true);
    kinect.enableDepthImg(true);
    
    kinect.init(); */
}

void draw() {
  // KINECT STUFF
  /*
  noFill();
  image(kinect.getBodyTrackImage(), 0, 0);
    //change contour extraction from bodyIndexImg or to PointCloudDepth
  if (contourBodyIndex)
    image(kinect.getBodyTrackImage(), 0, 0);
  else
    image(kinect.getPointCloudDepthImage(), 0, 0);

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

    
  ArrayList<Contour> contours = opencvBody.findContours(); */
  if ( (millis() - lastTimeCheck > themeChangeTimer)) {
    firstRun = false;
    println("normal");
    lastTimeCheck = millis();
    Theme temp = themeArray.get(themeCounter);
    //temp.transOut = 255;
    //temp.transIn = 0;
    //temp.fullImg.loadPixels();
    //image(temp.fullImg, 0, 0, 1280, 720);
    temp.drawFullImg();
    
    //drawContours(contours);
    
    if(themeCounter == 3)
      themeCounter = 0;
    else
      themeCounter ++;
  }/*else if((second() - lastTimeCheck +4 > themeChangeTimer)){
    //fade Out
    println("here " + themeCounter);
    Theme temp = themeArray.get(themeCounter);
    temp.fadeOut();
    
    int tempThemeCounter = themeCounter;
    if(tempThemeCounter == 3)
      tempThemeCounter = 0;
    else 
      tempThemeCounter++;
    Theme tempNew = themeArray.get(tempThemeCounter);
    temp.fadeIn();
  }*/else{
    Theme temp = themeArray.get(themeCounter);
    temp.drawFullImg();
    /*
    if (contours.size() > 0) {
      for (Contour contour : contours) {
        
        contour.setPolygonApproximationFactor(polygonFactor);
        if (contour.numPoints() < 100 &&  contour.numPoints() > 50) {
          stroke(150, 150, 0);
          fill(150, 150, 0);
          beginShape();
  
          for (PVector point : contour.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2.5, point.y * 2 );
          }
          endShape();
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
    */
  }
  
  //kinect.setLowThresholdPC(minD);
  //kinect.setHighThresholdPC(maxD);
  flock.run();
}

void getForestImages(){
  //append(forest.bgImages,loadImage("forest_bg_gate.png") );
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

}

void drawCountours(ArrayList<Contour> contours){
   if (contours.size() > 0) {
      for (Contour contour : contours) {
        
        contour.setPolygonApproximationFactor(polygonFactor);
        if (contour.numPoints() < 100 &&  contour.numPoints() > 50) {
          stroke(150, 150, 0);
          beginShape();
  
          for (PVector point : contour.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2, point.y * 2 );
          }
          endShape();
        }
        if (contour.numPoints() > 150) {
          stroke(0, 155, 155);
          beginShape();
  
          for (PVector point : contour.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2, point.y * 2);
          }
          endShape();
          //print(contour.numPoints() + '\n');
        }
        
      }
    }
}

// Add a new boid into the System
void mousePressed() {
  flock.addBird(new Bird(new PVector(mouseX,mouseY),random(1.0, 6.0),0.05f));
}

// Add a new boid into the System
void mouseMoved() {
  flock.addTarget(new PVector(mouseX,mouseY));
}




/////imagery

//all skies the same
void updateForest(Theme forest){
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_gate.png", 0, 0, height-350, int(4113/3.2), int(1087/3.2))); //image, parallax, x, y, w, h
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_grass.png", 0, 0, height-int(1384/6.25)+75, 1280, int(1384/6.25)));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree1.png", 0, 0, height-400, int(1700/6.25), int(1825/6.25)));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree2.png", 0, 800, height-500, int(2180/6.25), int(2384/6.25)));
  
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_ground.png", 0.5, 0, 0, 1500, 200));
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_tree1.png", -1, 0, 0, 300, 280));
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_tree2.png", 1, 0, 0, 350, 350));
  
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_cloud1.png", 0, 0, 0, 200, 100));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_cloud2.png", 0, 0, 0, 200, 100));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_ground.png", 0, 0, 0, 1280, 200));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom1.png", 0, 0, 0, 200, 200));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom2.png", 0, 0, 0, 200, 200));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom3.png", 0, 0, 0, 200, 200));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_tree1.png", 0, 0, 0, 500, 500));
  
  themeArray.add(forest);
}

void updateCity(Theme city){
  city.bgImgs.add(new DisplayImage("City/background/city_bg_grass.png", 0, 0, height-174, 1280, 174));//image, parallax, x, y, w, h
  city.bgImgs.add(new DisplayImage("City/background/city_bg_road.png", 0, 200, height-95, 32, 95));
  city.bgImgs.add(new DisplayImage("City/background/city_bg_post.png", 0, 800, height-113, 73, 113));
 
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_ground_long.png", -4, 0, height - 89, 1920, 89));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_houseLeft.png", 0, 0, 0, 284, 685));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_houseRight.png", 0, 0, 0, 125, 720));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_road.png", 0, 0, 0, 350, 350));
  
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_ground_long.png", 2, -100, height-89, 1920, 89));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseLeft.png", 0, 0, 0, 284, 685));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseRight.png", 0, 0, 0, 125, 720));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_lamp.png", 0, 0, 0, 153, 113));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_wires.png", 0, 0, 0, 1117, 149));
  
  themeArray.add(city);
}

void updateFarm(Theme farm){
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_grass.png", 0, 0, height-int(1384/6.25)+75, 1280, int(1384/6.25)));//image, parallax, x, y, w, h
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_farmHouse.png", 0, 0, height-150, 400, 250));
 
  farm.mgImgs.add(new DisplayImage("Farm/midground/farm_mg_crops.png", 0, 0, 0, 1500, 200));
  
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_grass.png", 2, -100, height-89, 1920, 89));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_scareCrow.png", 0, 0, height-550, 500, 550));
  
  themeArray.add(farm);
}

void updateMountain(Theme mountain){
  mountain.bgImgs.add(new DisplayImage("Mountain/background/mountain_bg_mountains.png", 0, 0, height-int(1384/6.25)+75, 1280, int(1384/6.25)));//image, parallax, x, y, w, h
 
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_grass.png", 0, 0, 0, 1500, 200));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_mountains.png", 0, 0, 0, 1500, 200));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_tree1.png", 0, 0, 0, 720, 1000));
  
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_grass.png", 2, -100, height-89, 1920, 89));
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_tree1.png", 0, 0, height-550, 600, 550));
  
  themeArray.add(mountain);
}
