// Imports
import gab.opencv.*;
import KinectPV2.*;
import KinectPV2.KJoint;
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
//Flock               flock;
Rectangle           boundRect;
Skeleton []         skeleton;
ParticleSystem      ps;
Goat                goat;
Fog                 fog;

// ArrayLists
ArrayList<Rectangle>     rectangles;
ArrayList<Contour>       boundingBox;

ArrayList<Theme>         themeArray= new ArrayList<Theme>();
ArrayList<Cloud>         cloudArray= new ArrayList<Cloud>();
ArrayList<Cloud>         darkCloudArray = new ArrayList<Cloud>();
ArrayList<Lightning>     lightningArray = new ArrayList<Lightning>();
ArrayList<Bandit>        banditArray= new ArrayList<Bandit>();
ArrayList<Tree>          treeArray= new ArrayList<Tree>();

ArrayList<string>        babyBalloon = new ArrayList<string>();
ArrayList<balloon>       balloons = new ArrayList<balloon>();
ArrayList<Player>        players = new ArrayList<Player>();
ArrayList<Flock>         flock = new ArrayList<Flock>();


//flock = new Flock();

ArrayList<Contour>       balloonContours;
ArrayList<Contour>       playerContours;
// Kinect related variables
float polygonFactor       = 1;
float maxD                = 3.0f;
float minD                = 1.5f;
PImage colorImage;

int currentBalloon        = 0;
int numBalloons           = 0;
int maxBalloons           = 0;
int numberOfPlayers       = 0;
int counter               = 0;
int threshold             = 45;
int maxBirds              = 1;
int currentBirds          = 0;

float newXPos = 0;
float newYPos = 0;

color passCol = color(255, 255, 0);

int balloon1R;
int balloon1G;
int balloon1B;

int balloon2R;
int balloon2G;
int balloon2B;
  
boolean    contourBodyIndex = false;
boolean    alreadyDeleted = false;

int collision = 0;

// Theme related variables
int lastTimeCheck           = 0;
int lastCloudTimeCheck      = 0;
int lastDarkCloudTimeCheck  = 0;
int lastBanditTimeCheck     = 0;
int lastBirdTimeCheck       = 0;
int themeChangeTimer        = 110000; // in milliseconds 97000
int cloudTimer              = 20000; //in milliseconds
int darkCloudTimer          = 40000; //in milliseconds
int banditTimer             = 15000; // in milliseconds 15000
int birdTimer               = 25000;
int currentTheme            = 1;
int nextTheme               = 2;

PImage bgImg;
PImage fgImg;
PImage mgImg;
PImage skyImg = new PImage();

PImage[] fogFrames = new PImage[400];
PImage[] cloudImages = new PImage[4]; //cloud type options
PImage[] darkCloudImages = new PImage[4]; //cloud type options
PImage[] lightningImages = new PImage[24];
PImage[] banditFrames = new PImage[14];
PImage[] birdFrames = new PImage[19];
PImage[] wireFrames = new PImage[95];
PImage[] lampFrames = new PImage[95];
PImage[] mushroom1Frames = new PImage[95];
PImage[] mushroom2Frames = new PImage[95];
PImage[] mushroom3Frames = new PImage[95];
PImage[] rockFrames = new PImage[96];
PImage[] goatFrames = new PImage[192];
PImage[] scareCrowFrames = new PImage[96];
PImage[] greenBBPopFrames = new PImage[7];
PImage[] blueBBPopFrames = new PImage[7];
PImage[] whiteBBPopFrames = new PImage[7];
PImage[] yellowBBPopFrames = new PImage[7];


// Audio variables
AudioPlayer[] player = new AudioPlayer[4]; 
AudioPlayer bowPlayer;
AudioPlayer thunderPlayer;
AudioPlayer poppingPlayer;

Minim minim;//audio context


