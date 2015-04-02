class Player{
  
  Boolean alive = true;
  int skeletonID;
  Vec2 lastPos;
  float polygonFactor= 1;
  color fillColour = color(0,0,0);
  int playerCount;
  
  ArrayList<Contour>       playerContours;

    
  Player(float startX, float startY, int skeletonID, ArrayList<Contour> contour){
    
    playerContours = contour;
    alive = true;
     
    lastPos = new Vec2(startX, startY);
  }
  
  // This function removes the particle from the box2d world
  void popBalloon() 
  {
    alive = false;
  }
  
  void draw(){
    playerCount = 0;
    if(!alive){
      fillColour = color(255,105,180);
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
      
      playerCount++;
    }
    
    println("PLAYA contours.. yeee " + playerCount);
     
    
  }
  
  void updateContour(ArrayList<Contour> newContour){
    playerContours = newContour;
  }
   
   boolean isAlive(){
     return alive;
   }
   
   int getSkeletonID(){
     return skeletonID;
   }
   
   
}


