class balloon{
  
  Body mBody;
  float mRadius;
  Box2DProcessing mBox2D;
  Boolean hit = false;
  float xPos;
  float yPos;
  
  float polygonFactor= 1;
  
  PVector boundingBoxMin;
  PVector boundingBoxMax;
  
  color balloonCol = color(255, 255, 255);
  
  ArrayList<Contour>       balloonContours;
  
  PImage img;
  
  balloon(PVector startPos, PVector boundingMin, PVector boundingMax, float radius, color startCol,  boolean initVel, boolean antiGrav, BodyType type, Box2DProcessing box2D){
    
   
    mBox2D = box2D;
    mRadius = radius;
    
    balloonCol = startCol;
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position = mBox2D.coordPixelsToWorld(startPos.x, startPos.y);
    xPos = startPos.x;
    yPos = startPos.y;
    boundingBoxMin = boundingMin;
    boundingBoxMax = boundingMax;
    
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
  
  void draw(){
    Vec2 pos = mBox2D.getBodyPixelCoord(mBody);
    float angle = mBody.getAngle();
    
    for (Contour contour : balloonContours) {
      
      contour.setPolygonApproximationFactor(polygonFactor);
      
      // Balloon countour handler
      if (contour.numPoints() < 300 &&  contour.numPoints() > 50) {   
        
        // Creating bounding box
        boundRect = new Rectangle(1280, 720, 0, 0);
        noFill();
        stroke(0,0,255);
        strokeWeight(2);
        Rectangle rec = contour.getBoundingBox();
        if(rec.width > boundRect.width && rec.height > boundRect.height){
           boundRect = rec; 
        }
        
        float centerX;
        float centerY;
        
        centerX = boundRect.x + (boundRect.width/2);
        centerY = boundRect.y + (boundRect.height/2);
        
        
        if(centerX < (boundingBoxMax.x + 100) && centerX > (boundingBoxMin.x - 100) && centerY < (boundingBoxMax.y + 100) && centerY > (boundingBoxMin.y - 100)) {
          attract(centerX * 2 + 128,centerY * 1.8 + 130);
          //println("Is dis being called?");
          
          // Should NOT draw balloon contours if it is below a certain y value
          if(centerY < 250){
            // Drawing the contours
            stroke(150, 150, 0);
            fill(0);
            beginShape();
         
            ArrayList<PVector> points = contour.getPolygonApproximation().getPoints();
            for (PVector point : points) {
              curveVertex(point.x * 2 + 128, point.y * 1.8 + 130 );
            }
            
            PVector firstPoint = points.get(1);
            curveVertex(firstPoint.x * 2 + 128, firstPoint.y * 1.8 + 130 ); 
            endShape();
          }
        }
      }    
    }
    
    fill(0);
    
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-angle);
    ellipse(0,0,mRadius*2,mRadius*2);
    popMatrix();   
    
    
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
  
  float getXPosition(){
    return xPos;
  }
  
  float getYPosition(){
    return yPos;
  }
  
  color getColor()
  {
     return balloonCol; 
  }
  
  void setColor( color col ) 
  {
    balloonCol = col;
  }
  
  void updateContour(ArrayList<Contour> newContour){
    balloonContours = newContour;
  }
  
  boolean isDead(){
     if(hit){
        return true;
     }
     return false;
  }
  
}
