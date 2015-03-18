class Cloud{
   PImage img;
   float x;
   float y;
   int lifeSpan;
   int savedTime;
   float moveX;
   
 
  Cloud(String image, int lifespan, float moveXDir, int xLoc, int yLoc){
    img = loadImage(image);
    savedTime = 0;
    lifeSpan = lifespan;
    moveX = moveXDir;
    x = xLoc;
    y = yLoc;
  }
  
  void draw(){
    x += moveX;
    tint(255, 255, 255, 255);
    image(img, x, y);
  }
  
  boolean isAlive(){
    if( millis() - savedTime > lifeSpan){
      return false;
    }
    return true;
  }
  
  
  
}
