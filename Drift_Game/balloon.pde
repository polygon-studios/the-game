class balloon{
  
  Body mBody;
  float mRadius;
  Box2DProcessing mBox2D;
  Boolean hit = false;
  float xPos;
  float yPos;
  
  color balloonCol = color(255, 255, 255);
  
  PImage img;
  
  balloon(PVector startPos, float radius, boolean initVel, boolean antiGrav, BodyType type, Box2DProcessing box2D){
    
   
    mBox2D = box2D;
    mRadius = radius;
    
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position = mBox2D.coordPixelsToWorld(startPos.x, startPos.y);
    xPos = startPos.x;
    yPos = startPos.y;
    
    mBody = mBox2D.world.createBody(bd);
    if(antiGrav){
      mBody.setGravityScale(-0.0);
    }
    
    CircleShape shape = new CircleShape();
    shape.m_radius = mBox2D.scalarPixelsToWorld(radius);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = shape;    
    fd.density     = 1.0f;
    fd.friction    = 0.2f;
    fd.restitution = 0.1f;
    
    mBody.createFixture(fd);
    
    if(initVel == true){
      //mBody.setLinearVelocity(new Vec2(random(0.0f, 2.0), random(0.0f, 2.0)));
      mBody.setAngularVelocity(random(1.0, 2.0));
    }

    mBody.setUserData(this);  
  }
  
   // This function removes the particle from the box2d world
  void killBody() 
  {
    mBox2D.destroyBody( mBody );
    println("BODY IS KILL");                                                                                
  }
  
  void attract(float x,float y) {
    Vec2 worldTarget = mBox2D.coordPixelsToWorld(x,y);   
    Vec2 bodyVec = mBody.getWorldCenter();
    //worldTarget.subLocal(bodyVec);
    //worldTarget.normalize();
    //worldTarget.mulLocal((float) 40000);
    mBody.setTransform(worldTarget, 0);
    
    xPos = x;
    yPos = y;
    
    // First find the vector going from this body to the specified point
    //worldTarget.subLocal(bodyVec);
    // Then, scale the vector to the specified force
    //worldTarget.normalize();
    //worldTarget.mulLocal((float) 100000);
    // Now apply it to the body's center of mass.
    //mBody.applyForce(worldTarget, bodyVec);
  }
  
  Vec2 getPosition(){
    return mBox2D.getBodyPixelCoord(mBody);
  }
  
  color getColor()
  {
     return balloonCol; 
  }
  
  void setColor( color col ) 
  {
    balloonCol = col;
  }
  
  boolean isAlive(){
     if(hit){
        return true;
     }
     return false;
  }
  
  void draw(){
    Vec2 pos = mBox2D.getBodyPixelCoord(mBody);
    float angle = mBody.getAngle();
    
    fill(balloonCol);
    //noStroke();
    
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-angle);
    ellipse(0,0,mRadius*2,mRadius*2);
    popMatrix();    
  }  
}