void setup() {
  // Intialize backgound stuff
  size(1280, 720);
  skyImg = loadImage("City/background/city_bg_sky.png");
  fog = new Fog("Fog.png");
  background(skyImg);
  frameRate(24);
  
  loadAnimations();
  
  Theme forest =   new Theme("forest.png", skyImg, true);
  Theme city =     new Theme("city.png", skyImg, false);
  Theme farm =     new Theme("farm.png", skyImg, true);
  Theme mountain = new Theme("mountain.png", skyImg, false);
  
  updateForest(forest);
  updateCity(city);
  updateFarm(farm);
  updateMountain(mountain);
  
  minim = new Minim(this);
  player[0] = minim.loadFile("forestMusic.mp3", 2048);
  player[1] = minim.loadFile("cityMusic.mp3", 2048);
  player[2] = minim.loadFile("farmMusic.mp3", 2048);
  player[3] = minim.loadFile("mountainMusic.mp3", 2048);
  player[currentTheme].play();
  
  bowPlayer = minim.loadFile("bow_release.mp3");
  thunderPlayer = minim.loadFile("thunder.mp3");
  poppingPlayer = minim.loadFile("pop2.mp3");
 
  ps = new ParticleSystem();
  
  flock.add(new Flock());
  
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
  
  kinect.init();
}

