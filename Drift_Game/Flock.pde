class Flock {
  ArrayList birds; // An arraylist for all the boids

  Flock() {
    birds = new ArrayList(); // Initialize the arraylist
  }

  void run() {
    for (int i = 0; i < birds.size(); i++) {
      Bird b = (Bird) birds.get(i);  
      b.run(birds);  // Passing the entire list of boids to each boid individually
      b.seek(new PVector(mouseX, mouseY));
    }
  }

  void addBird(Bird b) {
    birds.add(b);
  }
  
  void addTarget(PVector target) {
    //birds.seek(target);
  }

}
