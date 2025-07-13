import oscP5.*;
import netP5.*;

OscP5 oscP5;
PVector lastWristPos = new PVector(0, 0);
boolean isFirstWrist = true;

ArrayList<ExpandingCircle> circles = new ArrayList<ExpandingCircle>();

void setup() {
  size(1920, 1080);
  oscP5 = new OscP5(this, 12000);
  background(0);
}

void draw() {
  background(0);
  
  // 円アニメーション更新
  for (int i = circles.size() - 1; i >= 0; i--) {
    ExpandingCircle c = circles.get(i);
    c.update();
    c.display();
    if (c.isDead()) {
      circles.remove(i);
    }
  }
}

// OSCから受信 → 指定座標に円
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/wrist")) {
    float x = msg.get(0).floatValue() * width;
    float y = msg.get(1).floatValue() * height;
    PVector currentWristPos = new PVector(x, y);
    
    if (!isFirstWrist) {
      float moveDistance = PVector.dist(lastWristPos, currentWristPos);
      if (moveDistance > 50) {
        circles.add(new ExpandingCircle(currentWristPos, 10, 200, color(255, 150, 0)));
      }
    } else {
      isFirstWrist = false;
    }
    lastWristPos = currentWristPos.copy();
  }
}
