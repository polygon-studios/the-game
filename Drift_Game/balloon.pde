class balloon{
  
  Body mBody;
  float mRadius;
  Box2DProcessing mBox2D;
  Boolean hit = false;
  float xPos;
  float yPos;
  
  color balloonCol = color(255, 255, 255);
  
  PImage img;
  
  balloon(PVector startPos, float radius, color startCol,  boolean initVel, boolean antiGrav, BodyType type, Box2DProcessing box2D){
    
   
    mBox2D = box2D;
    mRadius = radius;
    
    balloonCol = startCol;
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
  
  boolean isAlive(){
     if(hit){
        return true;
     }
     return false;
  }
  
  void draw(){
    
    for (Contour contour : contours) {
      
      contour.setPolygonApproximationFactor(polygonFactor);
      
      // Balloon countour handler
      if (contour.numPoints() < 300 &&  contour.numPoints() > 50) {   
        println("Is dis being called?");
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
        
        counter = 0;
        for (balloon s: balloons) {
          //println("Current Balloon: " + currentBalloon + " counter: " + counter);
          if(counter == currentBalloon){
            s.attract(centerX * 2 + 128,centerY * 1.8 + 130);
            //println("attract");
          }
          if(numBalloons > currentBalloon + 1){
          // s.attract(1920,1080);
          }
          counter++;
        }
        currentBalloon++;
        
        int loc = int(centerX*3.75) + int(centerY*2.547) * 1920;
        color pointColour = colorImage.pixels[loc];
        
        float r1 = red(pointColour);
        float g1 = green(pointColour);
        float b1 = blue(pointColour);
        color passCol = color(r1, g1, b1);
        // Should NOT draw balloon contours if it is below a certain y value
        if(centerY < 250){
          // Drawing the contours
          stroke(150, 150, 0);
          fill(r1, g1, b1);
          beginShape();
       
          ArrayList<PVector> points = contour.getPolygonApproximation().getPoints();
          for (PVector point : points) {
            curveVertex(point.x * 2 + 128, point.y * 1.8 + 130 );
          }
          
          PVector firstPoint = points.get(1);
          curveVertex(firstPoint.x * 2 + 128, firstPoint.y * 1.8 + 130 ); 
          endShape();
          
          // Drawing bounding box and center point
          //rect(boundRect.x * 2 + 128, boundRect.y * 1.8 + 72, boundRect.width * 2.5, boundRect.height * 1.8 + 72);
          //fill(0,255,0);
          //ellipse(centerX * 2 + 128, centerY * 1.8 + 72, 8,8);
        }
        if(numBalloons < maxBalloons){
         balloons.add(new balloon(new PVector(centerX, centerY), 60.0f, passCol, true, true, BodyType.DYNAMIC, mBox2D));
         numBalloons++;
        }
        
      }    
    }
    
  }  
}
