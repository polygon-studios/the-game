class Player{
  
  Boolean alive = true;
  Boolean toDelete = false;
  Boolean balloonDeleted = false;
  int skeletonID;
  Vec2 startPos;
  float polygonFactor= 1;
  color fillColour = color(random(0, 255),random(0, 255),0);
  
  int rVal = 0;
  int gVal = 0;
  int bVal = 0;
  
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
  

  
  void removeBalloon(){
    balloon b = (balloon) balloonsList.get(0);  
    b.removeBody();
    balloonDeleted = true;
    balloonsList.remove(0);
    println("Balloon array size:" + balloonsList.size());
  }
  
  void draw(){
    
    //println("PLAYA contours.. yeee " + playerCount);
    for(balloon thisBalloon : balloonsList){
      if(thisBalloon.isDead() == true){
         alive = false;
         println("Balloon array size: " + balloonsList.size() + "on skeleton ID:" + skeletonID);
      }
      else{  
        thisBalloon.draw();
        println("Balloon array size: " + balloonsList.size() + "on skeleton ID:" + skeletonID);
      }
    }  
    
    if(!alive){
      fillColour = color(255,105,180);
    }
    else{
      //fillColour = color(0,0,0);
    }
    
    //rect(boundRect.x * 2 + 128, boundRect.y * 1.8 + 130, boundRect.width * 2.5, boundRect.height * 1.8 + 130);
     
    for (Contour person : playerContours) {
      
      person.setPolygonApproximationFactor(polygonFactor);
      
      // Person contour handler
      if (person.numPoints() > 550 && person.numPoints() < 3000) {
        
        // Creating bounding box
        boundRect = new Rectangle(1280, 720, 0, 0);
        //noFill();
        //stroke(0,0,255);
        //strokeWeight(2);
        Rectangle rec = person.getBoundingBox();
        if(rec.width > boundRect.width && rec.height > boundRect.height){
           boundRect = rec; 
        }
        
        float centerX;
        float centerY;
        
        centerX = boundRect.x + (boundRect.width/2);
        centerY = boundRect.y + (boundRect.height/2);
        
        
        if(centerX < (headPositionX + 75) && centerX > (headPositionX - 75)) {
          stroke(0, 155, 155);
          beginShape();
          fill(fillColour);
          for (PVector point : person.getPolygonApproximation().getPoints()) {
            vertex(point.x * 2 + 128, point.y *  1.8 + 130 );
          }
          endShape();
          noFill();
        }
        
        
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
          rVal = 255;
          gVal = 255;
          bVal = 0;
        }
        else if(r < bThreshMaxR && g < bThreshMaxG && b < bThreshMaxB && r > bThreshMinR && g > bThreshMinG && b > bThreshMinB){
          print("blue\n");
          rVal = 0;
          gVal = 0;
          bVal = 255;
        }
        else{
          print("unknown\n");
          //color passCol = color(255,0,0);
          rVal = 255;
          gVal = 0;
          bVal = 0;
          println("Passing colour: R:" + rVal + " G:" + gVal + " B:" + bVal);
        }
        
        // Should NOT draw balloon contours if it is below a certain y value
        if(centerY < 250){
          // Only say its a balloon if within threshold of person
          if( centerY < (headPositionY + 100) && centerY > (headPositionY - 100) && centerX < (headPositionX + 150) && centerX > (headPositionX - 150) ){
            println("Sorta within");  
            if(balloonsList.size() < 1){
              balloonsList.add(new balloon(new PVector(centerX, centerY), new PVector(boundRect.x, boundRect.y), new PVector((boundRect.x + boundRect.width), (boundRect.y + boundRect.height)), 60.0f, rVal, gVal, bVal, true, true, BodyType.DYNAMIC, mBox2D));
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
      if(alive){
        makeBalloon(newContour);
      }
    }
    
  }
  
  Vec2 getBalloonPos(){
    if(balloonsList.size() != 0){
      balloon b = (balloon) balloonsList.get(0);  
      return b.getPosition();
    }
    Vec2 blank = new Vec2(500, 500);
    return blank;
  }
   
  boolean isAlive(){
    return alive;
  }
  
  boolean isMarkedForDeletion(){
    return toDelete; 
  }
 
  int getSkeletonID(){
    return skeletonID;
  }
  

   
   
}