void draw() {
  for(int i=0; i< players.size(); i++){
    Player tempPlayer= players.get(i);
      if(tempPlayer.toDelete == true){
        players.remove(i);
        println("REMOVED ZE PLAYAAAA!");
        break;
      } 
  }
  
  for(Player thisPlayer : players){
    if(thisPlayer.alive == false){
       if(thisPlayer.balloonDeleted == false){
         thisPlayer.removeBalloon();
       }
    }
  }
  
  mBox2D.step();
  background(skyImg);
  
  
  // Resetting variables each time
  maxBalloons = 0;
  numberOfPlayers = 0;
  
  //
  // KINECT RELATED - GETTING VARIOUS IMAGES ETC
  //
  
  noFill(); 

  // Open CV on bodytrack image
  opencvBody.loadImage(kinect.getPointCloudDepthImage());
  opencvBody.gray();
  opencvBody.threshold(threshold);
  //PImage dst = opencvBody.getOutput();

  // Open CV on pointcloud depth for ballon
  opencvBalloon.loadImage(kinect.getPointCloudDepthImage());
  opencvBalloon.gray();
  opencvBalloon.dilate();
  opencvBalloon.blur(20);
  opencvBalloon.erode();
  opencvBalloon.threshold(threshold);
  PImage dst = opencvBalloon.getOutput();
  
  
  // Load our colour image for balloon colours
  opencvColour.loadImage(kinect.getColorImage());
  colorImage = opencvColour.getSnapshot();
  
  // Finding contours  
  balloonContours = opencvBalloon.findContours(); 
  playerContours = opencvBody.findContours(false, false);
  
  // Finding skeletons
  skeleton =  kinect.getSkeletonDepthMap();
  
  
  
  //
  // CHANGING THE THEME STUFF
  //
  
  // Theme changing
  if ( (millis() - lastTimeCheck > themeChangeTimer)) {
    lastTimeCheck = millis();
    
    println("1: CURRENTTHEME: " + currentTheme + " NEXTTHEME: " + nextTheme);
    
    player[currentTheme].close();
    
    currentTheme = calculateThemeCycle(currentTheme);
    nextTheme = calculateThemeCycle(currentTheme);
      
    Theme temp = themeArray.get(currentTheme);
    temp.drawBgImgs();
    temp.drawMgImgs();
    fog.draw();
    temp.drawFireflies();
    cloudGen();
    darkCloudGen();
    temp.drawFgImgs();
    
    for(Bandit bandit : banditArray){
      bandit.arrow.trans = 0;
    }
    player[currentTheme].rewind();
    player[currentTheme].play();

    alreadyDeleted = false;
    println("2: CURRENTTHEME: " + currentTheme + " NEXTTHEME: " + nextTheme);
  }else{
    Theme temp = themeArray.get(currentTheme);
    
    
    if(temp.checkToFadeOutBg() == true){
      Theme newTemp = themeArray.get(nextTheme);
      newTemp.bgTransFadeIn();
      newTemp.drawBgImgs();
    }
    temp.drawBgImgs();
    if(temp.checkToFadeOutMg() == true){
      Theme newTemp = themeArray.get(nextTheme);
      newTemp.mgTransFadeIn();
      newTemp.drawMgImgs();
    }
    temp.drawMgImgs();
    fog.draw();
    if(temp.checkToFadeOutFg() == true){
      Theme newTemp = themeArray.get(nextTheme);
      newTemp.fgTransFadeIn();
      newTemp.drawFgImgs();
    }
    
    
    
    temp.drawFireflies();
    cloudGen();
    darkCloudGen();
    temp.drawFgImgs();
  }

  
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  
  //image(kinect.getPointCloudDepthImage(), 0, 0); 
  //image(kinect.getColorImage(), 0, 0);
  //image(dst, 0, 0); 
  
  
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      boolean alreadyCreated = false;
      //println("Skeleton at: " + i + " is tracked");     
      // If there are no players
      if(players.size() == 0){
        // Determine position of head of skeleton
        KJoint[] joints = skeleton[i].getJoints();
        Vec2 headPos = getHeadPos(joints, KinectPV2.JointType_Head);
        float headXPos = headPos.x;
        float headYPos = headPos.y;
        //println("Headposition: " + headXPos + "x " + headYPos + "y");
        players.add(new Player(headXPos, headYPos, i, playerContours, balloonContours, colorImage));
        numberOfPlayers += 1;
        alreadyCreated = true;
      }
      // Check to see if there is already a skeleton with that skeletonID
      for(Player thisPlayer : players){
        int id = thisPlayer.getSkeletonID();
        if( i == id){
          alreadyCreated = true;
          
        }
      }
      
      // Create a skeleton if that ID hasn't been tracked already
      if(alreadyCreated == false)
      {
        println("Blehhhh????");
        // Determine position of head of skeleton
        KJoint[] joints = skeleton[i].getJoints();
        Vec2 headPos = getHeadPos(joints, KinectPV2.JointType_Head);
        float headXPos = headPos.x;
        float headYPos = headPos.y;
        //println("Headposition: " + headXPos + "x " + headYPos + "y");
        players.add(new Player(headXPos, headYPos, i, playerContours, balloonContours, colorImage));
      }
      
      maxBalloons += 1;
    }
  }


   
  if(players.size() != 0){
  
    if(balloons.size() > 0){
      for(balloon thisBalloon : balloons){
        thisBalloon.draw();
      }
      
      for(int i=0; i < balloons.size(); i++){
        balloon thisBalloon = balloons.get(i);
        if( thisBalloon.isDead() == true){
          balloons.remove(i);
          break;
        }
      }
    }
    
    if(collision > 0){
      babyBalloon.add(new string(new PVector (newXPos, newYPos), new PVector (500, 250 + 15.0), 30, passCol, mBox2D));
      collision = 0;
    }
    
    for(Player thisPlayer : players){
       // We want to delete the player if they are no longer trackeds
       boolean isTracked = false;
       int id = thisPlayer.getSkeletonID();
       
       for (int i = 0; i < skeleton.length; i++) {
          if (skeleton[i].isTracked()) {
            if(id == i){
              isTracked = true;
            }
          }
       }
       if(isTracked){
         thisPlayer.updateContour(playerContours);
         
         int i = thisPlayer.getSkeletonID();
         KJoint[] joints = skeleton[i].getJoints();   
         Vec2 headPos = getHeadPos(joints, KinectPV2.JointType_Head);
         float headXPos = headPos.x;
         float headYPos = headPos.y;
         thisPlayer.updateBalloonContour(balloonContours, headXPos, headYPos, colorImage);
         thisPlayer.draw();
         //println("drawin");
      }
      else{
        thisPlayer.toDelete = true; 
      }
    }
   
  }
  
  for(int i=0; i< babyBalloon.size(); i++){
    string tempString= babyBalloon.get(i);
    for(int j=0; j< tempString.mString.size(); j++){
      babyBalloon tempBB = tempString.mString.get(j);
      if(tempBB.hit == true && tempBB.currentFrame == (greenBBPopFrames.length-1)){
        babyBalloon.remove(i);
        break;
      }
    }
    
  }
  
  
  
  // Drawing everything
  Flock thisFlock = flock.get(0);  
  thisFlock.run();
  banditGen();
  birdGen();
  treeGen();
  goatGen();
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
    themeChangeTimer = 97000;
  }
  if (key == 's') {
    themeChangeTimer = 10000;
  }
  
  if (key == 'z') {
    banditTimer = 15000;
  }
  if (key == 'x') {
    banditTimer = 1000;
  }
  
  if (key == 'g') {
    babyBalloon.add(new string(new PVector (mouseX, mouseY), new PVector (500, 250 + 15.0), 30, color(0,255,0), mBox2D));
  }
  if (key == 'b') {
    babyBalloon.add(new string(new PVector (mouseX, mouseY), new PVector (500, 250 + 15.0), 30, color(0,0,255), mBox2D));
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
  
  if (key == 'p') {
    Flock thisFlock = flock.get(0);  
    thisFlock.addBird(new Bird(new PVector(0,height/4), random(1.0, 6.0) ,0.03, mBox2D, birdFrames));
  }
  
  

  if (key == '5')
    polygonFactor += 0.1;

  if (key == '6')
    polygonFactor -= 0.1;
  
  if (key == 't'){//change theme
    lastTimeCheck = -themeChangeTimer;
  }
  if (key == 'm'){//bandit
    lastBanditTimeCheck = -banditTimer;
  }
  if (key == 'l'){//dark cloud for lightning
    lastDarkCloudTimeCheck = -darkCloudTimer;
  }
}

