// Imports
import gab.opencv.*;
import KinectPV2.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.dynamics.joints.*;
import java.awt.Rectangle;
import ddf.minim.*;

// Constructors
KinectPV2           kinect;
OpenCV              opencvBody;
OpenCV              opencvBalloon;
OpenCV              opencvColour;
Box2DProcessing     mBox2D;
Flock               flock;
Rectangle           boundRect;
Skeleton []         skeleton;

// ArrayLists
ArrayList<Rectangle>     rectangles;
ArrayList<Contour>       boundingBox;

ArrayList<Theme>         themeArray= new ArrayList<Theme>();
ArrayList<Cloud>         cloudArray= new ArrayList<Cloud>();
ArrayList<Bandit>        banditArray= new ArrayList<Bandit>();
ArrayList<Tree>          treeArray= new ArrayList<Tree>();

ArrayList<string>        babyBalloon = new ArrayList<string>();
ArrayList<balloon>       balloons = new ArrayList<balloon>();
ArrayList<Player>        players = new ArrayList<Player>();

ArrayList<Contour>       contours;
ArrayList<Contour>       playerContours;
// Kinect related variables
float polygonFactor       = 1;
float maxD                = 3.5f;
float minD                = 2.5f;
PImage colorImage;

int currentBalloon        = 0;
int numBalloons           = 0;
int maxBalloons           = 0;
int numberOfPlayers       = 0;
int counter               = 0;
int threshold             = 45;

float newXPos = 0;
float newYPos = 0;
  
boolean    contourBodyIndex = false;

int collision = 0;

// Theme related variables
int lastTimeCheck           = 0;
int lastCloudTimeCheck      = 0;
int lastBanditTimeCheck     = 0;
int lastBirdTimeCheck       = 0;
int themeChangeTimer        = 97000; // in milliseconds 97000
int cloudTimer              = 30000; //in milliseconds
int banditTimer             = 15000; // in milliseconds 15000
int birdTimer               = 25000;
int currentTheme            = 0;
int nextTheme               = 1;

PImage bgImg;
PImage fgImg;
PImage mgImg;
PImage skyImg = new PImage();

PImage[] banditFrames = new PImage[14];

boolean firstRun = false;

// Audio variables
AudioPlayer[] player = new AudioPlayer[4]; 
AudioPlayer bowPlayer;

Minim minim;//audio context


void setup() {
  // Intialize backgound stuff
  size(1280, 720);
  skyImg = loadImage("City/background/city_bg_sky.png");
  background(skyImg);
  frameRate(24);
  
  loadAnimations();
  
  Theme forest =   new Theme("forest.png", skyImg);
  Theme city =     new Theme("city.png", skyImg);
  Theme farm =     new Theme("farm.png", skyImg);
  Theme mountain = new Theme("mountain.png", skyImg);
  
  updateForest(forest);
  updateCity(city);
  updateFarm(farm);
  updateMountain(mountain);
  
  minim = new Minim(this);
  player[0] = minim.loadFile("forestMusic.mp3", 2048);
  player[1] = minim.loadFile("cityMusic.mp3", 2048);
  player[2] = minim.loadFile("farmMusic.mp3", 2048);
  player[3] = minim.loadFile("mountainMusic.mp3", 2048);
  player[0].play();
  
  bowPlayer = minim.loadFile("bow_release.mp3");
  
  flock = new Flock();
  
  smooth();
    
  mBox2D = new Box2DProcessing(this);
  mBox2D.createWorld();
  mBox2D.setGravity(0, -40);
  mBox2D.listenForCollisions(); 
  
  //
  // KINECT RELATED
  //
  
  opencvBody = new OpenCV(this, 512, 424);
  opencvBalloon = new OpenCV(this, 512, 424);
  opencvColour = new OpenCV(this, 1920, 1080);
  opencvColour.useColor();
  kinect = new KinectPV2(this); 
  
  // Enable kinect tracking of following
  kinect.enablePointCloud(true);
  kinect.enableBodyTrackImg(true);
  kinect.enableColorImg(true);
  kinect.enableDepthImg(true);
  kinect.enableSkeleton(true );
  kinect.enableSkeletonDepthMap(true);
  kinect.enableLongExposureInfraredImg(true);
  
  kinect.init();
}

