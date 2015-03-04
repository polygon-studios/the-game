import gab.opencv.*;
import KinectPV2.*;
import SimpleOpenNI.*;

KinectPV2 kinect;
KinectPV2 kinectBall;
OpenCV opencvBody;
OpenCV opencvBalloon;

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

ArrayList<Theme> themeArray= new ArrayList<Theme>();

void setup() {
  size(1280, 720);
  background(255);
  //lastTimeCheck = second();
  
  Theme forest = new Theme("forest.png");
  Theme city = new Theme("city.png");
  Theme farm = new Theme("farm.png");
  Theme mountain = new Theme("mountain.png");
  
  themeArray.add(forest);
  themeArray.add(city);
  themeArray.add(farm);
  themeArray.add(mountain);
  
  //getForestImages();
  minim = new Minim(this);
  player = minim.loadFile("Music.mp3", 2048);
  player.loop();
  
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
  // KINECT STUFF
  noFill();
  //image(kinect.getBodyTrackImage(), 0, 0);
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

    
  ArrayList<Contour> contours = opencvBody.findContours();
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
  }
  
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
}

void getForestImages(){
  //append(forest.bgImages,loadImage("forest_bg_gate.png") );
}

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