Vec2 getHeadPos(KJoint[] joints, int jointType) {
  float xPos = joints[jointType].getX();
  float yPos = joints[jointType].getY();
  Vec2 position = new Vec2(xPos, yPos);
  return position;
}


// Add a new boid into the System
void mousePressed() {
  babyBalloon.add(new string(new PVector (mouseX, mouseY), new PVector (mouseX, mouseY + 15.0), 30, passCol, mBox2D));
}

// Add a new boid into the System
void mouseMoved() {
  Flock thisFlock = flock.get(0);  
  thisFlock.addTarget(new PVector(1280,400));
}


//called when Box2D elements have stopped touching each other
void beginContact(Contact cp) 
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
    
    balloon1R = Balloon1.getRColor();
    balloon1G = Balloon1.getGColor();
    balloon1B = Balloon1.getBColor();
    
    balloon2R = Balloon2.getRColor();
    balloon2G = Balloon2.getGColor();
    balloon2B = Balloon2.getBColor();
    
    if(balloon1R == 255 && balloon1G == 255 && balloon1B == 0 && balloon2R == 255 && balloon2G == 255 && balloon2B == 0){
      passCol = color(255, 255, 0);
      println("Yellow BB"); 
    }
    if(balloon1R == 0 && balloon1G == 0 && balloon1B == 255 && balloon2R == 0 && balloon2G == 0 && balloon2B == 255){
      passCol = color(0, 0, 255);
      println("Blue BB"); 
    }
    
    if(balloon1R == 0 && balloon1G == 0 && balloon1B == 255){
      if(balloon2R == 255 && balloon2G == 255 && balloon2B == 0){
        passCol = color(0, 255, 0);
        println("Green BB"); 
      }
    }
    
    if(balloon1R == 255 && balloon1G == 255 && balloon1B == 0){
      if(balloon2R == 0 && balloon2G == 0 && balloon2B == 255){
        passCol = color(0, 255, 0);
        println("Green BB"); 
      }
    }
    
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
  
  ////tree collision
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
    
    if(o1.getClass() == babyBalloon.class || o2.getClass() == babyBalloon.class){
      
        if (o1.getClass() == babyBalloon.class) {
          babyBalloon tempBaby = (babyBalloon)o1;
          tempBaby.setPoppingFrames(setBBpoppingFrames());
          tempBaby.hit = true;
        }else if(o2.getClass() == babyBalloon.class){
          babyBalloon tempBaby = (babyBalloon)o2;
          tempBaby.setPoppingFrames(setBBpoppingFrames());
          tempBaby.hit = true;
        }
    }
  }
  
  ////lightning collision
  if (o1.getClass() == Lightning.class || o2.getClass() == Lightning.class) {
    if(o1.getClass() == balloon.class || o2.getClass() == balloon.class){
      if (o1.getClass() == Lightning.class) {
          balloon touchBalloon = (balloon)o2;
          touchBalloon.hit = true;
        }else if(o2.getClass() == Lightning.class){
          balloon touchBalloon = (balloon)o1;
          touchBalloon.hit = true;
        }
    }
    
    if(o1.getClass() == babyBalloon.class || o2.getClass() == babyBalloon.class){
      
        if (o1.getClass() == babyBalloon.class) {
          babyBalloon tempBaby = (babyBalloon)o1;
          tempBaby.setPoppingFrames(setBBpoppingFrames());
          tempBaby.hit = true;
        }else if(o2.getClass() == babyBalloon.class){
          babyBalloon tempBaby = (babyBalloon)o2;
          tempBaby.setPoppingFrames(setBBpoppingFrames());
          tempBaby.hit = true;
        }
    }
  }
  
  ////Goat collision
  if (o1.getClass() == Goat.class || o2.getClass() == Goat.class) {
    if(o1.getClass() == balloon.class || o2.getClass() == balloon.class){
      if (o1.getClass() == Goat.class) {
          balloon touchBalloon = (balloon)o2;
          touchBalloon.hit = true;
        }else if(o2.getClass() == Goat.class){
          balloon touchBalloon = (balloon)o1;
          touchBalloon.hit = true;
        }
    }
    
    if(o1.getClass() == babyBalloon.class || o2.getClass() == babyBalloon.class){
      
        if (o1.getClass() == babyBalloon.class) {
          babyBalloon tempBaby = (babyBalloon)o1;
          tempBaby.setPoppingFrames(setBBpoppingFrames());
          tempBaby.hit = true;
        }else if(o2.getClass() == babyBalloon.class){
          babyBalloon tempBaby = (babyBalloon)o2;
          tempBaby.setPoppingFrames(setBBpoppingFrames());
          tempBaby.hit = true;
        }
    }
  }
  
  ////Bird collision
  if (o1.getClass() == Bird.class || o2.getClass() == Bird.class) {
    if(o1.getClass() == balloon.class || o2.getClass() == balloon.class){
      println("BIRD COLLISION");
      if (o1.getClass() == Bird.class) {
          
          balloon touchBalloon = (balloon)o2;
          touchBalloon.hit = true;
        }else if(o2.getClass() == Bird.class){
          balloon touchBalloon = (balloon)o1;
          touchBalloon.hit = true;
        }
    }
  }
}

