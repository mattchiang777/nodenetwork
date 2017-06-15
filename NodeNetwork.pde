/*
Kinect node network

A simple prototype of a node network that I'm trying to control via Kinect v2.

Here's a demonstration of it in action:
http://jasonlabbe3d.com/pages/rnd/kinect_node_network.html

Controls:
  - Drag the mouse around.

Author:
  Jason Labbe
 
Site:
  jasonlabbe3d.com
*/

import org.openkinect.processing.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

// The kinect stuff is happening in another class
KinectTracker tracker;

ArrayList<Particle> allParticles = new ArrayList<Particle>();
float currentHue = 0;


void setup() {
  //fullScreen();
  size(1280, 1040);
  //colorMode(HSB, 360);
  
  tracker = new KinectTracker(this);
}


void draw() {
  background(0);
  
  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();
  
  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  //fill(50, 100, 250, 200);
  noStroke();
  //ellipse(v1.x, v1.y, 20, 20);

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  //fill(100, 250, 50, 200);
  fill(255, 0, 0);
  noStroke();
  int xMapped = (int) map(v2.x, 0, 512, 0, width);
  int yMapped = (int) map(v2.y, 0, 424, 0, height);
  ellipse(width - xMapped, yMapped, 5, 5);
  //ellipse(v2.x, v2.y, 20, 20);
  
  
  // Display closest point
  int closestXMapped = (int) map(tracker.cX, 0, 512, 0, width);
  int closestYMapped = (int) map(tracker.cY, 0, 424, 0, width);
  //ellipse(width - closestXMapped, closestYMapped, 50, 50);
  
  // Display highest point
  fill(255);
  println(tracker.hx, tracker.hy, tracker.highestValue);
  ellipse(width - map(tracker.hx, 0, 512, 0, width), map(tracker.hy, 0, 424, 0, height), 50, 50);
  

  // Display some info
  int t = tracker.getThreshold();
  fill(255);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " +
    "UP increase threshold, DOWN decrease threshold" + "closestValue: " + tracker.closestValue, 10, 10);
  
  for (int i = allParticles.size()-1; i > -1; i--) {
    Particle p = allParticles.get(i);
    p.move();
    
    stroke(p.h, random(255), 255);
    strokeWeight(p.vel.mag()*1.25);
    point(p.pos.x, p.pos.y);
    
    // How long should particles last?
    float limit = random(0.0001, 0.0001);
    //println(limit);
    if (p.vel.mag() < limit) {
      allParticles.remove(p);
    }
  }
  
  for (int i = 0; i < allParticles.size(); i++) {
    Particle p1 = allParticles.get(i);
    for (int j = 0; j < allParticles.size(); j++) {
      Particle p2 = allParticles.get(j);
      
      if (p1 == p2) {
        continue;
      }
      
      stroke(p1.h, random(255), 255, p1.vel.mag()+20);
      
      float d = dist(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y);
      if (d < 250 && p2.vel.mag() > 0.05) { // distance needed before connecting strokes
        strokeWeight(1);
        line(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y);
      }
    }
  }
  
  currentHue = random(0, 255);
  if (frameCount % 2 == 0 && tracker.closestValue >= 600) {
    allParticles.add(new Particle(width - xMapped, yMapped));
  }
  
  // Clear screen if frameRate gets too slow
  if (frameRate <= 5) {
    for (int i = allParticles.size()-1; i > -1; i--) {
      Particle p = allParticles.get(i);
      allParticles.remove(p);
    }
  }
}

void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t +=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t -=5;
      tracker.setThreshold(t);
    }
  }
}