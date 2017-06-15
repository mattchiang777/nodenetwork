class Particle {
  
  PVector pos = new PVector(0, 0);
  PVector vel;
  PVector acc = new PVector(0, 0);
  float h = currentHue;
  
  Particle(float x, float y) {
    this.pos.set(x, y);
    
    PVector lastPos = new PVector(random(-500, 500), random(-500, 500));
    //this.vel = new PVector(pmouseX, pmouseY);
    this.vel = new PVector(random(-500, 500), random(-500, 500));
    this.vel.sub(lastPos);
    this.vel.rotate(radians(random(-1000, 1000)));
    this.vel.limit(10); // top speed of particles
    this.vel.mult(random(0, 2));
  }

  void move() {
    if (this.vel.mag() > 2) {
      this.vel.mult(0.95); // slow factor orig 0.98
    } else {
      this.vel.mult(0.98); // slow factor orig 0.95
    }
    
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
}