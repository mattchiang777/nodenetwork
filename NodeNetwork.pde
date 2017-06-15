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
  // Change background color based on depth and horizontal position
  changeBackground();
  //background(0);
  
  // Run the tracking analysis
  tracker.track();
  // Show the depth image
  //tracker.display();
  

  // Display some info
  displayInfo();
  
  // Set particle node size and velocity limits
  moveParticles();
  
  // Draw lines between particle nodes
  connectParticles();
  
  // Create particles
  addParticles();
  
  // Remove particles if frameRate gets too slow
  removeParticles();  
}

void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (-keyCode == UP) {
      t +=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t -=5;
      tracker.setThreshold(t);
    }
  }
}

void changeBackground() {
  PVector highestPoint = tracker.getHighestPoint();
  int closestValue = tracker.getClosestValue();
  //float b = map(closestValue, tracker.minThreshold, tracker.maxThreshold, 186, 0); //map(frameRate, 0, 60, 70, 0);
  //float r = map(highestPoint.x, 0, tracker.kinect2.depthWidth, 0, 255);//map(avgPosition.x, 0, width, 30, 0);
  float r = 0;
  float g = 0;
  float b = 0;

  //float b = map(highestPoint.x, 0, tracker.kinect2.depthWidth, 0, 255);
  
  println(r, g, b);
  
  // Trick where background doesn't refresh so things stay drawn
  if (frameCount % 10 == 0) {
    background(r, g, b);
  }
  //background(0);
}

void displayInfo() {
  int t = tracker.getThreshold();
  fill(255);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " +
    "UP increase threshold, DOWN decrease threshold " + "highestValue: " + tracker.highestValue + " closestValue: " + tracker.closestValue, 10, 10);
}

void moveParticles() {
  for (int i = allParticles.size()-1; i > -1; i--) {
    Particle p = allParticles.get(i);
    p.move();
    
    stroke(p.h, random(255), 255);
    //strokeWeight(p.vel.mag()*1.25);
    strokeWeight(p.vel.mag()*0.3);
    point(p.pos.x, p.pos.y);
    
    // How long should particles last?
    float limit = random(0.0001, 0.0001);
    //println(limit);
    if (p.vel.mag() < limit) {
      allParticles.remove(p);
    }
  }
}

void connectParticles() {
    for (int i = 0; i < allParticles.size(); i++) {
    Particle p1 = allParticles.get(i);
    for (int j = 0; j < allParticles.size(); j++) {
      Particle p2 = allParticles.get(j);
      
      if (p1 == p2) {
        continue;
      }
      
      stroke(p1.h, random(255), 255, p1.vel.mag()+20);
      
      float d = dist(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y);
      if (d < 350 && p2.vel.mag() > 0.01) { // distance needed before connecting strokes
        //strokeWeight(1);
        strokeWeight(random(1, 3));
        line(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y);
      }
    }
  }
}

void addParticles() {
  currentHue = random(0, 255);
  PVector point = tracker.getHighestPoint();
  float xMap = map(point.x, 0, tracker.kinect2.depthWidth, 0, width);
  float yMap = map(point.y, 0, tracker.kinect2.depthHeight, 0, height);
  
  if (frameCount % 1 == 0 && frameRate > 12) {
    allParticles.add(new Particle(width - xMap,  yMap));
    //allParticles.add(new Particle(mouseX,  mouseY));
  }
}

void removeParticles() {
  // Clear screen if frameRate gets too slow or
  // Clear the first half of particles that were created if number of particles is too big
  if (frameRate <= 12) {
    for (int i = allParticles.size() - 1; i > -1; i--) {
      Particle p = allParticles.get(i);
      allParticles.remove(p);
    }
  }
  else if (allParticles.size() > 35) {
    //for (int i = allParticles.size() / 2 - 1; i > -1; i--) {
      Particle p = allParticles.get(0);
      allParticles.remove(p);
    //}
  }
  for (int i = allParticles.size()-1; i > -1; i--) {
      Particle p = allParticles.get(i);
      if (p.pos.x < 0 || p.pos.x > width || p.pos.y < 0 || p.pos.y > height) {
        allParticles.remove(p);
      }
  }
}