void draw() {
  mBox2D.step();
  background(skyImg);
  
  // Resetting variables each time
  maxBalloons = 0;
  numberOfPlayers = 0;
  
  //
  // KINECT RELATED
  //
  
  noFill(); 

  // Open CV on bodytrack image
  opencvBalloon.loadImage(kinect.getBodyTrackImage());
  opencvBalloon.gray();
  kinect.getBodyTrackImage().loadPixels();
  opencvBalloon.threshold(threshold);
  //PImage dst = opencvBody.getOutput();

  // Open CV on pointcloud depth for ballon
  opencvBody.loadImage(kinect.getPointCloudDepthImage());
  opencvBody.gray();
  opencvBody.dilate();
  opencvBody.blur(20);
  opencvBody.erode();
  opencvBody.threshold(threshold);
  //PImage dst = opencvBody.getOutput();
  
  
  // Load our colour image for balloon colours
  opencvColour.loadImage(kinect.getColorImage());
  colorImage = opencvColour.getSnapshot();
  
  // Finding contours  
  contours = opencvBody.findContours(); 
  playerContours = opencvBalloon.findContours();
  
  // Finding skeletons
  skeleton =  kinect.getSkeletonDepthMap();
  
  
  // Theme changing
  if ( (millis() - lastTimeCheck > themeChangeTimer)) {
    lastTimeCheck = millis();
    
    println("1: CURRENTTHEME: " + currentTheme + " NEXTTHEME: " + nextTheme);
    if(firstRun == false){
      currentTheme = calculateThemeCycle(currentTheme);
      nextTheme = calculateThemeCycle(currentTheme);
    }
    
    Theme temp = themeArray.get(currentTheme);
    //temp.drawFullImg();
    temp.drawBgImgs();
    temp.drawMgImgs();
    cloudGen();
    temp.drawFgImgs();
    
    for(Bandit bandit : banditArray){
      bandit.arrow.trans = 0;
    }
    player[currentTheme].rewind();
    player[currentTheme].play();

    
    firstRun = false;
    println("2: CURRENTTHEME: " + currentTheme + " NEXTTHEME: " + nextTheme);
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
    
    temp.drawBgImgs();
    temp.drawMgImgs();
    cloudGen();
    temp.drawFgImgs();
  }

  
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  
  image(kinect.getPointCloudDepthImage(), 0, 0); 
  //image(kinect.getColorImage(), 0, 0);
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      if(players.size() == 0){
        players.add(new Player(30.0f, 30.0f, i));
      }
      maxBalloons += 1;
      numberOfPlayers += 1;
      
    }
  }
  
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      findContours();
      //println(skeleton.length);
    }
  }
  
//  if(numberOfPeople == 0){
//    for(balloon thisBalloon : balloons){
//      thisBalloon.killBody();
//    }
//  }
  
  PImage dst = opencvBody.getOutput();
  
   
  if(numberOfPlayers != 0){
  
    if(balloons.size() > 0){
      for(balloon thisBalloon : balloons){
        //thisBalloon.draw();
      }
      
      for(int i=0; i < balloons.size(); i++){
        balloon thisBalloon = balloons.get(i);
        if( thisBalloon.isAlive() == true){
          balloons.remove(i);
          break;
        }
      }
    }
    
    if(collision > 0){
      babyBalloon.add(new string(new PVector (newXPos, newYPos), new PVector (500, 250 + 15.0), 30, mBox2D));
      collision = 0;
    }
    
   
  }
  
  
  // Drawing everything
  flock.run();
  banditGen();
  birdGen();
  treeGen();
  for(string thisString : babyBalloon){
    thisString.draw();
  }
  
}


/***********************

SECONDARY FUNCTIONS

*************************/

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
     //balloons.add(new balloon(new PVector(mouseX, mouseY), 20.0f, true, true, BodyType.DYNAMIC, mBox2D));
  }
  if (key == 'a') {
    threshold+=1;
  }
  if (key == 's') {
    threshold-=1;
  }

  if (key == '1') {
    minD += 0.1;
  }

  if (key == '2') {
    minD -= 0.1;
  }

  if (key == '3') {
    maxD += 0.1;
  }

  if (key == '4') {
    maxD -= 0.1;
  }

  if (key == '5')
    polygonFactor += 0.1;

  if (key == '6')
    polygonFactor -= 0.1;
}


// Add a new boid into the System
void mousePressed() {
  babyBalloon.add(new string(new PVector (mouseX, mouseY), new PVector (mouseX, mouseY + 15.0), 30, mBox2D));
}

// Add a new boid into the System
void mouseMoved() {
  flock.addTarget(new PVector(mouseX,mouseY));
}


