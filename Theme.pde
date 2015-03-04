class Theme{
  
  //DisplayImage[] bgImages = new DisplayImage[0];
  PImage fullImg;
  float transOut, transIn;
  
  Theme(String imgLoc){
    fullImg = loadImage(imgLoc);
    transOut = 255;  
    transIn = 0;
}
  
  void drawFullImg(){
    //fullImg.loadPixels();
    /*if(fadeOut){
      println("YEs");
      transparency -= 0.05;
      tint(255, 255, 255, transparency);
    }
    else{
      println("NO");
      transparency = 1;
    }*/
    image(fullImg, 0, 0, 1280, 720);
  }
  
  void fadeOut(){
    //transOut -= 0.25;
    //tint(255, transOut);
    image(fullImg, 0, 0, 1280, 720);
  }
  
  void fadeIn(){
    //transIn += 0.25;
    //tint(255, transOut);
    image(fullImg, 0, 0, 1280, 720);
  }
  
 /* void transFullImg(){
    transparency -= 0.05;
    tint(255, 255, 255, transparency);
  }*/
  
}
