class OscController {
  OscP5 oscP5;

  NetAddress remoteBroadcast; 
  NetAddress localBroadcast;

  String maxAddress = "10.10.48.88";
  int maxPort = 74000;

  String visualAddress = "127.0.0.1";
  int visualPort = 32000;

  OscController () {
    // init os controller
  }

  void connect () {
    oscP5 = new OscP5(this,12000);
    localBroadcast = new NetAddress("127.0.0.1",32000);
    remoteBroadcast = new NetAddress("10.10.48.111",7400);
  }

  void sendOscplay (String speakerId, String audioID, String audioText, int index) {
    /* VISUAL */
    OscMessage visMessage = new OscMessage("/play");
    visMessage.add(speakerId);
    visMessage.add(audioID + ".wav");
    visMessage.add(audioText);
    oscP5.send(visMessage, localBroadcast);

    // set the index of MaxMSP "voice player" a way to save memory in MaxMSP
    for (NoiseCircularWalker walker : walkers) {
      String _id = walker.getSpeakerId();
      if (_id.equals(speakerId)) {
         walker.setVoiceIndex(index);
      }
    }
        
    /* Audio */
    OscMessage audioMessage = new OscMessage("/play");
    audioMessage.add(audioID);
    audioMessage.add(index);
    oscP5.send(audioMessage, remoteBroadcast);

    println("[OscController] send play", audioText);
  }

  void sendOscEnd (String speakerId, String audioId) {
    OscMessage myOscMessage = new OscMessage("/end");
    myOscMessage.add(speakerId);
    myOscMessage.add(audioId);
    oscP5.send(myOscMessage, localBroadcast);
  }

  void sendVisualOSC (int index, float theta, float radius) {
    OscMessage visMessage = new OscMessage("/pos");
    visMessage.add(index);
    visMessage.add(theta);
    // visMessage.add(0.001);
    visMessage.add(radius / height);
    oscP5.send(visMessage, localBroadcast);
  }
  
  void sendAudioOSC (int index, float theta, float radius) {
    OscMessage audioMessage = new OscMessage("/pos");
    audioMessage.add(index);
    audioMessage.add((theta / (PI * 2) * 360 - 90) % 360 );
    float audioRadius = map(radius / (height/2), 0.2, 1, 0, 1);
    audioMessage.add(audioRadius);
    oscP5.send(audioMessage, remoteBroadcast);
  }

  void onNewAudio (OscMessage theOscMessage) {
    JSONObject new_audio_data = parseJSONObject(theOscMessage.get(0).stringValue());
    println("[OscController] new_audio_data", new_audio_data);
    // not use direct function to avoid threading
    newAudio = new_audio_data;
    hasNewAudio = true;
  }

  void oscEvent(OscMessage theOscMessage) {
    /* print the address pattern and the typetag of the received OscMessage */
    print("[OscController]  ### received an osc message.");
    print("[OscController]  addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());

    if (theOscMessage.checkAddrPattern("/new_audio")) {
      onNewAudio(theOscMessage);
    }
  }
}
