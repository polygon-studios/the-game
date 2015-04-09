class Cloud{
   PImage img;
   float x;
   float y;
   int centreX = 0;
   int centreY = 0;
   int lifeSpan;
   int savedTime;
   float moveX;
   float trans = 0;
   boolean hasBolted = false;
 
  Cloud(PImage image, int lifespan, float moveXDir, int xLoc, int yLoc){
    img = image;
    savedTime = 0;
    lifeSpan = lifespan;
    moveX = moveXDir;
    x = xLoc;
    y = yLoc;
    centreX = int(x + img.width/2);
    centreY = int(y + img.height/2);
  }
  
  
  void draw(){
    centreX = int(x + img.width/2);
    centreY = int(y + img.height/2);
    if(trans < 255)
      trans += 20;
    
    x += moveX;
    tint(255, 255, 255, trans);
    image(img, x, y);
  }
  
  boolean isAlive(){
    if( millis() - savedTime > lifeSpan){
      if(trans > 0){
        trans -= 20;
        return true;
      }
      return false;
    }
    return true;
  }
  
  
  
}
