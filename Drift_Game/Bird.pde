class Bird {
  
  Body mBody;
  Box2DProcessing mBox2DRef;
  FixtureDef fd;
  float mRadius;
  
  float x1;
  float y1;
  
  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  boolean loaded = false;

  int numFrames = 19;  // The number of frames in the animation
  int currentFrame = 0;
  //PImage[] images = new PImage[numFrames];
  PImage[] images;
  
  boolean isAlive = true;
  
  Bird(PVector l, float ms, float mf, Box2DProcessing box2D, PImage[] birdFrames) {
    images = birdFrames;
    mBox2DRef = box2D;
    
    x1 = l.x;
    y1 = l.y;
    
    BodyDef bd = new BodyDef();                         //create body def
    bd.type    = BodyType.DYNAMIC; 
    
    bd.position = mBox2DRef.coordPixelsToWorld(x1, y1);      //set position
    mBody = mBox2DRef.world.createBody(bd);                //define body with bodyDef
    
    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius    = mBox2DRef.scalarPixelsToWorld( 20 );
    mRadius = 20.0f;
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
    //mBody.setGravityScale(1.0, -9.8);
    //mBody.setGravityScale(-0.6);
    
    
    acc = new PVector(0,0);
    vel = new PVector(random(-1,1),random(-1,1));
    loc = l.get();
    r = 2.0;
    maxspeed = ms;
    maxforce = mf;
  }
  
  void run(ArrayList Birds) {
    
    flock(Birds);
    update();
    borders();
    render();
  }
  
  Vec2 getPosition(){
    return mBox2D.getBodyPixelCoord(mBody);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList Birds) {
    PVector sep = separate(Birds);   // Separation
    PVector ali = align(Birds);      // Alignment
    PVector coh = cohesion(Birds);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
  }

  // Method to update location
  void update() {
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.add(vel);
    // Reset accelertion to 0 each cycle
    acc.mult(0);
    Vec2 worldTarget = mBox2D.coordPixelsToWorld(loc.x + 60,loc.y + 55);   
    //worldTarget.subLocal(bodyVec);
    //worldTarget.normalize();
    //worldTarget.mulLocal((float) 40000);
    mBody.setTransform(worldTarget, 0);
  }

  void seek(PVector target) {
    acc.add(steer(target,false));
  }

  void arrive(PVector target) {
    acc.add(steer(target,true));
  }


  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  PVector steer(PVector target, boolean slowdown) {
    PVector steer;  // The steering vector
    PVector desired = PVector.sub(target,loc);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0f)) desired.mult(maxspeed*(d/100.0f)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = PVector.sub(desired,vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } 
    else {
      steer = new PVector(0,0);
    }
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    Vec2 pos = mBox2D.getBodyPixelCoord(mBody);
    float angle = mBody.getAngle();
    /*fill(0);
    
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-angle);
    ellipse(0,0,mRadius*2,mRadius*2);
    popMatrix();  */
    currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
    int offset = 0;
    //rotate(theta);
    image(images[(currentFrame+offset) % numFrames], loc.x, loc.y);
    offset+=1;
  }

  // Wraparound
  void borders() {
    //if (loc.x < -r) loc.x = width+r;
    //if (loc.y < -r) loc.y = height+r;
    //if (loc.x > width+r) loc.x = -r;
    //if (loc.y > height+r) loc.y = -r;
  }

  // Separation
  // Method checks for nearby Birds and steers away
  PVector separate (ArrayList Birds) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every Bird in the system, check if it's too close
    for (int i = 0 ; i < Birds.size(); i++) {
      Bird other = (Bird) Birds.get(i);
      float d = PVector.dist(loc,other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(loc,other.loc);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby Bird in the system, calculate the average velocity
  PVector align (ArrayList Birds) {
    float neighbordist = 50.0;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    for (int i = 0 ; i < Birds.size(); i++) {
      Bird other = (Bird) Birds.get(i);
      float d = PVector.dist(loc,other.loc);
      if ((d > 0) && (d < neighbordist)) {
        steer.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby Birds, calculate steering vector towards that location
  PVector cohesion (ArrayList Birds) {
    float neighbordist = 50.0;
    PVector sum = new PVector(0,0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < Birds.size(); i++) {
      Bird other = (Bird) Birds.get(i);
      float d = PVector.dist(loc,other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.loc); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      return steer(sum,false);  // Steer towards the location
    }
    return sum;
  }
  
  void killBody() 
  {
    mBox2DRef.destroyBody( mBody );
  }
}

