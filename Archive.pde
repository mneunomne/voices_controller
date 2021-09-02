class Archive {
  JSONArray audios;
  JSONArray users;
  ArrayList<Word> words = new ArrayList<Word>();
  String server_url = "https://pandemic-archive-of-voices-db.herokuapp.com"; // http://localhost:7777
  
  Archive () {
    // loadDatabase();
  }

  void load () {
    // get database data from api
    GetRequest get = new GetRequest(server_url + "/api/data");
    get.send();
    get.addHeader("Accept", "application/json");
    JSONObject json = parseJSONObject(get.getContent());

    // save audio and user list locally
    audios = json.getJSONArray("audios");
    users = json.getJSONArray("users");

    // create .json points for each word in database
    for (int i = 0; i < audios.size(); i++) {    
      JSONObject audio = audios.getJSONObject(i);
      Word word = new Word(audio);
      words.add(word);
    }
    
    // create the moving points for each user
    for (int i = 0; i < users.size(); i++) {    
      JSONObject user = users.getJSONObject(i); 
      String name = user.getString("name");
      String id = user.getString("id");
      NoiseCircularWalker n = new NoiseCircularWalker(id, name, i);
      walkers.add(n);
    }
    println("[Archive] Loaded database with " + audios.size() + " audios");
    // loaded!
    onArchiveLoaded();
  }

  void appendAudio (JSONObject new_audio_data) {
    audios.append(new_audio_data);
    println("[Archive] New audio data appended, with now " + audios.size() + " audios");

    // check if user from new audio already exists in local array
    String new_user_id = new_audio_data.getString("user_id");
    boolean hasFound = false;
    for (int i = 0; i < users.size(); i++) {
      String user_id = users.getJSONObject(i).getString("id");
      hasFound = hasFound || user_id.equals(new_user_id);
      println(hasFound, new_user_id, user_id);
    }

    // if it is a new user...
    if (!hasFound) {
      // create new user data object based on new audio data
      JSONObject new_user = new JSONObject();
      new_user.put("id", new_audio_data.getString("user_id"));
      new_user.put("name", new_audio_data.getString("name"));
      appendUser(new_user);
    }
  }

  void firstLoad () {
    for (Word word : words) {
      word.load();
    }
  }

  void appendUser (JSONObject new_user) {
    // append new user
    users.append(new_user);
    // create new walker
    String name = new_user.getString("name");
    String id = new_user.getString("id");
    NoiseCircularWalker new_walker = new NoiseCircularWalker(id, name, walkers.size());
    walkers.add(new_walker);
    println("[Archive] New user data appended, with now " + users.size() + " users");
  }

  JSONArray getAudios () {
    return audios;
  }

  JSONArray getUsers () {
    return users;
  }
}