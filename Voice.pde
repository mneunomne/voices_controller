public class Voice {
  String currentSpeakerId;
  int index;
  float curAudioDuration; 
  String curAudioId;
  String curAudioText = "";
  String currentSpeakerName = "";
  boolean isPlaying = false;
  int interval;
  int lastTimeCheck = 0;
  boolean isActive = false;
  float reverb = 0;
  Voice (int _index, boolean _isActive, int _interval) {
    interval = _interval;
    index = _index;
    isActive = _isActive;
    
  }

  void play (JSONObject audio) {
    println("play!");
    lastTimeCheck = millis();
    isPlaying = true;
    // get audio data
    curAudioDuration = audio.getFloat("duration") * 1000 + 500;
    currentSpeakerId = audio.getString("user_id");
    curAudioId = audio.getString("id");
    currentSpeakerName = audio.getString("name");
    curAudioText = audio.getString("text");
    // send osc play data 
    oscController.sendOscplay(currentSpeakerId, curAudioId, curAudioText, index);
  }

  void end () {
    oscController.sendOscEnd(currentSpeakerId, curAudioId);
    reset();
  }

  void reset () {
    curAudioDuration = 0;
    isPlaying = false;
    curAudioId = "";
    currentSpeakerId = "";
    currentSpeakerName = "";
    curAudioText = "";
  }

  void setActive(boolean val) {
    isActive = val;
    if (val == false) {
      if (isPlaying) {
        end();
      } else {
        reset();
      }
    }
  }

  void setInterval (int val) {
    interval = val;
  }

  void setReverb (float val) {
    reverb = val;
  }


  void update () {
    if (isActive) {
      if (!isPlaying) {
        if (millis() > lastTimeCheck + interval ) {
          // here pick on audio 
          JSONObject audio = orchestration.getNextAudio(index);
          play(audio);
        }
      } else {

        // send effect values
        oscController.sendReverb(currentSpeakerId, reverb);


        // check if audio has finnished playing
        if (millis() > lastTimeCheck + curAudioDuration) {
          end();
        }
      }
    } 
  }


  boolean getIsPlaying () {
    return isPlaying;
  }

  String getSpeakerId () {
    return currentSpeakerId;
  }
}
