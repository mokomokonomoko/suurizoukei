class ExpandingCircle {
  PVector pos;
  float radius;
  float maxRadius;
  float alpha;
  float growth;
  float fadeSpeed;
  color col;

  ExpandingCircle(PVector position, float startRadius, float maxRadius, color col) {
    this.pos = position.copy();
    this.radius = startRadius;
    this.maxRadius = maxRadius;
    this.alpha = 255;
    this.growth = 2.5;
    this.fadeSpeed = 3.0;
    this.col = col;
  }

  void update() {
    radius += growth;
    alpha -= fadeSpeed;
  }

  void display() {
    noFill();
    stroke(col, alpha);
    strokeWeight(2);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
  }

  boolean isDead() {
    return alpha <= 0 || radius > maxRadius;
  }
}