//called when Box2D elements have stopped touching each other
void endContact(Contact cp) 
{
  // Get both shapes ( A and B )
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  
  // Get both bodies so we can compare later
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies .. Objects are undefined object types ...
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  //check if one of objects is a CircleBody .. if so continue
  if (o1.getClass() == Arrow.class || o2.getClass() == Arrow.class) {
    if(o1.getClass() == balloon.class || o2.getClass() == balloon.class){
    
      Arrow arrow1;
      if (o1.getClass() == Arrow.class) {
        arrow1 = (Arrow)o1;
        arrow1.hit = true; //hit causes the arrow to fade away and to remove the bandit from the scene.
        balloon touchBalloon = (balloon)o2;
        touchBalloon.hit = true;
      }else if(o2.getClass() == Arrow.class){
        arrow1 = (Arrow)o2;
        arrow1.hit = true; //hit causes the arrow to fade away and to remove the bandit from the scene.
        balloon touchBalloon = (balloon)o1;
        touchBalloon.hit = true;
      }
    }
  }
     
  if (o1.getClass() == balloon.class && o2.getClass() == balloon.class) {
    
    int balloon1xPos = 0;
    int balloon1yPos = 0;
    int balloon2xPos = 0;
    int balloon2yPos = 0;
    
    collision = 1;
    balloon Balloon1 = (balloon)o1;
    balloon Balloon2 = (balloon)o2;
    
    Vec2 balloon1Pos = Balloon1.getPosition(); 
    Vec2 balloon2Pos = Balloon2.getPosition(); 
    
    balloon1xPos = int(balloon1Pos.x);
    balloon1yPos = int(balloon1Pos.y);
    balloon2xPos = int(balloon2Pos.x);
    balloon2yPos = int(balloon2Pos.y);
    
    if(balloon1xPos > balloon2xPos){
      newXPos = balloon1xPos - balloon2xPos + balloon2xPos;
      newYPos = balloon1yPos - 100;
    }
    else {
      newXPos = balloon2xPos - balloon1xPos + balloon1xPos;
      newYPos = balloon2yPos - 100;
    }
    println(newXPos);
  }
  
  if (o1.getClass() == Tree.class || o2.getClass() == Tree.class) {
    if(o1.getClass() == balloon.class || o2.getClass() == balloon.class){
      if (o1.getClass() == Tree.class) {
          balloon touchBalloon = (balloon)o2;
          touchBalloon.hit = true;
        }else if(o2.getClass() == Tree.class){
          balloon touchBalloon = (balloon)o1;
          touchBalloon.hit = true;
        }
    }
  }
}



void findContours(){
    currentBalloon = 0;
    
    // Loop through all the countours
    for (Contour contour : contours) {
      
      contour.setPolygonApproximationFactor(polygonFactor);
      
      // Balloon countour handler
      if (contour.numPoints() < 200 &&  contour.numPoints() > 100) {   
        
        // Creating bounding box
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
        
        counter = 0;
        for (balloon s: balloons) {
          //println("Current Balloon: " + currentBalloon + " counter: " + counter);
          if(counter == currentBalloon){
            s.attract(centerX * 2 + 128,centerY * 1.8 + 130);
            //println("attract");
          }
          if(numBalloons > currentBalloon + 1){
          // s.attract(1920,1080);
          }
          counter++;
        }
        currentBalloon++;
        
        int loc = int(centerX*3.75) + int(centerY*2.547) * 1920;
        color pointColour = colorImage.pixels[loc];
        
        float r1 = red(pointColour);
        float g1 = green(pointColour);
        float b1 = blue(pointColour);
        color passCol = color(r1, g1, b1);
        // Should NOT draw balloon contours if it is below a certain y value
        if(centerY < 300){
          // Drawing the contours
          stroke(150, 150, 0);
          fill(r1, g1, b1);
          beginShape();
       
          ArrayList<PVector> points = contour.getPolygonApproximation().getPoints();
          for (PVector point : points) {
            curveVertex(point.x * 2 + 128, point.y * 1.8 + 130 );
          }
          
          PVector firstPoint = points.get(1);
          curveVertex(firstPoint.x * 2 + 128, firstPoint.y * 1.8 + 130 ); 
          endShape();
          
          // Drawing bounding box and center point
          //rect(boundRect.x * 2 + 128, boundRect.y * 1.8 + 72, boundRect.width * 2.5, boundRect.height * 1.8 + 72);
          //fill(0,255,0);
          //ellipse(centerX * 2 + 128, centerY * 1.8 + 72, 8,8);
        }
        if(numBalloons < maxBalloons){
         balloons.add(new balloon(new PVector(centerX, centerY), 60.0f, passCol, true, true, BodyType.DYNAMIC, mBox2D));
         numBalloons++;
        }
        
      }
      
      // Person contour handler
      if (contour.numPoints() > 550 && contour.numPoints() < 3000) {
        stroke(0, 155, 155);
        beginShape();
        fill(0);
        for (PVector point : contour.getPolygonApproximation().getPoints()) {
          vertex(point.x * 2 + 128, point.y *  1.8 + 130 );
        }
        endShape();
      }
      
      
      
    }
    
}
/***********************

OBJECT GENERATION

*************************/

