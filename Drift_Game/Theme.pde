class Theme{
  
  //DisplayImage[] bgImages = new DisplayImage[0];
  PImage fullImg;
  float transOut, transIn;
  
  ArrayList<DisplayImage> bgImgs; //background
  ArrayList<DisplayImage> mgImgs; //midground
  ArrayList<DisplayImage> fgImgs; //foreground
  
  
  Theme(String imgLoc){
    fullImg = loadImage(imgLoc);
    transOut = 255;  
    transIn = 0;
    
    bgImgs = new ArrayList<DisplayImage>();
    mgImgs = new ArrayList<DisplayImage>();
    fgImgs = new ArrayList<DisplayImage>();
}
  
  void drawFullImg(){
   
    /*if(fadeOut){
      transparency -= 0.05;
      tint(255, 255, 255, transparency);
    }
    else{
      println("NO");
      transparency = 1;
    }*/
    
   if(bgImgs.size() > 0)
      drawThemeImages();
    else
      image(fullImg, 0, 0, 1280, 720);
  }
  
  void drawThemeImages(){
    for(int i = 0; i < bgImgs.size(); i++){
      DisplayImage temp = bgImgs.get(i);
      image(temp.image, temp.x, temp.y, temp.w, temp.h);
    }
    
    for(int i = 0; i < mgImgs.size(); i++){
      DisplayImage temp = mgImgs.get(i);
      image(temp.image, temp.x, temp.y, temp.w, temp.h);
    }
  }
  
  void fadeOut(){
    transOut -= 0.25;
    tint(255, transOut);
    image(fullImg, 0, 0, 1280, 720);
  }
  
  void fadeIn(){
    transIn += 0.25;
    tint(255, transOut);
    image(fullImg, 0, 0, 1280, 720);
  }
  
 /* void transFullImg(){
    transparency -= 0.05;
    tint(255, 255, 255, transparency);
  }*/
  
}
