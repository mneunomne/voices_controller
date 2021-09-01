public class Voice {
  long currentSpeakerId;
  int index;
  int curAudioDuration; 
  int curAudioId;
  String curAudioText = "";
  String currentSpeakerName = "";
  boolean isPlaying = false;
  int interval;
  int lastTimeCheck = 0;
  boolean isActive = false;

  Voice (int _index, boolean _isActive, int _interval) {
    interval = _interval;
    index = _index;
    isActive = _isActive;
    
  }

  void play (JSONObject audio) {
    lastTimeCheck = millis();
    isPlaying = true;
    // get audio data
    curAudioDuration = audio.getInt("duration") * 1000 + 500;
    currentSpeakerId = audio.getLong("user_id");
    curAudioId = audio.getInt("id");
    currentSpeakerName = audio.getString("name");
    curAudioText = audio.getString("text");
    // send osc play data 
    osc_controller.sendOscplay(currentSpeakerId, curAudioId, curAudioText, index);
  }

  void end () {
    osc_controller.sendOscEnd(currentSpeakerId, curAudioId);
    reset();
  }

  void reset () {
    curAudioDuration = 0;
    isPlaying = false;
    curAudioId = 0;
    currentSpeakerId = 0;
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


  void update () {
    if (isActive) {
      if (!isPlaying) {
        if (millis() > lastTimeCheck + interval ) {
          // here pick on audio 
          JSONObject audio = orchestration.getNextAudio(index);
          play(audio);
        }
      } else {
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

  long getSpeakerId () {
    return currentSpeakerId;
  }
}
