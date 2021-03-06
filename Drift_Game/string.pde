class string{
  
  Box2DProcessing mBox2D;
  ArrayList<babyBalloon> mString;
  float balloonRad = 20.0;
  
  string(PVector startPos, PVector endPos, int numSections, color col, Box2DProcessing box2D){
    PVector newStartPos = new PVector(startPos.x, startPos.y + balloonRad*1.5);
    PVector newEndPos = new PVector(endPos.x, endPos.y + balloonRad*1.5);
    PVector stringVec = PVector.sub(newEndPos, newStartPos);
    float sectionSpacing = stringVec.mag()/(float)numSections;
    
    passCol = col;
    
    stringVec.normalize();
    float sectionRadius = 0.5f;
    
    mString = new ArrayList<babyBalloon>();
    mBox2D = box2D;
    
    for(int i = 0; i < numSections + 1; i++){
      babyBalloon section = null;
      
      if(i == 0){
        section = new babyBalloon(new PVector(startPos.x, startPos.y), balloonRad, true, true, passCol, BodyType.DYNAMIC, mBox2D, poppingPlayer);
      }
      else{
        PVector sectionPos = new PVector(startPos.x, startPos.y);
        sectionPos.add(PVector.mult(stringVec, (float)i*sectionSpacing));
        
        section = new babyBalloon(new PVector(sectionPos.x, sectionPos.y + balloonRad*1.5), sectionRadius, false, false, passCol, BodyType.DYNAMIC, box2D, poppingPlayer);
      }
      
      mString.add(section);
      
      if(i > 0){
        DistanceJointDef djd = new DistanceJointDef();
        babyBalloon previous = mString.get(i-1);
        
        djd.bodyA = previous.mBody;
        djd.bodyB = section.mBody;
        
        if(i==1){
          djd.localAnchorA.set(0, -4);
          djd.localAnchorB.set(0,0);
        }
        
        djd.length = mBox2D.scalarPixelsToWorld(sectionSpacing);
        
        djd.frequencyHz = 0;
        djd.dampingRatio = 0;
        
        DistanceJoint dj = (DistanceJoint)mBox2D.world.createJoint(djd);
      }
    }
    
  }
  
  void draw(){
    fill(255, 0, 0);
    for(babyBalloon circle: mString){
      circle.draw();
    }    
  }  
}
