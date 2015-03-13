class DisplayImage{
  
  PImage image;
  float parallax;
  float x;
  int y;
  int w;
  int h;
  
  DisplayImage(String imgLocation, float parallaxAmount, int xLoc, int yLoc, int imgWidth, int imgHeight){
    image = loadImage(imgLocation);
    parallax = parallaxAmount;
    x = xLoc;
    y = yLoc;
    w = imgWidth;
    h = imgHeight;
    
  }
  
  void updateForParallax(){
    x += parallax;
  }
}
