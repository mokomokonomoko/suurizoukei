class AuroraParticle {
  PVector pos, vel;
  float radius;
  color c;
  float alpha;
  float decaySpeed;
  
  AuroraParticle() {
    pos = new PVector(random(width), -random(50, 200));
    vel = new PVector(random(-1.5, 1.5), random(1.0, 4.0));
    radius = random(80, 160);
    c = palette[int(random(palette.length))];
    alpha = 80;
    decaySpeed = random(0.01, 0.03);
  }
  
  void update() {
    pos.add(vel);
    vel.x += random(-0.05, 0.05);
    vel.x = constrain(vel.x, -2, 2);
    alpha = max(alpha - decaySpeed, 0);
  }
  
  void display(PGraphics pg) {
    int steps = 20;
    float stepSize = radius / 2.0 / steps;
    for (int i = steps; i >= 1; i--) {
      float r = i * stepSize;
      float a = map(i, 1, steps, 0, alpha);
      pg.fill(c, a);
      pg.ellipse(pos.x, pos.y, r * 2, r * 2);
    }
  }
}
