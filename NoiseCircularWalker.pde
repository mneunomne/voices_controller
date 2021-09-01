// Noise Walker
class NoiseCircluarWalker {
  float aoff;
  float roff;
  float aVel = .001;
  float rVel = .001;
  long id; 
  float posX, posY;
  String name; 
  int index; 
  int voiceIndex; 
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
    posX = radius * cos( theta );
    posY = radius * sin( theta );
    pushMatrix();
    noFill();
    for (long _id : orchestration.getCurrentSpeakerId()) {
      if (_id == id) {
        fill(255); 
        osc_controller.sendAudioOSC(theta, radius);
      }
    }
    
    osc_controller.sendVisualOSC(theta, radius);
    
    translate(height/2, height/2);
    ellipse(posX, posY, 4, 4);
    popMatrix();
    
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
