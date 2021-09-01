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
      long cur_id = obj.getLong("user_id");
      boolean hasFound = false;       
      for (long id : getCurrentSpeakerId()) {
         if (cur_id == id) {
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
  
  long [] getCurrentSpeakerId () {
    long [] ids = new long[numActiveVoices];
    for(int i = 0; i < numActiveVoices; i++) {
       ids[i] = voices[i].getSpeakerId();
    }
    return ids;
  }
  
  void setVoiceInterval (int index, int value) {
    voices[index].setInterval(value);
  }
  
}