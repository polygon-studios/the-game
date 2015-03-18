class balloon{
  
  Body mBody;
  float mRadius;
  Box2DProcessing mBox2D;
  
  color balloonCol = color(255, 255, 255);
  
  PImage img;
  
  balloon(PVector startPos, float radius, boolean initVel, boolean antiGrav, BodyType type, Box2DProcessing box2D){
    
   
    mBox2D = box2D;
    mRadius = radius;
    
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position = mBox2D.coordPixelsToWorld(startPos.x, startPos.y);
    
    mBody = mBox2D.world.createBody(bd);
    if(antiGrav){
      mBody.setGravityScale(-0.6);
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
  
  void attract(float x,float y) {
    Vec2 worldTarget = mBox2D.coordPixelsToWorld(x,y);   
    Vec2 bodyVec = mBody.getWorldCenter();
    //worldTarget.subLocal(bodyVec);
    //worldTarget.normalize();
    //worldTarget.mulLocal((float) 40000);
    mBody.setTransform(worldTarget, 0);
  }
  
  color getColor()
  {
     return balloonCol; 
  }
  
  void setColor( color col ) 
  {
    balloonCol = col;
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
