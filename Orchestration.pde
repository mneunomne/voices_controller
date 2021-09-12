public class Orchestration { 
    
  JSONArray audios;
  Voice[] voices = new Voice[maxNumVoices];
  
  Orchestration (JSONArray _audios) {
    audios = _audios;
    // initiate all voices
    for (int i = 0; i < maxNumVoices; i++) {
      int interval = int(cp5.getController("interval_" + i).getValue());
      voices[i] = new Voice(i, i < numActiveVoices, interval); 
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

  void reloadDatabase (JSONArray _audios) {
    audios = _audios;
  }

  JSONObject getNextAudio (int voiceIndex) {
    // get audio not from same speaker
    ArrayList<JSONObject> filtered = new ArrayList<JSONObject>();
    ArrayList<JSONObject> non_filtered = new ArrayList<JSONObject>();
    for (int i = 0; i < audios.size(); i++) {
      JSONObject obj = audios.getJSONObject(i);
      non_filtered.add(obj);
      
      boolean is_disabled = false;
      boolean is_same_speaker = false;
      boolean is_from_text_field = true;

      boolean can_play = false;      

      // if audio is disabled, dont add to filtered list
      if (obj.isNull("disabled") == false) {
        is_disabled = obj.getBoolean("disabled"); 
      }

      String cur_id = obj.getString("user_id").toLowerCase();
      String cur_name = obj.getString("name").toLowerCase();
      String textFilter = voices[voiceIndex].textFilter;

      // check text filter is set
      if (!voices[voiceIndex].textFilter.equals("")){
        is_from_text_field = (cur_name.contains(textFilter.toLowerCase()) || cur_id.contains(textFilter.toLowerCase()));
      }

      // if its from same speaker...
      for (String id : getCurrentSpeakerId()) {
        if (cur_id.equals(id)) {
            is_same_speaker = true;
        }
      }

      // if auto, dont play same speaker if possible
      if (auto_mode) {
        can_play = !is_disabled && !is_same_speaker; 
      } else {
        can_play = !is_disabled && is_from_text_field;
      }
      
      // dont add to filtered list
      if (can_play) {
         filtered.add(obj);
      }
    }
    if (filtered.size() > 0) {
      //  int index = floor(random(0, filtered.size())); 
      return filtered.get(floor(random(0, filtered.size())));
    } else {
      // int index = floor(random(0, audios.size())); 
      return non_filtered.get(floor(random(0, non_filtered.size())));
    }
    
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

  void setVoiceTextFilter (int index, String value) {
    println("setVoiceTextFilter", value);
    voices[index].setTextFilter(value);
  }
  
}
