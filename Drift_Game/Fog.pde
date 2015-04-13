class Fog{
  
  float xFogLoc1= 0;
  float xFogLoc2= -4918;
  
  int fogImgWidth  = 4918;
  int currentFrame = 0;
  
  PImage fogImg1;
  PImage fogImg2;
  
  
  Fog(String imageName){
    fogImg1 = loadImage(imageName);
    fogImg2 = loadImage(imageName);
  }
  
  void draw(){
    
    xFogLoc1 = xFogLoc1 + 2;  
    xFogLoc2 = xFogLoc2 + 2;
    
    if (xFogLoc1 == fogImgWidth){
      xFogLoc1= -fogImgWidth;
    }
    if (xFogLoc2 == fogImgWidth){
      xFogLoc2 = -fogImgWidth;
    }
    //noFill();
    tint(255,255,255,255);
    image(fogImg1, xFogLoc1, 246);
    image(fogImg2, xFogLoc2, 246);  
    
  }
  
}
