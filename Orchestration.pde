public class Orchestration { 
    
  JSONArray audios;
  Voice[] voices = new Voice[maxNumVoices];
  
  Orchestration (JSONArray _audios) {
    audios = _audios;
    // initiate all voices
    for (int i = 0; i < maxNumVoices; i++) {
     voices[i] = new Voice(i, i < numActiveVoices, initialInterval); 
    }
  }
  
  void setActiveVoices (int amount) {
    numActiveVoices = amount;
    for(int i = 0; i < maxNumVoices; i++) {
      if (i < numActiveVoices) {
        voices[i].setActive(true); 
      } else {
        voices[i].setActive(false);
      }
    }
  }

  void setVoiceActive (int index, boolean value) {
    voices[index].setActive(value);
    int amount = 0;
    for(int i = 0; i < maxNumVoices; i++) {
      if (voices[i].isActive) {
        amount++;
      }
    }
    numActiveVoices = amount;
  }
  
  void update () {
    for(int i = 0; i < maxNumVoices; i++) {
       voices[i].update();
    }
  }

  JSONObject getNextAudio (int voiceIndex) {
    // get audio not from same speaker
    ArrayList<JSONObject> filtered = new ArrayList<JSONObject>();
    for (int i = 0; i < audios.size(); i++) {
      JSONObject obj = audios.getJSONObject(i);
      String cur_id = obj.getString("user_id");
      boolean hasFound = false;       
      for (String id : getCurrentSpeakerId()) {
         if (cur_id.equals(id)) {
            hasFound = true;
         }
      }
      if (!hasFound) {
         filtered.add(obj);
      }
    }
    int index = floor(random(0, filtered.size())); 
    return filtered.get(index);
  }
  
  ArrayList<String> getCurrentSpeakerId () {
    ArrayList<String> ids = new ArrayList<String>();
    for(int i = 0; i < numActiveVoices; i++) {
      if (voices[i].isPlaying) {
        ids.add(voices[i].getSpeakerId());
      }
    }
    return ids;
  }
  
  void setVoiceInterval (int index, int value) {
    voices[index].setInterval(value);
  }

  void setVoiceReverb (int index, float value) {
    voices[index].setReverb(value);
  }
  
}
