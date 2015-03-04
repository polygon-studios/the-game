class DisplayImage{
  
  PImage image;
  int parallax;
  int x;
  int y;
  int w;
  int h;
  
  DisplayImage(String imgLocation, int parallaxAmount, int xLoc, int yLoc, int imgWidth, int imgHeight){
    image = loadImage(imgLocation);
    parallax = parallaxAmount;
    x = xLoc;
    y = yLoc;
    w = imgWidth;
    h = imgHeight;
  }
  
}
