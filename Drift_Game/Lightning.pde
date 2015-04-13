class Lightning{
  
  int x;
  int y;
  int startY;
  PImage[] frames;
  int currentFrame;
  int numFrames;
  boolean isAlive = true;
  AudioPlayer soundEffect;
  
  Body mBody;
  float mWidth = 30;
  float mHeight = 400;
  Box2DProcessing mBox2D;
  
  Lightning(int xLoc, int yLoc, PImage[] aniFrames, Box2DProcessing box2D, BodyType type, AudioPlayer thunderPlayer){
    x = xLoc;
    y = yLoc;
    startY = yLoc - 350;
    frames = aniFrames;
    numFrames = aniFrames.length;
    soundEffect = thunderPlayer;
    
    if(!soundEffect.isPlaying()){
      soundEffect.rewind();
      soundEffect.play();
    }
    
    mBox2D = box2D;
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position = mBox2D.coordPixelsToWorld(x + 80, startY);
    println("x : " + x + "    y : " + y);
    mBody = mBox2D.world.createBody(bd);
    
    PolygonShape shape = new PolygonShape();
    float box2DW = mBox2D.scalarPixelsToWorld( mWidth );          
    float box2DH = mBox2D.scalarPixelsToWorld( mHeight ); 
    shape.setAsBox( box2DW, box2DH );  
    
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
    
    
    if(currentFrame < 15){
      pushMatrix();
       translate(pos.x,pos.y);
       rotate(angle);
       popMatrix();
    }
    
    if(currentFrame < 23)
      animationDraw();
    else
      isAlive = false;
  
  }
  
  void attract() {
    
    float yPos = currentFrame*20 + startY;
    
    Vec2 worldTarget = mBox2D.coordPixelsToWorld(x + 80,yPos);   
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
