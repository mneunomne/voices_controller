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

// value in meters
float projectionRadius = 2.80;
float innerRadius = 1;
float outerRadius = 2.8;
float maxRadius = 3;
float debugRadius = 2.80;
int debugWidth = 583 - 20; 
float debugScale = debugWidth / (debugRadius*2); 

// loaded states
boolean dbLoaded = false;
boolean firstLoaded = false;

// States
boolean auto_mode = true;
boolean idle = true;
boolean running = false;
boolean loop = false;

JSONObject newAudio;
String lastAudio = "";
boolean hasNewAudio = false;
boolean addedNewAudio = false;
boolean hasNewAudioToPlay = false; 
boolean playedNewAudio = false;

int waveform_h = 150;
float wave_speed = 512/300;
WaveForm waveform;

int fr = 30;

PFont font;

Chart myChart;

int startDelay=100;

float newAudioChance = 0.25;

JSONObject config;
// GLOBAL CONFIGS
String maxAddress = "10.10.48.85";
int maxPort = 12000;
String visualAddress = "127.0.0.1";
int visualPort = 32000;
String text_svg_folder = "/Users/hfkmacmini/archive_folder_sync/texts/";

void setup () {
  // fullScreen(P2D, 1);
  size(1280, 1024, P2D);

  // load config
  config = loadJSONObject("data/config.json");
  maxAddress = config.getString("max_ip");
  maxPort = config.getInt("max_port");
  visualAddress = config.getString("visual_ip");
  visualPort = config.getInt("visual_port");
  text_svg_folder = config.getString("text_svg_folder");

  cp5 = new ControlP5(this);
  cp5.setColorForeground(color(255, 80));
  cp5.setColorBackground(color(255, 20));

  //font 
  font = createFont("Courier New", 12);

  // setup debug canvas
  pg = createGraphics(debugWidth, debugWidth, P2D);
  pg.ellipseMode(RADIUS);

  pg.textFont(font);
  textFont(font);


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

  frameRate(fr);
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
    // if there is a new audio, add it to archive
    if (hasNewAudio && !addedNewAudio) {
      archive.addNewAudio(newAudio);
      // debug text
      lastAudio =  newAudio.toString().replace("\n", "");
      // hasNewAudio = false;
      addedNewAudio = true;
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

void startAuto () {
  println("start auto");
  playedNewAudio = true;
  idle = false;
  running = true;
  waveform.start();
}

void goIdle () {
  // to do, transition, waveform
  println("goIdle!");
  waveform.reset();
  idle = true;
  running = false;
}

void loadedNewWaveform () {
  startAuto();
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
    // interval
    if(theControlEvent.isFrom("interval_" + i)) {
      int value = int(theControlEvent.getValue());
      orchestration.setVoiceInterval(i, value);
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

void wave_speed (float value) {
  wave_speed = value;
}

void idle () {
  println("idle!");
  goIdle();
} 

void started () {
  println("run!");
  startAuto();
}

void loop (float value) {
  loop = value == 1.0;
}

void set_start_delay (float value) {
  println("startDelay", startDelay);
  startDelay = int(value) * -1 * fr; 
}

void new_audio_chance (float value) {
  newAudioChance = value;
}

void keyPressed () {
 switch(key) {
  case 'l':
    // loads the saved layout
    // cp5.loadProperties();
    break;
  case 's':
    // saves the layout
    // cp5.saveProperties();
    break;
 }
}