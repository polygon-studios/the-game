class Arrow{
  
  Body mBody;
  Box2DProcessing mBox2DRef;
  FixtureDef fd;
  Boolean hit;
  PImage img;
  float x1;
  float y1;
  float x2;
  float y2;
  Vec2 savedPos;
  float step = 0.0f;
  float trans = 1;
  float angle = 0;
    
  Arrow(Box2DProcessing box2D, float startX, float startY, float endX, float endY){
    mBox2DRef = box2D;
    x1 = startX;
    y1 = startY;
    x2 = endX;
    y2 = endY;
    hit = false;
    img = loadImage("arrow.png");
    savedPos = new Vec2(startX, startY);
    
    BodyDef bd = new BodyDef();                         //create body def
    bd.type    = BodyType.DYNAMIC; 
    
    bd.position = mBox2DRef.coordPixelsToWorld(x1, y1);      //set position
    mBody = mBox2DRef.world.createBody(bd);                //define body with bodyDef
    
    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius    = mBox2DRef.scalarPixelsToWorld( 20 );
    // Define a fixture
    fd   = new FixtureDef();
    fd.shape        = cs;
    fd.density      = 1;
    fd.friction     = 1;
    fd.restitution  = -6;//bounciness

    mBody.setUserData(this);      //need to set this for collsion listening!!
    mBody.setAngularDamping(3);
    //attach fixture finishing creation of body
    mBody.createFixture( fd );
    setBodyVelocity();
    
    angle = tan((y2-y1)/(x2-x1));
  }
  
  // This function removes the particle from the box2d world
  void killBody() 
  {
    mBox2DRef.destroyBody( mBody );
  }
  
  void draw(){
    
    if(trans > 0){
      
       Vec2 pos = mBox2DRef.getBodyPixelCoord( mBody ); 
       
       //calculate angle SOHCAH(TOA)
       float currentAngle = tan((pos.y - savedPos.y)/(pos.x - savedPos.x));
       savedPos = pos;
       float a = mBody.getAngle(); 
       
       pushMatrix();
       translate(pos.x,pos.y);
       //rotate(a + sin(2*PI - currentAngle));
       rotate(angle);
       if(hit == true){
         println("IT twas hit");
         trans -= 0.04;
         //fill(255, 0, 0, trans*255); // trans *255 because transparency is out of 255
         tint(255, 255, 255, trans*255);   
       }else{
         tint(255, 255, 255, 255);   
         //fill(255, 0, 0);
       }
       
       //ellipse(0, 0, 20, 20);
       //line( 0, 0, 20, 0 ); 
       image(img, -60, -8, 75, 8);   
       popMatrix();
       
    }
   }
   
   void setBodyVelocity(){
     
     //float time = (x2 - x1)/10; //smaller the denominator, more thime arrow takes
     float time = 8;
     float xVel = (x2 - x1)/(time);
     float yVel = ((y2-y1) + (0.5 * -40.0 * (int(time/2)^2)))/-time;
     
     //works, just timing is wrong
     //int xVel = int((x2 - x1)/10);
     //int yVel = int(((y2-y1) + (0.5 * 1.0 * (16^2)))/-10);
     
     //println("GravityScale : " + mBody.getGravityScale() + " X: " + xVel + " Y: " + yVel);
     
     mBody.setLinearVelocity(new Vec2(xVel,yVel));
   }
   
   boolean isAlive(){
     Vec2 pos = mBox2DRef.getBodyPixelCoord( mBody ); 
     if(trans > 0){
       if(pos.x < 1500 && pos.x > 0 && pos.y < 850 && pos.y > -150){
         return true;
       }
     }
     return false;
   }
   
   
}

//linear velocity equations: http://www.ajdesigner.com/phpprojectilemotion/range_equation_initial_velocity.php
// check out linear velocity and linear force. Not going to path would be easier
///https://github.com/jbox2d/jbox2d/blob/master/jbox2d-library/src/main/java/org/jbox2d/dynamics/Body.java
//http://www.iforce2d.net/b2dtut/projected-trajectory
