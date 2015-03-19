class Bandit{
  Arrow arrow;
  int numFrames = 7;
  int currentFrame = 0;
  PImage[] images = new PImage[numFrames];
  float x;
  float y;
  
  
  Bandit( Arrow throwArrow, PImage[] animationFrames, float xLoc, float yLoc){
    x = xLoc;
    y = yLoc;
    
    arrow = throwArrow;
    
    images = animationFrames;
  }
  
  void draw(){
    arrow.draw();
    
    if(currentFrame < 6)
      bowCycleDraw();
    else
      image(images[6], x, y);
  }
  
  void bowCycleDraw(){
    currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
    int offset = 0;
    image(images[(currentFrame+offset) % numFrames], x, y);
    offset+=1;
  }
  
}
