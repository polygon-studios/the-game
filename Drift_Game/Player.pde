class Player{
  
  Boolean alive = true;
  int skeletonID;
  Vec2 startPos;
  float polygonFactor= 1;
  color fillColour = color(0,0,0);
  color passCol;
  
  ArrayList<Contour>       playerContours;
  ArrayList<Contour>       baloonContours;
  ArrayList<balloon>       balloonsList;
  
  float headPositionX;
  float headPositionY;
  
  PImage colourImage;

    
  Player(float headPosX, float headPosY, int ID, ArrayList<Contour> contour, ArrayList<Contour> balloonContour, PImage image){
    
    playerContours = contour;
    balloonContours = balloonContour;
    colourImage = image;
    
    headPositionX = headPosX;
    headPositionY = headPosY;
    
    alive = true;
    skeletonID = ID;
     
    startPos = new Vec2(headPosX, headPosY);
    balloonsList = new ArrayList();
    makeBalloon(balloonContour);
  }
  
  // This function removes the particle from the box2d world
  void popBalloon() 
  {
    alive = false;
  }
  
  void draw(){
    
    //println("PLAYA contours.. yeee " + playerCount);
    for(balloon thisBalloon : balloonsList){
      if(thisBalloon.isDead() == true){
         alive = false;
         println("It's dead now");
      }
      else{  
        thisBalloon.draw();
        println("Its drawn still");
      }
    }  
    
    if(!alive){
      fillColour = color(255,105,180);
    }
     
    for (Contour person : playerContours) {
      
      person.setPolygonApproximationFactor(polygonFactor);
      
      // Person contour handler
      if (person.numPoints() > 550 && person.numPoints() < 3000) {
        stroke(0, 155, 155);
        beginShape();
        fill(fillColour);
        for (PVector point : person.getPolygonApproximation().getPoints()) {
          vertex(point.x * 2 + 128, point.y *  1.8 + 130 );
        }
        endShape();
      }
      
    }
    
     
    
  }
  
  void updateContour(ArrayList<Contour> newContour){
    playerContours = newContour;
  }
  
  void makeBalloon(ArrayList<Contour> balloon){
    
    
    for (Contour balloons : balloon) {
      balloons.setPolygonApproximationFactor(polygonFactor);
      
      // Balloon countour handler
      if (balloons.numPoints() < 300 &&  balloons.numPoints() > 50) {   
        
        // Creating bounding box
        boundRect = new Rectangle(1280, 720, 0, 0);
        noFill();
        stroke(0,0,255);
        strokeWeight(2);
        Rectangle rec = balloons.getBoundingBox();
        if(rec.width > boundRect.width && rec.height > boundRect.height){
           boundRect = rec; 
        }
        
        float centerX;
        float centerY;
        
        centerX = boundRect.x + (boundRect.width/2);
        centerY = boundRect.y + (boundRect.height/2);
        
        int loc = int(centerX*3.75) + int(centerY*2.547) * 1920;
        color pointColour = colorImage.pixels[loc];
        
        //color passCol = color(r1, g1, b1);
        
        float yThreshMaxR = 255;
        float yThreshMaxG = 255;
        float yThreshMaxB = 220;
        
        float yThreshMinR = 150;
        float yThreshMinG = 200;
        float yThreshMinB = 0;
        
        float bThreshMaxR = 220;
        float bThreshMaxG = 255;
        float bThreshMaxB = 255;
        
        float bThreshMinR = 0;
        float bThreshMinG = 0;
        float bThreshMinB = 100;

        float r = red(pointColour);
        float g = green(pointColour);
        float b = blue(pointColour);
        
        if(r < yThreshMaxR && g < yThreshMaxG && b < yThreshMaxB && r > yThreshMinR && g > yThreshMinG && b > yThreshMinB){
          print("yellow\n");
          color passCol = color(255,255,0);
        }
        else if(r < bThreshMaxR && g < bThreshMaxG && b < bThreshMaxB && r > bThreshMinR && g > bThreshMinG && b > bThreshMinB){
          print("blue\n");
          color passCol = color(0,0,255);
        }
        else{
          print("unknown\n");
          color passCol = color(255,0,0);
        }
        
        // Should NOT draw balloon contours if it is below a certain y value
        if(centerY < 250){
          // Only say its a balloon if within threshold of person
          if( centerY < (headPositionY + 75) && centerY > (headPositionY - 50) && centerX < (headPositionX + 150) && centerX > (headPositionX - 150) ){
            println("Sorta within");  
            if(balloonsList.size() < 1){
              balloonsList.add(new balloon(new PVector(centerX, centerY), new PVector(boundRect.x, boundRect.y), new PVector((boundRect.x + boundRect.width), (boundRect.y + boundRect.height)), 60.0f, passCol, true, true, BodyType.DYNAMIC, mBox2D));
              println("Balloon Created");  
          }
        }
        }
        
        
      }    
    }
  }
  
  void updateBalloonContour(ArrayList<Contour> newContour, float headPosX, float headPosY, PImage image){
    
    headPositionX = headPosX;
    headPositionY = headPosY;
    
    colourImage = image;
    
    if(balloonsList.size() != 0){
       balloon b = (balloon) balloonsList.get(0);  
       b.updateContour(newContour);  // Passing the entire list of boids to each boid individually
    }
    else{
      makeBalloon(newContour);
    }
    
  }
  
  Vec2 getBalloonPos(){
    balloon b = (balloon) balloonsList.get(0);  
    return b.getPosition();
  }
   
  boolean isAlive(){
    return alive;
  }
 
  int getSkeletonID(){
    return skeletonID;
  }
   
   
}


