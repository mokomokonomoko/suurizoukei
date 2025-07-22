class AuroraParticle {
  PVector pos, vel;
  float radius;
  color c;
  float alpha;
  float decaySpeed;

  AuroraParticle() {
    pos = new PVector(random(width), -random(50, 200));
    vel = new PVector(random(-1.5, 1.5), random(5.0, 10.0));
    // グラデーションマップ（明度 → 色）
    gradMap = new color[] {
      color(255, 240, 245), color(255, 200, 220),
      color(200, 150, 240), color(180, 250, 250),
      color(120, 240, 180), color(255, 220, 130),
      color(255, 150, 150), color(255, 255, 200)
    };
    radius = random(100, 300);
    c = gradMap[int(random(gradMap.length))];
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
    print("aurora");
    int steps = 20;
    float stepSize = radius / 2.0 / steps;
    for (int i = steps; i >= 1; i--) {
      float r = i * stepSize;
      float a = map(i, 1, steps, 0, alpha);
      pg.fill(c, a);
      pg.ellipse(pos.x, pos.y, r * 2, r * 2);
    }
  }

  boolean isDead() {
    return (pos.y > height);
    //return (pos.x < -radius || pos.x > width + radius || pos.y > height + radius || alpha <= 0);
  }
}
