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
    remoteBroadcast = new NetAddress("10.10.48.88",7400);
  }

  void sendOscplay (long speakerId, int audioID, String audioText, int index) {
    // VISUAL
    OscMessage visMessage = new OscMessage("/play");
    visMessage.add(Long.toString(speakerId));
    visMessage.add(audioID);
    visMessage.add(audioText);
    oscP5.send(visMessage, localBroadcast);
    
    /*
    // set the index of MaxMSP "voice player" a way to save memory in MaxMSP
    for (NoiseCircluarWalker walker : walkers) {
      long _id = walker.getSpeakerId();
      if (_id == speakerId) {
         walker.setVoiceIndex(index);
      }
    }
    */
    
    println("[OscController] send play", audioText);
        
    // AUDIO
    OscMessage audioMessage = new OscMessage("/play");
    audioMessage.add(audioID);
    audioMessage.add(index);
    oscP5.send(audioMessage, remoteBroadcast);
  }

  void sendOscEnd (long speakerId, int audioID) {
    OscMessage myOscMessage = new OscMessage("/end");
    myOscMessage.add(Long.toString(speakerId));
    myOscMessage.add(audioID);
    oscP5.send(myOscMessage, localBroadcast);
  }

  void onNewAudio (OscMessage theOscMessage) {
    JSONObject new_audio_data = parseJSONObject(theOscMessage.get(0).stringValue());
    println("[OscController] new_audio_data", new_audio_data);
    archive.appendAudio(new_audio_data);
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
