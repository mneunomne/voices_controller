class OscController {
  OscP5 oscP5;

  NetAddress remoteBroadcast; 
  NetAddress localBroadcast;

  String maxAddress = "10.10.48.85";
  int maxPort = 12000;

  String visualAddress = "127.0.0.1";
  int visualPort = 32000;

  OscController () {
    // init os controller
  }

  void connect () {
    oscP5 = new OscP5(this,12000);
    localBroadcast = new NetAddress(visualAddress,visualPort);
    remoteBroadcast = new NetAddress(maxAddress,maxPort);
  }

  void sendOscplay (String speakerId, String audioId, String audioText, int index) {
    /* VISUAL */
    OscMessage visMessage = new OscMessage("/play");
    visMessage.add(speakerId);
    visMessage.add(audioId);
    visMessage.add(index);
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
    audioMessage.add(audioId);
    audioMessage.add(index);
    oscP5.send(audioMessage, remoteBroadcast);

    println("[OscController] send play", audioText);
  }

  void sendOscEnd (String speakerId, String audioId) {
    OscMessage visMessage = new OscMessage("/end");
    visMessage.add(speakerId);
    visMessage.add(audioId);
    oscP5.send(visMessage, localBroadcast);
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
    float audioAngle = (theta / (PI * 2) * 360 - 90) % 360 ;
    audioMessage.add(audioAngle);
    float audioRadius = radius / projectionRadius;
    audioMessage.add(audioRadius);
    oscP5.send(audioMessage, remoteBroadcast);
  }

  void sendReverb (String speakerId, float value ) {
    OscMessage visMessage = new OscMessage("/reverb");
    visMessage.add(speakerId);
    visMessage.add(value);
    oscP5.send(visMessage, localBroadcast);
  }

  void onNewAudio (OscMessage theOscMessage) {
    JSONObject new_audio_data = parseJSONObject(theOscMessage.get(0).stringValue());
    // println("[OscController] new_audio_data", new_audio_data);
    // not use direct function to avoid threading
    newAudio = new_audio_data;
    hasNewAudio = true;
  }

  void sendBlur (float value) {
    OscMessage visMessage = new OscMessage("/blur");
    visMessage.add(value);
    oscP5.send(visMessage, localBroadcast);
    println("send blur message!", value);
  }

  void oscEvent(OscMessage theOscMessage) {
    /* print the address pattern and the typetag of the received OscMessage */
    // print("[OscController]  ### received an osc message.");
    // print("[OscController]  addrpattern: "+theOscMessage.addrPattern());
    // println(" typetag: "+theOscMessage.typetag());

    if (theOscMessage.checkAddrPattern("/new_audio")) {
      onNewAudio(theOscMessage);
    }

    if (theOscMessage.checkAddrPattern("/update_audio")) {
      loadDatabase();
    }

    if (theOscMessage.checkAddrPattern("/waveform1")) {
      waveform.loadDataChunk(0, theOscMessage);
    }

    if (theOscMessage.checkAddrPattern("/waveform2")) {
      waveform.loadDataChunk(1, theOscMessage);
    }

    if (theOscMessage.checkAddrPattern("/waveform3")) {
      waveform.loadDataChunk(2, theOscMessage);
    }

    if (theOscMessage.checkAddrPattern("/waveform4")) {
      waveform.loadDataChunk(3, theOscMessage);
    }
  }
}
