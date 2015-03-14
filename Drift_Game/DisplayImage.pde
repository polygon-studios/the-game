class DisplayImage{
  
  PImage image;
  float parallax;
  float trans; //image transparency
  float lifeSpan; //amount of time image appears on screen
  float x;
  int y;
  int w;
  int h;
  boolean isFadingOut;
  
  DisplayImage(String imgLocation, float parallaxAmount, float lifespan, int xLoc, int yLoc, int imgWidth, int imgHeight){
    image = loadImage(imgLocation);
    parallax = parallaxAmount;
    x = xLoc;
    y = yLoc;
    w = imgWidth;
    h = imgHeight;
    trans = 0;
    lifeSpan = lifespan;
    isFadingOut = false;
  }
  
  void updateForParallax(){
    x += parallax;
  }
  
  void updateTrans(boolean fadeOut){
 
    if(fadeOut == true && trans > 0)
      trans -= lifeSpan/255;
    else if(fadeOut == false && trans < 255)
      trans += lifeSpan/255;
      
  }
}
