class Goat{
  
  int x;
  int y;
  int box2DY;
  PImage[] frames;
  int currentFrame;
  int numFrames;
  boolean isAlive = true;
  boolean triggerJump = false;
  int loopCounter = 0;
  
  Body mBody;
  float mWidth = 30;
  float mHeight = 400;
  Box2DProcessing mBox2D;
  
  Goat(int xLoc, int yLoc, PImage[] aniFrames, Box2DProcessing box2D, BodyType type){
    x = xLoc;
    y = yLoc;
    box2DY = y + 230;
    frames = aniFrames;
    numFrames = aniFrames.length;
    
    mBox2D = box2D;
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position = mBox2D.coordPixelsToWorld(x+30, box2DY);
    println("x : " + x + "    y : " + y);
    mBody = mBox2D.world.createBody(bd);
    
    CircleShape shape = new CircleShape();
    shape.m_radius = mBox2D.scalarPixelsToWorld(40);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = shape;    
    fd.density     = 1.0f;
    fd.friction    = 0.2f;
    fd.restitution = 0.1f;
    
    mBody.createFixture(fd);
    mBody.setUserData(this);  
  }
  
  void killBody() 
  {
    mBox2D.destroyBody( mBody );
  }
  
  void draw(){
    Vec2 pos = mBox2D.getBodyPixelCoord(mBody);
    float angle = mBody.getAngle();
    attract();
    
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(angle);
    popMatrix();
    //fill(255,0,0);
    //ellipse(pos.x +30, pos.y, 80, 80);
    
    animationDraw();
    
    if(loopCounter == 4){
      triggerJump = true;
      numFrames = 192;
    }
    if(currentFrame == 1 && triggerJump == true){
      triggerJump = false;
      loopCounter = 0;
      numFrames = 96;
    }
    if(currentFrame == 94){
      loopCounter ++;
    }
  
  }
  
  void attract() {
    
    Vec2 worldTarget;
    if(currentFrame > 97 && currentFrame < 120){
      
      float xTrans = (currentFrame - 97) * 2;
      worldTarget= mBox2D.coordPixelsToWorld(x+xTrans, box2DY); 
      
    }else if(currentFrame > 119 && currentFrame < 150){
      
      float xTrans = (119 - 97) * 2;
      worldTarget= mBox2D.coordPixelsToWorld(x+xTrans, box2DY); 
    }
    else if (currentFrame > 149 && currentFrame < 168){
      
      float xTrans = x + 40;
      float yTrans = (currentFrame - 168) + 10;
      float yEq = (20*abs(yTrans)) + box2DY - 180;
      
      if(currentFrame > 161)
        xTrans += (currentFrame - 168) * 1.5 -10;        
        
      worldTarget= mBox2D.coordPixelsToWorld(xTrans,yEq); 
      
    }
    else{
      
      worldTarget= mBox2D.coordPixelsToWorld(x , box2DY); 
      
    }
    
    Vec2 bodyVec = mBody.getWorldCenter();
    mBody.setTransform(worldTarget, 0);
  }
  
  void animationDraw(){
    
      currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
      int offset = 0;
      image(frames[(currentFrame+offset) % numFrames], x, y);
      offset+=1;
   
    
    
  }
  
}
