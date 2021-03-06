class OscController {
  OscP5 oscP5;

  NetAddress remoteBroadcast; 
  NetAddress localBroadcast;

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

    // println("[OscController] send play", audioText);
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

  void sendOscStart () {
    OscMessage audioMessage = new OscMessage("/start");
    oscP5.send(audioMessage, remoteBroadcast);
  }

  void onNewAudio (OscMessage theOscMessage) {
    String jsonString = theOscMessage.get(0).stringValue();
    JSONObject new_audio_data = parseJSONObject(theOscMessage.get(0).stringValue());
    // println("[OscController] new_audio_data", new_audio_data);
    // not use direct function to avoid threading
    newAudio = new_audio_data;
    addedNewAudio = false;
    hasNewAudio = true;
    boolean is_disabled = false;
    if (new_audio_data.isNull("disabled") == false) {
      is_disabled = new_audio_data.getBoolean("disabled");
    }

    if (!is_disabled) {
      hasNewAudioToPlay = true;
      println("hasNewAudioToPlay!");
    }

    println("idle auto_mode", idle, auto_mode);
    
    if (idle && auto_mode) {
      // playedNewAudio = true;
      // startAuto();
    }

    println("onUpdateAudio is_disabled", is_disabled);
  }
  
  void onUpdateAudio(OscMessage theOscMessage) {
    String jsonString = theOscMessage.get(0).stringValue();
    JSONObject new_audio_data = parseJSONObject(theOscMessage.get(0).stringValue());

    boolean is_disabled = false;
    if (new_audio_data.isNull("disabled") == false) {
      is_disabled = new_audio_data.getBoolean("disabled");
    }

    println("onUpdateAudio");
    println("is_disabled", is_disabled);

    newAudio = new_audio_data;
    if (!is_disabled) {
      hasNewAudioToPlay = true;
      println("hasNewAudioToPlay!");
    }

    println("idle auto_mode", idle, auto_mode);
    if (idle && auto_mode) {
      playedNewAudio = true;
      startAuto();
    }
    // also load database in general
    loadDatabase();
  }

  void sendNewAudio (JSONObject new_audio_data) {
    // send new audio to visualization
    OscMessage visMessage = new OscMessage("/new_audio");
    visMessage.add(new_audio_data.toString());
    oscP5.send(visMessage, localBroadcast);
    println("[OscController] sentNewAudio", new_audio_data.toString());
  }
  

  void sendBlur (float value) {
    OscMessage visMessage = new OscMessage("/blur");
    visMessage.add(value);
    oscP5.send(visMessage, localBroadcast);
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
      onUpdateAudio(theOscMessage);
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
