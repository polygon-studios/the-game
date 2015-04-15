class Flock {
  ArrayList birds; // An arraylist for all the boids

  Flock() {
    birds = new ArrayList(); // Initialize the arraylist
  }

  void run() {
    for (int i = 0; i < birds.size(); i++) {
      Bird b = (Bird) birds.get(i);  
      b.run(birds);  // Passing the entire list of boids to each boid individually
      b.seek(new PVector(1280, 400));
    }
  }

  void addBird(Bird b) {
    birds.add(b);
  }
  
  void addTarget(PVector target) {
    //birds.seek(target);
  }
  
  Vec2 getBirdPos(){
    Bird b = (Bird) birds.get(0);  
    Vec2 position = b.getPosition();
    return position;
  }

}
