// CircleLayer.pde またはメインスケッチファイル内の CircleLayer クラス定義

class CircleLayer {
  ArrayList<Particle> particles;
 // PGraphics layerCanvas; // このレイヤー専用の PGraphics を追加

  CircleLayer() {
    // スケッチの幅と高さを使ってPGraphicsを初期化します
    //backgroundLayer = new BackgroundLayer();
    // createGraphicsはProcessingのメインスケッチ環境で呼び出す必要があります。
    // もしこれが別ファイルなら、メインスケッチでwidth, heightを渡すか、
    // グローバル変数としてアクセスできるようにしてください。
    //layerCanvas = createGraphics(width, height, P2D);
    //layerCanvas.beginDraw();
    //layerCanvas.background(0); // 初期背景を黒に設定
    //layerCanvas.colorMode(HSB, 360, 100, 100, 100); // HSBモードもここで設定
    //layerCanvas.endDraw();
    //backgroundLayer.update();
    //layerCanvas.fill(0, 0, 0, 10); // 強めに消す
    //backgroundLayer.update();
    particles = new ArrayList<Particle>();
  }


  // update メソッドは PGraphics を引数として受け取るようにします
  void update() {
   // layerCanvas.beginDraw();
    //layerCanvas.colorMode(HSB, 360, 100, 100, 100);
    //layerCanvas.tint(255, 100);  // ← 透明度50（0〜255）
    //layerCanvas.blendMode(BLEND);
    //layerCanvas.noStroke();
    //layerCanvas.fill(0, 0, 0, 25); // 強めに消す
    // 毎回背景を入れる（暗い膜はやめる）
   // layerCanvas.image(backgroundLayer.fogLayer, 0, 0);
    //layerCanvas.noTint();
    //layerCanvas.rect(0, 0, width, height);

    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display(grayLayer);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
    //grayLayer.endDraw();
  }

  // 新しいメソッド: 手首の座標でパーティクルを追加する
  void addParticleAtWrist(float x, float y, int hue) {
    particles.add(new Particle(x, y, hue));
    // デバッグ用: パーティクルが追加されたことを確認
    println("Particle added at wrist: x=" + x + ", y=" + y + ", hue=" + hue);
  }

  // CircleLayer の描画を担当する display メソッド
  void display(PGraphics pg) {
    pg.noStroke();
   // for (Particle p : particles) {
      //pg.fill(0); // GrayLayer だから黒系統で
      //pg.ellipse(p.x, p.y, 10, 10);
   // }
  }

  // mouseDragged() と keyPressed() は CircleLayer クラスの直接の子として定義する必要があります
  // これらはメインスケッチでイベントリスナーとして呼び出すべきです。
  // CircleLayer自身がこれらのイベントを直接処理することはProcessingの標準的なやり方ではありません。
  // メインスケッチ側で処理し、必要ならCircleLayerのメソッドを呼び出します。
  // 例:
  /*
  void mouseDragged() {
   int hue = frameCount % 360;
   circleLayer.addParticleAtWrist(mouseX, mouseY, hue); // テスト用
   }
   void keyPressed() {
   if (key == ' ') {
   circleLayer.clearParticles(); // 新しいメソッドをCircleLayerに追加
   }
   }
   */

  // パーティクルをクリアするメソッドを追加
  void clearParticles() {
    particles.clear();
    //layerCanvas.beginDraw();
    //layerCanvas.background(0); // クリア時にレイヤーも黒くする
    //layerCanvas.endDraw();
  }
}

// Particle クラスの修正点: PGraphics を引数として受け取る display メソッド
class Particle {
  float x, y;
  float size;
  int hue;
  float alpha;
  float speedX, speedY;

  // Particleクラス
  Particle(float x, float y, int hue) {
    this.x = x;
    this.y = y;
    this.hue = hue;
    this.size = random(30, 80);
    this.alpha = 50;
    this.speedX = random(-1, 1);
    this.speedY = random(-1, 1);
  }

  void update() {
    x += speedX;
    y += speedY;
    alpha -= 8;
  }


  void display(PGraphics pg) { // PGraphics を引数として受け取る
    pg.noStroke();
    pg.fill(hue, 100, 100, alpha);
    pg.ellipse(x, y, size, size);
  }

  boolean isDead() {
    return alpha <= 0;
  }
}
