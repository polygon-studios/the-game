class Theme{
  
  //DisplayImage[] bgImages = new DisplayImage[0];
  PImage fullImg;
  PImage skyImg;
  boolean fadeOutBg = false;
  boolean incomingScene = true;
  
  ArrayList<DisplayImage> bgImgs; //background
  ArrayList<DisplayImage> mgImgs; //midground
  ArrayList<DisplayImage> fgImgs; //foreground
  
  
  Theme(String imgLoc, PImage skyBg){
    fullImg = loadImage(imgLoc);
    
    skyImg = skyBg;
    
    bgImgs = new ArrayList<DisplayImage>();
    mgImgs = new ArrayList<DisplayImage>();
    fgImgs = new ArrayList<DisplayImage>();
}
  
  void drawFullImg(){
    
   if(bgImgs.size() > 0){
      drawBgImgs();
      drawMgImgs();
      drawFgImgs();
   }else
      image(fullImg, 0, 0, 1280, 720);
  }
  
  void drawBgImgs(){
    for(int i = 0; i < bgImgs.size(); i++){
      DisplayImage temp = bgImgs.get(i);
      if(temp.isFadingOut == true)
        temp.updateTrans(true);
      else
        temp.updateTrans(false);
      tint(255, 255, 255, temp.trans);
      image(temp.image, temp.x, temp.y, temp.w, temp.h);
    }
  }
  
  void drawMgImgs(){
    for(int i = 0; i < mgImgs.size(); i++){
      DisplayImage temp = mgImgs.get(i);
      temp.updateForParallax();
      if(temp.isFadingOut == true)
        temp.updateTrans(true);
      else
        temp.updateTrans(false);
      tint(255, 255, 255, temp.trans);
      image(temp.image, temp.x, temp.y, temp.w, temp.h);
    }
  }
  
  void drawFgImgs(){
    for(int i = 0; i < fgImgs.size(); i++){
      DisplayImage temp = fgImgs.get(i);
      temp.updateForParallax();
      if(temp.isFadingOut == true)
        temp.updateTrans(true);
      else
        temp.updateTrans(false);
      if(temp.isAnimation == true)
        temp.stepAni();
      tint(255, 255, 255, temp.trans);
      image(temp.image, temp.x, temp.y, temp.w, temp.h);
    }
  }
  
 boolean checkToFadeOutBg(){
    boolean fadeOut = false;
    
    for(int i = 0; i < bgImgs.size(); i++){
      DisplayImage temp = bgImgs.get(i);
     if ( (millis() - lastTimeCheck > temp.lifeSpan)) {
       temp.isFadingOut = true;
       fadeOut = true;
       temp.updateTrans(true);
       //bgTransFadeOut();
     }
    }
   return fadeOut;
 }
 
 boolean checkToFadeOutMg(){
   boolean fadeOut = false;
   for(int i = 0; i < mgImgs.size(); i++){
      DisplayImage temp = mgImgs.get(i);
     if ( (millis() - lastTimeCheck > temp.lifeSpan)) {
       temp.isFadingOut = true;
       fadeOut = true;
       temp.updateTrans(true);
       //mgTransFadeOut();
     }
    }
   return fadeOut;
 }
 
 boolean checkToFadeOutFg(){
   boolean fadeOut = false;
   for(int i = 0; i < fgImgs.size(); i++){
      DisplayImage temp = fgImgs.get(i);
     if ( (millis() - lastTimeCheck > temp.lifeSpan)) {
       temp.isFadingOut = true;
       fadeOut = true;
       temp.updateTrans(true);
       //mgTransFadeOut();
     }
    }
   return fadeOut;
 }
  
  void bgTransFadeIn(){
    for(int i = 0; i < bgImgs.size(); i++){
      DisplayImage temp = bgImgs.get(i);
      temp.isFadingOut = false;
      temp.updateTrans(false);
    }    
  }
  
  void mgTransFadeIn(){
    for(int i = 0; i < mgImgs.size(); i++){
      DisplayImage temp = mgImgs.get(i);
      temp.isFadingOut = false;
      temp.updateTrans(false);
    }
  }
  
  void fgTransFadeIn(){
    for(int i = 0; i < fgImgs.size(); i++){
      DisplayImage temp = fgImgs.get(i);
      temp.isFadingOut = false;
      temp.updateTrans(false);
    }
  }
  


}