void banditGen(){
  if ( (millis() - lastBanditTimeCheck > banditTimer)) {
    lastBanditTimeCheck = millis();
    
    int banditX =0;
    int banditY =0;
    
    switch(currentTheme){
      case 0: 
        banditX = 125;
        banditY = 272;
        break;
      case 1: //city
        int balconyNum = int(random(2));
        if(balconyNum == 1){
          banditX = 184;
          banditY = 77;
        }else{
          banditX = 185;
          banditY = 335;
        }
        break;
      case 2: 
        banditX = 87;
        banditY = 450;
        break;
      case 3: 
        banditX = 143;
        banditY = 447;
        break;
      default:
        banditX = 87;
        banditY = 450;
        break;
    }
    
    
    int balloonX = int(random(1280));
    int balloonY = int(random(720));
    
    if(balloons.size() > 0){
      
      int balloonIdx = int(random(balloons.size()));
    
      balloon thisBalloon = balloons.get(balloonIdx);
      Vec2 balloonPos = thisBalloon.getPosition(); 
      
      balloonX = int(balloonPos.x);
      balloonY = int(balloonPos.y);
      
      Arrow arrow = new Arrow(mBox2D, banditX+67, banditY+89, balloonX, balloonY);
      
      Bandit bandit = new Bandit(arrow, banditFrames, bowPlayer, banditX, banditY );
      banditArray.add(bandit);
    }
    
  }
  if(banditArray.size() > 0){
    for(Bandit bandit : banditArray){
      bandit.draw();
    }
    
    for(int i=0; i < banditArray.size(); i++){
      Bandit bandit = banditArray.get(i);
      if( bandit.arrow.isAlive() == false){
        banditArray.remove(i);
        break;
      }
    }
    
    
  }
  
}


//Cloud generation
void cloudGen(){
  if ( (millis() - lastCloudTimeCheck > cloudTimer)) {
    lastCloudTimeCheck = millis();
    int cloudNum = int(random(4)) + 1;
    int cloudX = int(random(600));
    
    //println(cloudX);
    
    cloudArray.add(new Cloud("lightClouds/cloud" + str(cloudNum) + "_light.png", 2000, (random(5)-2.5), cloudX, int(random(200)-100)));
  }
  for(Cloud cloud : cloudArray){
    cloud.draw();
  }
}

//Bird generation
void birdGen(){
  if ( (millis() - lastBirdTimeCheck > birdTimer)) {
    lastBirdTimeCheck = millis();
    
    flock.addBird(new Bird(new PVector(0,height/4), random(1.0, 6.0) ,0.03, mBox2D));
  
  }
}

// Tree collidable generation
void treeGen(){
  
  if(treeArray.size() == 0){
    treeArray.add(new Tree(new PVector(1150, 150), 150.0f, BodyType.STATIC, mBox2D));
    treeArray.add(new Tree(new PVector(1015, 290), 50.0f, BodyType.STATIC, mBox2D));
    treeArray.add(new Tree(new PVector(925, 340), 40.0f, BodyType.STATIC, mBox2D));
    treeArray.add(new Tree(new PVector(800, 330), 10.0f, BodyType.STATIC, mBox2D));
    treeArray.add(new Tree(new PVector(810, 140), 5.0f, BodyType.STATIC, mBox2D));
    treeArray.add(new Tree(new PVector(955, 200), 40.0f, BodyType.STATIC, mBox2D));
  }
  
  if(currentTheme == 0){
    for (Tree t: treeArray) {
        //t.attract(900,200);
        t.draw();
    }
  }
  
  
}



/***********************

BACKGROUND FUNCTIONS

*************************/


void loadAnimations(){
  for (int i = 0; i < 14; i++) {
    String imageName = "Bandit/banditCycle_" + (i+1) + ".png";
    banditFrames[i] = loadImage(imageName);
  }
}

int calculateThemeCycle(int themeCounter){
  if(themeCounter == 3)
      themeCounter = 0;
    else
      themeCounter ++;
   return themeCounter;
}

