import http.requests.*;
import netP5.*;
import oscP5.*;
import AULib.*;
import controlP5.*;

ControlP5 cp5;

Gui gui;

Archive archive;

OscController oscController;

Orchestration orchestration;

ArrayList<NoiseCircularWalker> walkers = new ArrayList<NoiseCircularWalker>();

PGraphics pg;

int maxNumVoices = 8;
int numActiveVoices = 1;
int initialInterval = 5000;

// value in meters
float projectionRadius = 3;
float minRadius = 1;
float maxRadius = 3.5;
float debugRadius = 4;

int debugWidth = 583 - 20; 

float debugScale = debugWidth / (debugRadius*2); 

boolean dbLoaded = false;
boolean firstLoaded = false;

JSONObject newAudio;
boolean hasNewAudio = false;

void setup () {
  size(1194, 834, P2D);

  cp5 = new ControlP5(this);

  // setup debug canvas
  pg = createGraphics(debugWidth, debugWidth, P2D);
  pg.ellipseMode(RADIUS);


  // Graphical user interface
  gui = new Gui();
  gui.init();

  // start osc controller
  oscController = new OscController();
  oscController.connect();

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

    if (hasNewAudio) {
      archive.addNewAudio(newAudio);
      hasNewAudio = false;
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