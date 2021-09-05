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
int numActiveVoices = 0;
int initialInterval = 5000;

// value in meters
float projectionRadius = 3;
float innerRadius = 1;
float outerRadius = 3.5;
float maxRadius = 5;
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
  println("Archive Loaded!");
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

void controlEvent(ControlEvent theControlEvent) {
  if(!dbLoaded) return;

  if(theControlEvent.isFrom("radius")) {
    innerRadius = theControlEvent.getController().getArrayValue(0);
    outerRadius = theControlEvent.getController().getArrayValue(1);
  }

  if(theControlEvent.isFrom("load_svgs")) { 
    archive.loadSvgs();
  }

  // Voices Controllers  
  for (int i = 0; i < maxNumVoices; i++) {
    // toggle
    if(theControlEvent.isFrom("_" + i)) {
      boolean value = theControlEvent.getValue() == 1.0;
      orchestration.setVoiceActive(i, value);
    }
    // reverb
    if(theControlEvent.isFrom("reverb_" + i)) {
      float value = theControlEvent.getValue();
      orchestration.setVoiceReverb(i, value);
      // oscController.sendReverb(i, value);
    }
  }
}

void angle_vel(float vel) {
  for(int i = 0; i < walkers.size(); i++) {
    walkers.get(i).setAngleVelocity(vel);
  }
}

void radial_vel(float vel) {
  for(int i = 0; i < walkers.size(); i++) {
    walkers.get(i).setRadiusVelocity(vel);
  }
}

void blur (float value) {
  oscController.sendBlur(value);
}