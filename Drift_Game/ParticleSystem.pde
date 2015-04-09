// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 
int savedTime;
int totalTime = 350;

class ParticleSystem {
  ArrayList<Firefly> fireflies;
  PVector origin;

  ParticleSystem() {
    fireflies = new ArrayList<Firefly>();
    savedTime = millis();
  }

  void addParticle() {
    int passedTime = millis() - savedTime;
    if ( passedTime > totalTime) {
      float randWidth = random(0, 1280);
      float randHeight = random(420, 600);
      origin = new PVector(randWidth, randHeight);
      fireflies.add(new Firefly(origin));
      savedTime = millis();
    }
  }

  void run() {
    for (int i = fireflies.size()-1; i >= 0; i--) {
      Firefly f = fireflies.get(i);
      f.run();
      if (f.isDead()) {
        fireflies.remove(i);
      }
    }
  }
}
