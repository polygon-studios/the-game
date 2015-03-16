class string{
  
  Box2DProcessing mBox2D;
  ArrayList<babyBalloon> mString;
  
  string(PVector startPos, PVector endPos, int numSections, Box2DProcessing box2D){
    
    PVector stringVec = PVector.sub(endPos, startPos);
    float sectionSpacing = stringVec.mag()/(float)numSections;
    
    stringVec.normalize();
    float sectionRadius = 0.5f;
    
    mString = new ArrayList<babyBalloon>();
    mBox2D = box2D;
    
    for(int i = 0; i < numSections + 1; i++){
      //balloon startString = null;
      babyBalloon section = null;
      
      if(i == 0){
        section = new babyBalloon(new PVector(startPos.x, startPos.y), 20.0f, true, true, BodyType.DYNAMIC, mBox2D);
        //mString.add(startString);
      }
      else{
        PVector sectionPos = new PVector(startPos.x, startPos.y);
        sectionPos.add(PVector.mult(stringVec, (float)i*sectionSpacing));
        
        section = new babyBalloon(new PVector(sectionPos.x, sectionPos.y), sectionRadius, false, false, BodyType.DYNAMIC, box2D);
      }
      
      mString.add(section);
      
      if(i > 0){
        DistanceJointDef djd = new DistanceJointDef();
        babyBalloon previous = mString.get(i-1);
        
        djd.bodyA = previous.mBody;
        djd.bodyB = section.mBody;
        
        djd.length = mBox2D.scalarPixelsToWorld(sectionSpacing);
        
        djd.frequencyHz = 0;
        djd.dampingRatio = 0;
        
        DistanceJoint dj = (DistanceJoint)mBox2D.world.createJoint(djd);
      }
    }
    
  }
  
  void draw(){
    fill(255, 0, 0);
    for(babyBalloon babyBalloon: mString){
      babyBalloon.draw();
    }
    
  }
  
}