PImage[] setBBpoppingFrames(){
  return yellowBBPopFrames;
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
    
    if(players.size() > 0 || keyPressed){
      
      if(keyPressed){
        balloonX = 1000;
        balloonY = 400;
        
        Arrow arrow = new Arrow(mBox2D, banditX+67, banditY+89, balloonX, balloonY);
        
        Bandit bandit = new Bandit(arrow, banditFrames, bowPlayer, banditX, banditY );
        banditArray.add(bandit);
      }else{
      
        int balloonIdx = int(random(balloons.size()));
      
        Player thisPlayer = players.get(balloonIdx);
        Vec2 balloonPos = thisPlayer.getBalloonPos(); 
        
        balloonX = int(balloonPos.x);
        balloonY = int(balloonPos.y);
        //balloonX = 1000;
        //balloonY = 400;
        
        Arrow arrow = new Arrow(mBox2D, banditX+67, banditY+89, balloonX, balloonY);
        
        Bandit bandit = new Bandit(arrow, banditFrames, bowPlayer, banditX, banditY );
        banditArray.add(bandit);
      }
    }
    
  }
  if(banditArray.size() > 0){
    for(Bandit bandit : banditArray){
      bandit.draw();
    }
    
    for(int i=0; i < banditArray.size(); i++){
      Bandit bandit = banditArray.get(i);
      if( bandit.arrow.isAlive() == false){
        bandit.removeArrow();
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
    int cloudNum = int(random(4));
    int cloudX = int(random(600));
    
    //println(cloudX);
    
    cloudArray.add(new Cloud(cloudImages[cloudNum], int(random(20000, 60000)), (random(5)-2.5), cloudX, int(random(200)-100)));
  }
  for(Cloud cloud : cloudArray){
    cloud.draw();
  }
  
  for(int i=0; i < cloudArray.size(); i++){
    Cloud cloud = cloudArray.get(i);
    if( cloud.isAlive() == false){
      cloudArray.remove(i);
      break;
    }
  }
  
}

//dark cloud generation
void darkCloudGen(){
  if ( (millis() - lastDarkCloudTimeCheck > darkCloudTimer)) {
    lastDarkCloudTimeCheck = millis();
    int cloudNum = int(random(4));
    int cloudX = int(random(800)) + 200;
    //if(darkCloudArray.size() < 2)//remove line
    float xDir = (random(5)-2.5);
    
    while(xDir < 1 && xDir > -1){
      xDir = (random(5)-2.5);
    }
    
      darkCloudArray.add(new Cloud(darkCloudImages[cloudNum], int(random(20000, 60000)), xDir, cloudX, int(random(200)-100)));
  }
  for(Cloud darkCloud : darkCloudArray){
    darkCloud.draw();
    
    for(Cloud darkCloud2 : darkCloudArray){
      if(darkCloud.centreX != darkCloud2.centreX){
        if(darkCloud.hasBolted == false && darkCloud2.hasBolted == false){
          
          if(((darkCloud2.centreX - 75  < darkCloud.centreX + 75) && 
            (darkCloud2.centreX + 75 > darkCloud.centreX - 75))){
              
            darkCloud.lifeSpan = 0;
            darkCloud2.lifeSpan = 0;
            darkCloud.hasBolted = true;
            darkCloud2.hasBolted = true;
            
            //create Lightning at the centre of two clouds
            int centreX = int((darkCloud.centreX + darkCloud2.centreX)/2);
            int centreY = int((darkCloud.centreY + darkCloud2.centreY)/2);
            lightningArray.add(new Lightning(centreX, centreY, lightningImages, mBox2D,BodyType.STATIC, thunderPlayer));
            
          }
        }
      }
     // if(darkCloud2.centreX - 150 < darkCloud.centreX +150 && darkCloud2.centreX + 150 
    }
    
  }
  
  for(Lightning lightning : lightningArray){
    lightning.draw();
  }
  for(int i=0; i < lightningArray.size(); i++){
    Lightning lightning = lightningArray.get(i);
    if( lightning.isAlive == false){
      lightning.killBody();
      lightningArray.remove(i);
      break;
    }
  }
  /*for(int i=0; i < darkCloudArray.size(); i++){
    Cloud cloud = darkCloudArray.get(i);
    if( cloud.isAlive() == false){
      darkCloudArray.remove(i);
      break;
    }
  }*/
}


//Bird generation
void birdGen(){
  
  Flock thisFlock = flock.get(0);  
  Vec2 position;
  
  if ( (millis() - lastBirdTimeCheck > birdTimer)) {
    if(currentBirds < maxBirds){
      lastBirdTimeCheck = millis();
      
      thisFlock.addBird(new Bird(new PVector(0,height/4), random(1.0, 6.0) ,0.03, mBox2D, birdFrames));
      currentBirds++;
    }
  }
  
  if(thisFlock.birds.size() != 0){
    position = thisFlock.getBirdPos();
    if(position.x > 1280 || position.y > 720){
      thisFlock.birds.remove(0);
      currentBirds--;
    }
  }
}

// Tree collidable generation
void treeGen(){
  
  if(alreadyDeleted == false){
    
    if(treeArray.size() != 0){
      println(treeArray.size());
      for(int i = treeArray.size() - 1; i >= 0; i--){
        Tree thisTree = treeArray.get(i);
        thisTree.killBody();
        treeArray.remove(i);
        println("Should have removed tree");
      }
    }
    alreadyDeleted = true;
  }
  
  if(currentTheme == 0){
    for (Tree t: treeArray) {
        t.draw();
    }
    if(treeArray.size() == 0){
      treeArray.add(new Tree(new PVector(1150, 150), 150.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(1015, 290), 50.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(925, 340), 40.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(800, 330), 10.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(810, 140), 5.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(955, 200), 40.0f, BodyType.STATIC, mBox2D));
    }
  }
  
  if(currentTheme == 2){
    for (Tree t: treeArray) {
        t.draw();
    }
    if(treeArray.size() == 0){
      treeArray.add(new Tree(new PVector(890, 275), 6.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(930, 275), 6.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(965, 275), 6.0f, BodyType.STATIC, mBox2D));
    }
  }
  
  if(currentTheme == 3){
    for (Tree t: treeArray) {
        t.draw();
    }
    if(treeArray.size() == 0){
      treeArray.add(new Tree(new PVector(1150, 500), 150.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(1100, 315), 50.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(985, 550), 40.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(1115, 220), 40.0f, BodyType.STATIC, mBox2D));
      treeArray.add(new Tree(new PVector(1125, 170), 40.0f, BodyType.STATIC, mBox2D));
    }
  }

  
}

//Goat for mountain
void goatGen(){
  if(currentTheme == 3){
    if(goat == null){
      goat = new Goat(600, 300, goatFrames,mBox2D, BodyType.STATIC);
    }else{
      goat.draw();
    }
  }else{
    if(goat != null){
      goat.killBody();
      goat = null;
    }
  }
}


/***********************

BACKGROUND FUNCTIONS

*************************/


void loadAnimations(){
  for(int i = 0; i < cloudImages.length; i++){
    String imageName = "lightClouds/cloud" + str(i + 1) + "_light.png";
    cloudImages[i] = loadImage(imageName);
  }
  for(int i = 0; i < cloudImages.length; i++){
    String imageName = "darkClouds/cloud" + str(i + 1) + "_dark.png";
    darkCloudImages[i] = loadImage(imageName);
  }
  for(int i = 0; i < lightningImages.length; i++){
    String imageName = "lightning/lightningCycle_" + str(i + 1) + ".png";
    lightningImages[i] = loadImage(imageName);
  }
  for (int i = 0; i < 14; i++) {
    String imageName = "Bandit/banditCycle_" + (i+1) + ".png";
    banditFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < 19; i++) {
    String imageName = "Bird/birdCycle_step" + (i+1) + ".png";
    birdFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < 95; i++) {
    String imageName = "City/foreground/wire/wireCycle_" + (i+1) + ".png";
    wireFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < lampFrames.length; i++) {
    String imageName = "City/foreground/lamp/lampCycle_" + (i+1) + ".png";
    lampFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < scareCrowFrames.length; i++) {
    String imageName = "Farm/foreground/scareCrow/scarecrowCycle_" + (i+1) + ".png";
    scareCrowFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < mushroom1Frames.length; i++) {
    String imageName = "Forest/foreground/mushroom1/mushroom1_Cycle00" + (i+1) + ".png";
    mushroom1Frames[i] = loadImage(imageName);
  }
  for (int i = 0; i < mushroom2Frames.length; i++) {
    String imageName = "Forest/foreground/mushroom2/mushroom2_Cycle" + (i+1) + ".png";
    mushroom2Frames[i] = loadImage(imageName);
  }
  for (int i = 0; i < mushroom3Frames.length; i++) {
    String imageName = "Forest/foreground/mushroom3/mushroom3_Cycle" + (i+1) + ".png";
    mushroom3Frames[i] = loadImage(imageName);
  }
  for (int i = 0; i < 96; i++){
    String imageName = "Mountain/midground/rockAni/rollingRock_" + (i+1) + ".png";
    rockFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < goatFrames.length; i++){
    String imageName = "Mountain/foreground/goat/mountainGoat_" + (i+1) + ".png";
    goatFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < greenBBPopFrames.length; i++){
    String imageName = "bbPop/babyBalloon_g/babyBalloon_g_" + (i+1) + ".png";
    greenBBPopFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < blueBBPopFrames.length; i++){
    String imageName = "bbPop/babyBalloon_b/babyBalloon_b_" + (i+1) + ".png";
    blueBBPopFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < whiteBBPopFrames.length; i++){
    String imageName = "bbPop/babyBalloon_w/babyBalloon_w_" + (i+1) + ".png";
    whiteBBPopFrames[i] = loadImage(imageName);
  }
  for (int i = 0; i < yellowBBPopFrames.length; i++){
    String imageName = "bbPop/babyBalloon_y/babyBalloon_y_" + (i+1) + ".png";
    yellowBBPopFrames[i] = loadImage(imageName);
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
  forest.fgImgs.add(new DisplayImage(mushroom1Frames, 0, themeChangeTimer - 1000, 40, 0, 0, 1280, 720, 0));
  forest.fgImgs.add(new DisplayImage(mushroom2Frames, 0, themeChangeTimer - 1000, 40, 209, 590, 101, 93, 0));
  forest.fgImgs.add(new DisplayImage(mushroom3Frames, 0, themeChangeTimer - 1000, 40, 65, 578, 96, 100, 0));
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
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_mailbox1.png", 0, themeChangeTimer - 2000, 25, 433, 340, 72, 141));
  city.mgImgs.add(new DisplayImage("City/midground/city_mg_mailbox2.png", 0, themeChangeTimer - 2000, 25, 920, 531, 84, 166));
  
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_ground_long.png", 0.7, themeChangeTimer - 1000, 40, -640, height-60, 1920, 89));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseLeft.png", 0, themeChangeTimer - 1000, 40, 0, 0, 284, 685));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_houseRight.png", 0, themeChangeTimer - 1000, 40, 1158, 0, 125, 720));
  city.fgImgs.add(new DisplayImage("City/foreground/city_fg_flowers.png", 0, themeChangeTimer - 1000, 40, 1000, 549, 198, 132));
  city.fgImgs.add(new DisplayImage(lampFrames, 0, themeChangeTimer - 1000, 40, 1118, 112, 152, 113, 0));
  city.fgImgs.add(new DisplayImage(wireFrames, 0, themeChangeTimer - 1000, 40, 164, 22, 1120, 156, 0));
  
  themeArray.add(city);
}

