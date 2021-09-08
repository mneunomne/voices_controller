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

boolean auto_mode = true;

JSONObject newAudio;
boolean hasNewAudio = false;

int waveform_h = 100;
WaveForm waveform;

int fr = 30;

PFont font;

Chart myChart;

void setup () {
  size(1280, 1024, P2D);

  cp5 = new ControlP5(this);
  cp5.setColorForeground(color(255));
  cp5.setColorBackground(color(80));

  //font 
  font = createFont("arial", 12);

  // setup debug canvas
  pg = createGraphics(debugWidth, debugWidth, P2D);
  pg.ellipseMode(RADIUS);


  // Graphical user interface
  gui = new Gui();
  gui.init();

  waveform = new WaveForm(waveform_h);
  waveform.loadJson();

  // start osc controller
  oscController = new OscController();
  oscController.connect();

  archive = new Archive();
  thread("loadDatabase");

  frameRate(30);
}

void onArchiveLoaded () {
  // if its first time loading, create orchestration 
  if (!firstLoaded) {
    println("Archive first time Loaded!");
    orchestration = new Orchestration(archive.getAudios());
    firstLoaded = true;
  } else {
    // if not, just update orchestration data
    println("Archive update");
    orchestration.reloadDatabase(archive.getAudios());
  }
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

    waveform.update();
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

  if(theControlEvent.isFrom("load_db")) { 
    thread("loadDatabase");
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
    // text filter
    if(theControlEvent.isFrom("filter_" + i)) {
      String value = theControlEvent.getStringValue();
      orchestration.setVoiceTextFilter(i, value);
      println("get string value", i, value);
      
    }
  }
}

void angle_vel(float vel) {
  if (!dbLoaded) return;
  for(int i = 0; i < walkers.size(); i++) {
    walkers.get(i).setAngleVelocity(vel);
  }
}

void radial_vel(float vel) {
  if (!dbLoaded) return;
  for(int i = 0; i < walkers.size(); i++) {
    walkers.get(i).setRadiusVelocity(vel);
  }
}

void blur (float value) {
  if (!dbLoaded) return;
  oscController.sendBlur(value);
}

void auto_mode (float value) {
  auto_mode = value == 1.0;
  //println("value", value);
}