//all skies the same
void updateForest(Theme forest){
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_gate.png", 0, themeChangeTimer - 5000, 15, 188, 474, 608, 126)); //image, parallax, lifespan, x, y, w, h
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_grass.png", 0, themeChangeTimer - 5000, 15, 0, 511, 1280, 209));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree1.png", 0, themeChangeTimer - 5000, 15, -47, 309, 223, 248));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree2.png", 0, themeChangeTimer - 5000, 15, 94, 304, 306, 296));
  forest.bgImgs.add(new DisplayImage("Forest/background/forest_bg_tree3.png", 0, themeChangeTimer - 5000, 15, 846, 286, 298,332));
  
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_ground.png", 0, themeChangeTimer - 2000, 25, 0, 514, 1280, 207));
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_tree1.png", -0.3, themeChangeTimer - 2000, 25, 919, 206, 368, 409));
  forest.mgImgs.add(new DisplayImage("Forest/midground/forest_mg_tree2.png", -0.3, themeChangeTimer - 2000, 25, -38, 83, 514, 529));
  
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_ground_long.png", 0.7, themeChangeTimer - 1000, 40, -640, 600, 1920, 134));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom1.png", 0, themeChangeTimer - 1000, 40, 65, 486, 216, 185));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom2.png", 0, themeChangeTimer - 1000, 40, 209, 590, 96, 90));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_mushroom3.png", 0, themeChangeTimer - 1000, 40, 77, 578, 77, 89));
  forest.fgImgs.add(new DisplayImage("Forest/foreground/forest_fg_tree1.png", 0, themeChangeTimer - 1000, 40, 793, -58, 822, 736));
  
  themeArray.add(forest);
}

void updateCity(Theme city){
  city.bgImgs.add(new DisplayImage("City/background/city_bg_grass.png", 0, themeChangeTimer - 5000, 15, 0, 327, 1280, 394));//image, parallax, x, y, w, h
  city.bgImgs.add(new DisplayImage("City/background/city_bg_road.png", 0, themeChangeTimer - 5000, 15, 704, 371, 386, 360));
  city.bgImgs.add(new DisplayImage("City/background/city_bg_post.png", 0, themeChangeTimer - 5000, 15, 761, 292, 73, 113));
 
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_ground.png", 0, themeChangeTimer - 2000, 25, 0, 444, 1280, 276));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_road.png", 0, themeChangeTimer - 2000, 25, 115, 444, 979, 277));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_houseLeft.png", 0, themeChangeTimer - 2000, 25, 50, 114, 401, 485));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_houseRight.png", 0, themeChangeTimer - 2000, 25, 975, 270, 308, 397));
  
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_ground_long.png", 0.7, themeChangeTimer - 1000, 40, -640, height-60, 1920, 89));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseLeft.png", 0, themeChangeTimer - 1000, 40, 0, 0, 284, 685));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseRight.png", 0, themeChangeTimer - 1000, 40, 1158, 0, 125, 720));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_lamp.png", 0, themeChangeTimer - 1000, 40, 1118, 112, 152, 113));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_wires.png", 0, themeChangeTimer - 1000, 40, 164, 22, 1119, 146));
  
  themeArray.add(city);
}

void updateFarm(Theme farm){
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_grass.png", 0, themeChangeTimer - 5000, 15, 0, 418, 1280, 300));//image, parallax, time, x, y, w, h
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_farmHouse.png", 0, themeChangeTimer - 5000, 15, 330, 328, 487, 275));
 
  farm.mgImgs.add(new DisplayImage("Farm/midground/farm_mg_crops.png", -0.3, themeChangeTimer - 2000, 25, 0, 421, 1683, 280));
  
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_grass_long.png", 0.7, themeChangeTimer - 1000, 40, -640, height-91, 1920, 134));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_scareCrow.png", 0, themeChangeTimer - 1000, 40, 900, 325, 369, 403));
   
  themeArray.add(farm);
}

void updateMountain(Theme mountain){
  mountain.bgImgs.add(new DisplayImage("Mountain/background/mountain_bg_mountain.png", 0, themeChangeTimer - 3000, 15, 0, 255, 1280, 465));//image, parallax, x, y, w, h
 
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_grass_short.png", 0, themeChangeTimer - 2000, 25, 0, 522, 1280, 198));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_mountain_long.png", -0.5, themeChangeTimer - 2000, 25, 0, 546, 1920, 540));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_tree1.png", -0.25, themeChangeTimer - 2000, 25, 999, 175, 281, 430));
  mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_tree2.png", 0, themeChangeTimer - 2000, 25, 1084, 150, 196, 483));
  
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_grass_short.png", 0, themeChangeTimer - 1000, 40, 0, height-90, 1280, 90));
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_tree1.png", 0, themeChangeTimer - 1000, 40, 0, 286, 160, 434));
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_tree2.png", 0, themeChangeTimer - 1000, 40, 935, 7, 345, 710));
  
  themeArray.add(mountain);
}
