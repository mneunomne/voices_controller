import http.requests.*;
import netP5.*;
import oscP5.*;
import AULib.*;

Archive archive;

OscController osc_controller;

Orchestration orchestration;

int maxNumVoices = 8;
int numActiveVoices = 1;
int initialInterval = 3000;

void setup () {
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