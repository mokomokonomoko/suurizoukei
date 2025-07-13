import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Movie video;
Capture cam;

void setup() {
  size(640, 480);
   String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);

    // Or, the camera name can be retrieved from the list (you need
    // to enter valid a width, height, and frame rate for the camera).
    //cam = new Capture(this, 640, 480, "FaceTime HD Camera (Built-in)", 30);
  }

  // Start capturing the images from the camera
  cam.start();
  //video = new Movie(this, "sample1.mov");
  opencv = new OpenCV(this, 640, 480);
}

void draw() {
  background(0);

  if (cam.available()) {
    cam.read(); // ← これが重要！
  }

  if (cam.width == 0 || cam.height == 0)
    return;

  opencv.loadImage(cam);
  opencv.calculateOpticalFlow();

  image(cam, 0, 0);
  //translate(cam.width, 0);
  stroke(255, 0, 0);
  opencv.drawOpticalFlow();

  PVector aveFlow = opencv.getAverageFlow();
  int flowScale = 50;

  stroke(255);
  strokeWeight(2);
  line(cam.width/2, cam.height/2, cam.width/2 + aveFlow.x*flowScale, cam.height/2 + aveFlow.y*flowScale);
}
