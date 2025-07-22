class BackgroundLayer {
  //PGraphics fogLayer;
  float noiseScale = 0.01;
  float noiseSpeed = 0.005;

  BackgroundLayer() {
    //fogLayer = createGraphics(width, height, P2D);
    //fogLayer.beginDraw();
   // fogLayer.noStroke();
    //fogLayer.background(0);
   // updateFogLayer();
   // fogLayer.endDraw();
  }

  void update() {
    // もうここでは何もしない。1回作ったら終了。
  }

  void display(PGraphics pg) {
    pg.noStroke();
  }

  void updateFogLayer(PGraphics pg) {
    for (int x = 0; x < width; x += 4) {
      for (int y = 0; y < height; y += 4) {
        float noiseValue = noise(x * noiseScale, y * noiseScale, frameCount * noiseSpeed);
        float alpha = map(noiseValue, 0, 1, 100, 200);

        float time = frameCount * 0.01;

        float r = 150 + sin(time + x * 0.005) * 80 + cos(time * 0.7 + y * 0.003) * 30;
        float g = 100 + sin(time * 1.2 + x * 0.003 + y * 0.002) * 60 + cos(time * 0.5) * 40;
        float b = 200 + sin(time * 0.8 + (x+y) * 0.001) * 50 + cos(time * 1.5 + x * 0.002) * 30;

        float positionFactor = map(y, 0, height, 1.2, 0.8);
        r *= positionFactor;
        g *= positionFactor * 0.9;
        b *= positionFactor * 1.1;

        r = constrain(r, 80, 200);
        g = constrain(g, 80, 200);
        b = constrain(b, 80, 200);
        
        pg.fill(r, g, b, alpha);
        //fogLayer.rect(x, y, 4, 4);
      }
    }
  }
}
