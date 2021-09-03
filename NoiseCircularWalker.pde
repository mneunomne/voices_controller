// Noise Walker
class NoiseCircularWalker {
  float aoff;
  float roff;
  float aVel = .001;
  float rVel = .001;
  String id; 
  String name; 
  int index; 
  int voiceIndex; 
  PVector pos;
  boolean isPlaying = false;
  NoiseCircularWalker (String _id, String _name, int _index) {
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
    float radius = min(map(noise(roff), 0, 1, minRadius, maxRadius), maxRadius);
    float posX = radius * cos( theta );
    float posY = radius * sin( theta );
    pos = new PVector(posX, posY);
    // only send position if speaker is playing
    isPlaying = false;
    for (String _id : orchestration.getCurrentSpeakerId()) {
      if (_id.equals(id)) {
        oscController.sendAudioOSC(voiceIndex, theta, radius);
        isPlaying = true;
      }
    }
    oscController.sendVisualOSC(index, theta, radius);
  }

  void draw (PGraphics pg) {
    if (isPlaying) {
      pg.fill(255);
    } else {
      pg.noFill();
    }
    float x = pos.x * debugScale;
    float y = pos.y * debugScale;
    pg.ellipse(x, y, 5, 5);
    pg.text(index, x + 5, y);
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
  
  String getSpeakerId() {
    return id;
  }
}
