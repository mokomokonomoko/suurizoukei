class ExpandingCircle {
  PVector pos;
  float radius;
  float maxRadius;
  color c;
  
  ExpandingCircle(PVector pos, float radius, float maxRadius, color c) {
    this.pos = pos.copy();
    this.radius = radius;
    this.maxRadius = maxRadius;
    this.c = c;
  }
  
  void update() {
    radius += 4;
  }
  
  void display() {
    noFill();
    stroke(c, map(radius, 0, maxRadius, 150, 0));
    strokeWeight(3);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
  }
  
  boolean isDead() {
    return radius > maxRadius;
  }
}
