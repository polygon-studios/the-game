class Tree{
  
  Body mBody;
  float mRadius;
  Box2DProcessing mBox2D;
  float xPos;
  float yPos;
Tree(PVector startPos, float radius, BodyType type, Box2DProcessing box2D){
    
   
    mBox2D = box2D;
    mRadius = radius;

    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position = mBox2D.coordPixelsToWorld(startPos.x, startPos.y);
    xPos = startPos.x;
    yPos = startPos.y;
    
    mBody = mBox2D.world.createBody(bd);
    
    // General tree shape  
    CircleShape shape = new CircleShape();
    shape.m_radius = mBox2D.scalarPixelsToWorld(radius);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = shape;    
    fd.density     = 1.0f;
    fd.friction    = 0.2f;
    fd.restitution = 0.1f;
    
    mBody.createFixture(fd);
    
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

  
  void draw(){
    Vec2 pos = mBox2D.getBodyPixelCoord(mBody);
    float angle = mBody.getAngle();
    noFill(); 
    stroke(255);   
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-angle);
    ellipse(0,0,mRadius*2,mRadius*2);
    popMatrix();    
  }  
}
