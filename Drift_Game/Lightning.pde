class Lightning{
  
  int x;
  int y;
  PImage[] frames;
  int currentFrame;
  int numFrames;
  boolean isAlive = true;
  
  Lightning(int xLoc, int yLoc, PImage[] aniFrames){
    x = xLoc;
    y = yLoc;
    frames = aniFrames;
    numFrames = aniFrames.length;
  }
  
  void draw(){
    if(currentFrame < 23)
      animationDraw();
    else
      isAlive = false;
  
  }
  
  void animationDraw(){
    currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
    int offset = 0;
    image(frames[(currentFrame+offset) % numFrames], x, y);
    offset+=1;
  }
  
}
