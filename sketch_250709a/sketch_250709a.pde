import oscP5.*;
import netP5.*;

OscP5 oscP5;
PVector lastWristPos = new PVector(0, 0);
boolean isFirstWrist = true;
PVector wristVelocity = new PVector();

boolean jumpDetected = false;
int lastJumpMillis = 0;

ArrayList<AuroraParticle> auroras;
PGraphics pg;
color[] palette;
int maxAuroraPerClick = 30;

ArrayList<ExpandingCircle> circles = new ArrayList<ExpandingCircle>();

PVector bodyCenter = new PVector(960, 540);
float bodyRadius = 200;

void setup() {
  size(1920, 1080, P2D);
  oscP5 = new OscP5(this, 12000);
  background(0);

  pg = createGraphics(width, height, P2D);
  palette = new color[] {
    color(217, 2, 152, 160),
    color(242, 121, 153, 160),
    color(242, 167, 160, 160),
    color(235, 242, 182, 160),
    color(193, 218, 146, 160),
    color(208, 241, 255, 160),
    color(151, 218, 245, 160),
    color(96, 176, 251, 160),
    color(54, 71, 180, 160)
  };

  auroras = new ArrayList<AuroraParticle>();
}

void draw() {
  background(0);
  
  for (int i = circles.size() - 1; i >= 0; i--) {
    ExpandingCircle c = circles.get(i);
    c.update();
    c.display();
    if (c.isDead()) {
      circles.remove(i);
    }
  }

  if (jumpDetected && millis() - lastJumpMillis > 3000) {
    for (int i = 0; i < maxAuroraPerClick; i++) {
      auroras.add(new AuroraParticle());
    }
    lastJumpMillis = millis();
    jumpDetected = false;
  }

  pg.beginDraw();
  pg.blendMode(REPLACE);
  pg.noStroke();
  pg.fill(0, 5);
  pg.rect(0, 0, width, height);
  pg.blendMode(ADD);

  for (int i = auroras.size() - 1; i >= 0; i--) {
    AuroraParticle a = auroras.get(i);
    a.update();

    if (PVector.dist(a.pos, bodyCenter) < bodyRadius) {
      PVector repel = PVector.sub(a.pos, bodyCenter);
      repel.normalize();
      repel.mult(4.0);
      a.vel.add(repel);
    }

    if (wristVelocity.mag() > 20) {
      PVector blow = wristVelocity.copy().normalize().mult(2.0);
      PVector delta = PVector.sub(a.pos, lastWristPos);
      if (delta.mag() < 200) {
        a.vel.add(blow);
      }
    }

    a.display(pg);

    if (a.alpha <= 0) {
      auroras.remove(i);
    }
  }

  pg.endDraw();
  image(pg, 0, 0);
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/wrist")) {
    float x = msg.get(0).floatValue() * width;
    float y = msg.get(1).floatValue() * height;
    PVector currentWristPos = new PVector(x, y);

    if (!isFirstWrist) {
      wristVelocity = PVector.sub(currentWristPos, lastWristPos);
    } else {
      isFirstWrist = false;
    }
    lastWristPos = currentWristPos.copy();
  }

  if (msg.checkAddrPattern("/jump")) {
    jumpDetected = true;
  }
}
