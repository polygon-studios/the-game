class DisplayImage{
  
  PImage image;
  PImage aniFrames[];
  float parallax;
  float trans; //image transparency
  float lifeSpan; //amount of time image appears on screen
  float transitionSpeed;
  float xOrig = 0;
  float x;
  int y;
  int w;
  int h;
  int currentFrame = 0;
  int numFrames;
  int delayTimer;
  int lastTimeCheck;
  boolean isFadingOut;
  boolean isAnimation;
  
  DisplayImage(String imgLocation, float parallaxAmount, float lifespan, float transSpeed, int xLoc, int yLoc, int imgWidth, int imgHeight){
    image = loadImage(imgLocation);
    parallax = parallaxAmount;
    x = xLoc;
    y = yLoc;
    w = imgWidth;
    h = imgHeight;
    trans = 0;
    lifeSpan = lifespan;
    isFadingOut = false;
    transitionSpeed = transSpeed;
    isAnimation = false;
    
    if(parallaxAmount != 0)
      xOrig = xLoc;
  }
  
  DisplayImage(PImage[] animationFrames, float parallaxAmount, float lifespan, float transSpeed, int xLoc, int yLoc, int imgWidth, int imgHeight, int delay){
    aniFrames = animationFrames;
    image = aniFrames[0];
    parallax = parallaxAmount;
    x = xLoc;
    y = yLoc;
    w = imgWidth;
    h = imgHeight;
    trans = 0;
    lifeSpan = lifespan;
    isFadingOut = false;
    transitionSpeed = transSpeed;
    isAnimation = true;
    numFrames = aniFrames.length;
    delayTimer = delay;
    lastTimeCheck = 0;
    
    if(parallaxAmount != 0)
      xOrig = xLoc;
  }
  
  void updateForParallax(){
    x += parallax;
  }
  
  void updateTrans(boolean fadeOut){
   
    if(fadeOut == true && trans > 0)
      trans -= transitionSpeed;
    else if(fadeOut == false && trans < 255)
      trans += transitionSpeed;
      
   if(trans < 5 && parallax != 0)
        x = xOrig;     
  }
  
  void stepAni(){
    if(delayTimer == 0){
       currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
      int offset = 0;
      image = aniFrames[(currentFrame+offset) %numFrames];
      offset+=1;
    }else{
      
      if(currentFrame < numFrames-1 || (millis() - lastTimeCheck > delayTimer)){
        //trans = 255;
        lastTimeCheck = millis();
        currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
        int offset = 0;
        image = aniFrames[(currentFrame+offset) %numFrames];
        offset+=1;
      }else{
        trans = 0;
      }
      
    }
  }
}
