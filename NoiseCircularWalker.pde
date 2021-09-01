// Noise Walker
class NoiseCircluarWalker {
  float aoff;
  float roff;
  float aVel = .001;
  float rVel = .001;
  long id; 
  String name; 
  int index; 
  int voiceIndex; 
  PVector pos;
  boolean isPlaying = false;
  NoiseCircluarWalker (long _id, String _name, int _index) {
    aoff = random(10000);
    roff = random(10000);
    id = _id;
    name = _name;
    index = _index;
  }
  
  void update() {
    noiseDetail(2,0.5);
    aoff = aoff + aVel;
    roff = roff + rVel;
    float theta = noise(aoff) * 4 * PI;
    float radius = min(map(noise(roff), 0, 0.8, minRadius, maxRadius), maxRadius);
    int posX = radius * cos( theta );
    int posY = radius * sin( theta );
    pos = new PVector(posX, posY);
    // only send position if speaker is playing
    isPlaying = false;
    for (long _id : orchestration.getCurrentSpeakerId()) {
      if (_id == id) {
        osc_controller.sendAudioOSC(theta, radius);
        isPlaying = true;
      }
    }
    osc_controller.sendVisualOSC(theta, radius);
  }

  PVector getPosition () {
    return pos;
  } 
  
  void setAngleVelocity (float vel) {
    aVel = vel / 10000;
  }
  
  void setRadiusVelocity (float vel) {
    rVel = vel / 10000;
  }
  
  void setVoiceIndex (int _voiceIndex) {
    voiceIndex = _voiceIndex;
  }
  
  long getSpeakerId() {
    return id;
  }
}
