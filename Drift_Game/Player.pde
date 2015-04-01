class Player{
  
  Boolean alive;
  int skeletonID;
  Vec2 lastPos;

    
  Player(float startX, float startY, int skeletonID){
    
    alive = true;
     
    lastPos = new Vec2(startX, startY);
  }
  
  // This function removes the particle from the box2d world
  void popBalloon() 
  {
    alive = false;
  }
  
  void draw(){
    
  
 
       
    
   }
  
   
   boolean isAlive(){
     return alive;
   }
   
   int getSkeletonID(){
     return skeletonID;
   }
   
   
}


