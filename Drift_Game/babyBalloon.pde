class babyBalloon{
  
  Body mBody;
  float mRadius;
  Box2DProcessing mBox2D;
  boolean mBalloon;
  color mCol;
  PImage img;  
  boolean hit = false;
  
  babyBalloon(PVector startPos, float radius, boolean initVel, boolean balloon, color col, BodyType type, Box2DProcessing box2D){
    
    mBalloon = balloon;
    mBox2D = box2D;
    mRadius = radius;
    mCol = col;
    hit = false;
        
    if(mCol == color(255, 255, 0)){
      img = loadImage("babyBalloon_y.png");
    }
    else if(mCol == color(0, 255, 0)){
      img = loadImage("babyBalloon_g.png");
    }
    else if(mCol == color(0, 0, 255)){
      img = loadImage("babyBalloon_b.png");
    }
    else if(mCol == color(0, 0, 0)){
    }
    else{
      img = loadImage("babyBalloon_w.png");
    }
    
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position = mBox2D.coordPixelsToWorld(startPos.x, startPos.y);
    
    mBody = mBox2D.world.createBody(bd);
    
    if(balloon){
      mBody.setGravityScale(-0.8);
      
      CircleShape shape = new CircleShape();
      shape.m_radius = mBox2D.scalarPixelsToWorld(radius);
      
      CircleShape shape2 = new CircleShape();
      shape2.m_p.y = -(shape.m_radius*1.5);
      shape2.m_radius = mBox2D.scalarPixelsToWorld(radius/2);
      
      FixtureDef fd = new FixtureDef();
      fd.shape = shape;    
      fd.density     = 0.0001f;
      fd.friction    = 0.2f;
      fd.restitution = 0.1f;
      
      //mBody.createFixture(fd);
      
      FixtureDef fd2 = new FixtureDef();
      fd2.shape = shape2;    
      fd2.density     = 10.0f;
      fd2.friction    = 0.2f;
      fd2.restitution = 0.1f;
      
      mBody.createFixture(fd2);  
      mBody.createFixture(fd);    
  
      mBody.setUserData(this); 
    }
    else{
      CircleShape shape = new CircleShape();
      shape.m_radius = mBox2D.scalarPixelsToWorld(radius);
      
      FixtureDef fd = new FixtureDef();
      fd.shape = shape;    
      fd.density     = 10.0f;
      fd.friction    = 0.1f;
      fd.restitution = 0.0f;
      
      mBody.createFixture(fd);
       
      mBody.setUserData(this);  
      
      MassData data = new MassData();
      
      mBody.getMassData(data);
    }
  
  }
  
  void draw(){
    Vec2 pos = mBox2D.getBodyPixelCoord(mBody);
    float angle = mBody.getAngle();
    
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-angle);
    if(mBalloon){
      imageMode(CENTER);
      tint(255);
      image(img, 0, mRadius/2, mRadius*2, mRadius*3);
      //ellipse(0,0,mRadius*2,mRadius*2);
      //ellipse(0, mRadius*1.5, mRadius, mRadius);
      imageMode(CORNER);
    }
    else{
      ellipse(0,0,mRadius*2,mRadius*2);
    }
    popMatrix();    
  }  
}
