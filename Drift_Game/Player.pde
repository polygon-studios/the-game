class Player{
  
  Boolean alive = true;
  int skeletonID;
  Vec2 startPos;
  float polygonFactor= 1;
  color fillColour = color(0,0,0);
  
  ArrayList<Contour>       playerContours;
  ArrayList<balloon>       balloonsList;

    
  Player(float headPosX, float headPosY, int ID, ArrayList<Contour> contour, ArrayList<Contour> balloonContour, PImage colourImage){
    
    playerContours = contour;
    alive = true;
    skeletonID = ID;
     
    startPos = new Vec2(headPosX, headPosY);
    balloonsList = new ArrayList();
    for (Contour balloons : balloonContour) {
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
        
        float r1 = red(pointColour);
        float g1 = green(pointColour);
        float b1 = blue(pointColour);
        color passCol = color(r1, g1, b1);
        
        // Should NOT draw balloon contours if it is below a certain y value
        if(centerY < 250){
          // Only say its a balloon if within threshold of person
          if( centerY < (headPosY + 75) && centerY > (headPosY - 50) && centerX < (headPosX + 150) && centerX > (headPosX - 150) ){
           
            if(balloonsList.size() < 1){
              balloonsList.add(new balloon(new PVector(centerX, centerY), new PVector(boundRect.x, boundRect.y), new PVector((boundRect.x + boundRect.width), (boundRect.y + boundRect.height)), 60.0f, passCol, true, true, BodyType.DYNAMIC, mBox2D));
              println("Balloon Created");  
          }
        }
        }
        
        
      }    
    }
  }
  
  // This function removes the particle from the box2d world
  void popBalloon() 
  {
    alive = false;
  }
  
  void draw(){
    
    if(!alive){
      fillColour = color(255,105,180);
    }
    
    //println("PLAYA contours.. yeee " + playerCount);
    for(balloon thisBalloon : balloonsList){
       thisBalloon.draw();
    }  
     
    for (Contour person : playerContours) {
      
      person.setPolygonApproximationFactor(polygonFactor);
      
      // Person contour handler
      if (person.numPoints() > 550 && person.numPoints() < 3000) {
        stroke(0, 155, 155);
        beginShape();
        fill(0);
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
  
  void updateBalloonContour(ArrayList<Contour> newContour){
    balloon b = (balloon) balloonsList.get(0);  
    b.updateContour(newContour);  // Passing the entire list of boids to each boid individually
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


