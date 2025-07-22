import oscP5.*;
import netP5.*;

OscP5 oscP5;

PVector lastWristPos = new PVector(0, 0);
PVector wristVelocity = new PVector();
boolean isFirstWrist = true;

boolean jumpDetected = false;
int lastJumpMillis = 0;

boolean colorfulActive = false;
int colorfulTimer = 0;

BackgroundLayer backgroundLayer;
//ColorLayer colorLayer;
CircleLayer circleLayer;
AuroraParticle auroraparticle;

ArrayList<AuroraParticle> auroras;
color[] palette;
int maxAuroraPerClick = 30;

PVector bodyCenter = new PVector(960, 540);

ArrayList<Petal> petals;
PGraphics grayLayer;
color[] gradMap;

PImage backFrame;

void setup() {
  size(1920, 1080, P2D);
  oscP5 = new OscP5(this, 12000);
  backgroundLayer = new BackgroundLayer();
  backFrame = loadImage("backframe.png");
  //colorLayer = new ColorLayer(width, height);
  circleLayer = new CircleLayer();
  auroraparticle = new AuroraParticle();

  petals = new ArrayList<Petal>();
  grayLayer = createGraphics(width, height);

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

  // グラデーションマップ（明度 → 色）
  gradMap = new color[] {
    color(255, 240, 245), color(255, 200, 220),
    color(200, 150, 240), color(180, 250, 250),
    color(120, 240, 180), color(255, 220, 130),
    color(255, 150, 150), color(255, 255, 200)
  };

  auroras = new ArrayList<AuroraParticle>();
  //colorMode(HSB, 360, 100, 100, 100);
}

void draw() {
  // 1. 花弁たちをグレーで描く
  grayLayer.beginDraw();
  grayLayer.background(255);
  image(backFrame, 0, 0, width, height);
  grayLayer.blendMode(MULTIPLY);
  for (Petal p : petals) {
    p.update();
    p.display(grayLayer);
  }
  // aurora
  for (int i = auroras.size() - 1; i >= 0; i--) {
    AuroraParticle a = auroras.get(i);
    a.update();
    a.display(grayLayer);
    if (a.isDead()) {
      auroras.remove(i);
    }
  }

  //grayLayer.endDraw();
  //background(255);
  //backgroundLayer.update();
  //backgroundLayer.updateFogLayer();
  //backgroundLayer.updateFogLayer();

  circleLayer.update();
  circleLayer.display(grayLayer);// grayLayer に書くよう修正する

  //colorLayer.update();
  //colorLayer.display();

  if (colorfulActive) {
    fill(random(360), 100, 100, 50);
    noStroke();
    ellipse(random(width), random(height), 200, 200);
    if (millis() - colorfulTimer > 3000) {
      colorfulActive = false;
    }
  }

  //if (jumpDetected && millis() - lastJumpMillis > 3000) {
    //for (int i = 0; i < maxAuroraPerClick; i++) {
      //auroras.add(new AuroraParticle());
    //}
    //lastJumpMillis = millis();
    //jumpDetected = false;
  //}
  // 1. 花弁たちをグレーで描く
  //grayLayer.beginDraw();
  //grayLayer.background(255);
  //grayLayer.blendMode(MULTIPLY);
  //for (Petal p : petals) {
  //p.update();
  //p.display(grayLayer);
  //}
  grayLayer.endDraw();

  // 2. グレースケール → グラデーションに変換して表示
  applyGradientMap(grayLayer);

  // 3. フェードアウトが終わった花弁を削除（ここが重要！）
  for (int i = petals.size() - 1; i >= 0; i--) {
    if (petals.get(i).isDead()) {
      petals.remove(i);
    }
  }
}