void updateFarm(Theme farm){
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_grass.png", 0, themeChangeTimer - 5000, 15, 0, 418, 1280, 300));//image, parallax, time, x, y, w, h
  farm.bgImgs.add(new DisplayImage("Farm/background/farm_bg_barn.png", 0, themeChangeTimer - 5000, 15, 400, 330, 324, 183));
 
  farm.mgImgs.add(new DisplayImage("Farm/midground/farm_mg_crops.png", -0.3, themeChangeTimer - 2000, 25, 0, 421, 1683, 280));
  
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_grass_long.png", 0.4, themeChangeTimer - 1000, 40, -640, height-91, 1920, 134));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_pitchfork.png", 0, themeChangeTimer - 1000, 40, 890, 270, 80, 438));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_tree.png", 0, themeChangeTimer - 1000, 40, 0, 100, 420, 622));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_hayBale.png", 0, themeChangeTimer - 1000, 40, 1180, 600, 211, 111));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_hayBale.png", 0, themeChangeTimer - 1000, 40, 1180, 520, 211, 111));
  farm.fgImgs.add(new DisplayImage("Farm/foreground/farm_fg_hayPile.png", 0, themeChangeTimer - 1000, 40, 110, 600, 243, 125));
  farm.fgImgs.add(new DisplayImage(scareCrowFrames, 0, themeChangeTimer - 1000, 40, 870, 325, 369, 403, 0));
  
  themeArray.add(farm);
}

void updateMountain(Theme mountain){
  mountain.bgImgs.add(new DisplayImage("Mountain/background/mountain_bg_mountain.png", 0, themeChangeTimer - 3000, 15, 0, 255, 1280, 465));//image, parallax, x, y, w, h
 
 mountain.mgImgs.add(new DisplayImage("Mountain/midground/mountain_mg_mountain2.png", 0, themeChangeTimer - 2000, 25, 0, 327, 1280, 393));
  mountain.mgImgs.add(new DisplayImage(rockFrames, 0, themeChangeTimer - 2000, 25, 0, 310, 554, 297, 4000));
  
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_grass_short.png", 0, themeChangeTimer - 1000, 40, 0, height-90, 1280, 90));
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_tree1.png", 0, themeChangeTimer - 1000, 40, 0, 286, 160, 434));
  mountain.fgImgs.add(new DisplayImage("Mountain/foreground/mountain_fg_tree2.png", 0, themeChangeTimer - 1000, 40, 935, 7, 345, 710));
  themeArray.add(mountain);
}
