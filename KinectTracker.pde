// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan
// Track and display eyes using OpenCV and the Kinect2 camera

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

class KinectTracker {

  // Depth threshold
  int minThreshold = 500;
  int maxThreshold = 750;
  //int threshold = 1930;

  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;

  // Depth data
  int[] depth;
  
  // Closest value
  int closestValue;
  int cX;
  int cY;
  
  // Highest point
  int highestValue;
  int hx = 0;
  int hy = 0;

  // What we'll show the user
  PImage display;
  
  //Kinect2 class
  Kinect2 kinect2;
  
  KinectTracker(PApplet pa) {
    
    //enable Kinect2
    kinect2 = new Kinect2(pa);
    kinect2.initDepth();
    kinect2.initVideo();
    kinect2.initDevice();
    
    // Make a blank image
    //display = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
    display = createImage(width, height, RGB);
    
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect2.getRawDepth();
    closestValue = 8000;
    highestValue = height;

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for (int x = 0; x < kinect2.depthWidth; x++) {
      for (int y = 0; y < kinect2.depthHeight; y++) {
        // Mirroring the image
        int offset = kinect2.depthWidth - x - 1 + y * kinect2.depthWidth;
        // Unmirror the image
        //int offset = x + y * kinect2.depthWidth;        
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (rawDepth > minThreshold && rawDepth < maxThreshold && x > 50 && y > 50) {
          sumX += x;
          sumY += y;
          count++;
          
          // update closest point
          updateClosest(x, y, rawDepth);
          
          // update highest point
          if (closestValue > minThreshold && closestValue < maxThreshold) {
            updateHighest(x, y);
          }
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count, sumY/count);
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
  }

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }
  
  PVector getHighestPoint() {
    return new PVector(hx, hy);
  }
  
  int getHighestValue() {
    return highestValue;
  }
  
  // Very shaky because of stray pixels
  PVector getClosestPoint() {
    return new PVector(cX, cY);
  }
  
  int getClosestValue() {
    return closestValue;
  }

  void display() {
    PImage img = kinect2.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kinect2.depthWidth; x++) {
      for (int y = 0; y < kinect2.depthHeight; y++) {
        // mirroring image
        //int offset = (kinect2.depthWidth - x - 1) + y * kinect2.depthWidth;
        // unmirror the image
        int offset = x + y * kinect2.depthWidth;
        // Raw depth
        int rawDepth = depth[offset];
        
        int xMapped = (int) map(x, 0, 512, 0, width);
        int yMapped = (int) map(y, 0, 424, 0, height);
        //int pix = x + y*display.width;
        int pix = xMapped + yMapped*display.width;
        
        
        if (rawDepth > minThreshold && rawDepth < maxThreshold) {
          // A red color instead
          display.pixels[pix] = color(150, 50, 50);
          //display.pixels[pix] = color(map(rawDepth, minThreshold, maxThreshold, 106, 127), map(rawDepth, minThreshold, maxThreshold, 0, 35), 255);
          
        } else {
          //display.pixels[pix] = img.pixels[offset];
          display.pixels[pix] = color(0, 0, 0);
        }
      }
    }
    
    display.updatePixels();
    
    if (closestValue > minThreshold && closestValue < maxThreshold) {
      // Show where the highestPoint is
      //image(kinect2.getDepthImage(), 0, 0);
      fill(255, 255, 255);
      float mapX = map(hx, 0, kinect2.depthWidth, 0, width);
      float mapY = map(hy, 0, kinect2.depthHeight, 0, height);
      ellipse(width - mapX, mapY, 10, 10);
    }

    // Draw the image
    image(display, 0, 0);
  }

  int getThreshold() {
    return maxThreshold;
  }

  void setThreshold(int t) {
    maxThreshold =  t;
  }
  
  void updateClosest(int x, int y, int rawDepth) {
    if (rawDepth < closestValue) {
      closestValue = rawDepth;
      cX = x;
      cY = y;
    }
  }
  
  void updateHighest(int x, int y) {
    // highest point
    if (y < highestValue) {
      highestValue = y;
      hx = x;
      hy = y;
      ////highest point
      //fill(255);
      //println(hx, hy, highestValue);
      //ellipse(map(hx, 0, 512, 0, width), map(hy, 0, 424, 0, height), 50, 50);
    }
  }
}