void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/jump")) {
    for (int i = 0; i < 10; i++) {
      auroras.add(new AuroraParticle());
    }
    //lastJumpMillis = millis();
    //jumpDetected = false;
  }

  if (msg.checkAddrPattern("/wrist")) {
    float x = msg.get(0).floatValue() * width;
    float y = msg.get(1).floatValue() * height;
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);

    PVector currentWristPos = new PVector(x, y);
    circleLayer.addParticleAtWrist(x, y, int(random(360)));
    //colorLayer.addPetals(x,y);

    if (!isFirstWrist) {
      wristVelocity = PVector.sub(currentWristPos, lastWristPos);
      int hue = frameCount % 360;
      circleLayer.addParticleAtWrist(currentWristPos.x, currentWristPos.y, hue);
      //colorLayer.addPetals(currentWristPos.x,currentWristPos.y);
    } else {
      isFirstWrist = false;
    }
    lastWristPos = currentWristPos.copy();
  }

  if (msg.checkAddrPattern("/leftwrist")) {
    float x = msg.get(0).floatValue() * width;
    float y = msg.get(1).floatValue() * height;
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);

    PVector currentWristPos = new PVector(x, y);
    circleLayer.addParticleAtWrist(x, y, int(random(360)));
    //colorLayer.addPetals(x,y);

    if (!isFirstWrist) {
      wristVelocity = PVector.sub(currentWristPos, lastWristPos);
      int hue = frameCount % 360;
      circleLayer.addParticleAtWrist(currentWristPos.x, currentWristPos.y, hue);
      //colorLayer.addPetals(currentWristPos.x,currentWristPos.y);
    } else {
      isFirstWrist = false;
    }
    lastWristPos = currentWristPos.copy();
  }

  if (msg.checkAddrPattern("/hip")) {
    float y = msg.get(0).floatValue() * height;
    bodyCenter.y = y;
  }

  if (msg.checkAddrPattern("/cross")) {
    //jumpDetected = true;
    float x = msg.get(0).floatValue() * width;
    float y = msg.get(1).floatValue() * height;
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
    for (int i = 0; i < 10; i++) {
      petals.add(new Petal(x, y));
    }
  }

  if (msg.checkAddrPattern("/ymca")) {
    String pose = msg.get(0).stringValue();
    if (pose.equals("Y")) {
      colorfulActive = true;
      colorfulTimer = millis();
    }
  }
}
// ---------------- Petalクラス ------------------
class Petal {
  float x, y;       // 位置
  float vx, vy;     // 速度（落下に使用）
  float r;          // 最大サイズ
  float angle;      // 基本回転
  int sides;
  float growth;     // 0.0〜1.0
  float decayRate;  // 萎む速度（成長後にrが0になるまで）
  boolean grown;    // 成長完了フラグ
  float swayStrength;
  float swaySpeed;


  color fillColor;
  float tOffset;

  Petal(float cx, float cy) {
    float spread = random(10, 30);
    float theta = random(TWO_PI);
    x = cx + cos(theta) * spread;
    y = cy + sin(theta) * spread;

    vx = random(-0.4, 0.4);
    vy = 2.0;

    r = random(50, 100);
    sides = int(random(4, 7));
    angle = random(TWO_PI);

    growth = 0;
    decayRate = random(0.2, 0.5); // 小さいほど長く残る
    grown = false;

    fillColor = color(random(150, 255), random(150, 255), random(150, 255));
    tOffset = random(1000);
  }

  void update() {
    if (!grown) {
      growth += 0.01;
      if (growth >= 1.0) {
        growth = 1.0;
        grown = true;
      }
    } else {
      // 落下：重力＋空気抵抗
      // 揺れの強さ・速さ（大きさに依存）
      swayStrength = map(r, 20, 60, 1, 5); // 大きい花弁ほど大きく揺れる
      swaySpeed = map(r, 20, 60, 2.0, 0.5); // 小さい花弁ほど速く揺れる
      float drag = map(r * growth, 0, 60, 0.05, 0.01);
      vy += 0.1 * drag;
      y += vy;

      // 左右に揺れる（大きさ依存＋個体差）
      float t = millis() * 0.001;
      float sway = sin(t * swaySpeed + tOffset) * swayStrength;
      x += sway;

      // 小さくなっていく（枯れる）
      growth -= 0.01 * decayRate;
      if (growth < 0) growth = 0;
    }
  }

  void display(PGraphics pg) {
    if (growth <= 0) return;

    pg.pushMatrix();
    pg.translate(x, y);

    float t = millis() * 0.001;
    float swing = sin(t + tOffset) * PI / 6 * (1 - growth);
    pg.rotate(angle + swing);

    pg.fill(fillColor, 255);
    pg.noStroke();

    pg.beginShape();
    for (int i = 0; i < sides; i++) {
      float a = TWO_PI * i / sides;
      float rad = r * growth;
      pg.vertex(cos(a) * rad, sin(a) * rad);
    }
    pg.endShape(CLOSE);
    pg.popMatrix();
  }

  boolean isDead() {
    return growth <= 0;
  }
}



// ------------ グラデーションマップ変換 --------------
void applyGradientMap(PGraphics pg) {
  int cycleCount = 2; // ここを好きなサイクル数に変更可能

  pg.loadPixels();
  loadPixels();

  for (int i = 0; i < pg.pixels.length; i++) {
    color src = pg.pixels[i];
    float b = brightness(src);
    int a = int(alpha(src));

    // グラデーションを n 周するように拡張
    int totalSteps = gradMap.length * cycleCount;

    int idx = int(map(b, 0, 255, 0, totalSteps));
    idx = idx % gradMap.length; // ← mod で周回

    color mapped = gradMap[constrain(idx, 0, gradMap.length - 1)];
    pixels[i] = color(red(mapped), green(mapped), blue(mapped), a);
  }

  updatePixels();
}
