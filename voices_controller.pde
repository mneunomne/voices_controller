import http.requests.*;
import netP5.*;
import oscP5.*;
import AULib.*;
import controlP5.*;

ControlP5 cp5;

Gui gui;

Archive archive;

OscController osc_controller;

Orchestration orchestration;

ArrayList<NoiseCircularWalker> walkers = new ArrayList<NoiseCircularWalker>();

PGraphics pg;

int maxNumVoices = 8;
int numActiveVoices = 1;
int initialInterval = 3000;

// value in meters
float projection_radius = 3;
float minRadius = 1;
float maxRadius = 3.5;
float debug_radius = 4;

int debug_width = 583 - 20; 

float debug_scale = debug_width / (debug_radius*2); 

boolean dbLoaded = false;
boolean firstLoaded = false;

void setup () {
  size(1194, 834, P2D);

  cp5 = new ControlP5(this);

  // setup debug canvas
  pg = createGraphics(debug_width, debug_width, P2D);
  pg.ellipseMode(RADIUS);


  // Graphical user interface
  gui = new Gui();
  gui.init();

  // start osc controller
  osc_controller = new OscController();
  osc_controller.connect();

  archive = new Archive();
  thread("loadDatabase");
}

void onArchiveLoaded () {
  orchestration = new Orchestration(archive.getAudios());
  dbLoaded = true;
}

// draw controller debug 
void draw () {
  background(0);
  update();
  gui.draw();
}

void update() {
  if (dbLoaded) {
    // only runs once after db is loaded. avoiding multithreading
    if (!firstLoaded) {
      archive.firstLoad();
      firstLoaded = true;
    }

    orchestration.update();
    for (NoiseCircularWalker walker : walkers) {
      walker.update();
    }
  }
}

void loadDatabase () {
  archive.load();
}