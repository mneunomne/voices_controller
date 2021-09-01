import http.requests.*;
import netP5.*;
import oscP5.*;
import AULib.*;

Archive archive;

OscController osc_controller;

Orchestration orchestration;

ArrayList<NoiseCircluarWalker> walkers = new ArrayList<NoiseCircluarWalker>();

int maxNumVoices = 8;
int numActiveVoices = 1;
int initialInterval = 3000;

void setup () {
  size(1200, 900);

  osc_controller = new OscController();
  osc_controller.connect();

  archive = new Archive();
  thread("loadDatabase");
}

void onArchiveLoaded () {
  orchestration = new Orchestration(archive.getAudios());
}

void draw () {

}

void loadDatabase () {
  archive.load();
}