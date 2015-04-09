class Firefly {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Firefly(PVector l) {
    //acceleration = new PVector(0,0.05);
    velocity = new PVector(random(-2,2),random(-2,0));
    location = l.get();
    lifespan = 300.0;
  }

  void run() {
    update();
    display();
  }

  // Method to update location
  void update() {
    //velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    stroke(255,lifespan);
    fill(255,lifespan);
    ellipse(location.x,location.y,4,4);
  }
  
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
