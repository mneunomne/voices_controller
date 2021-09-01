class Archive {
  JSONArray audios;
  JSONArray users;
  Archive () {
    // loadDatabase();
  }

  void load () {
    GetRequest get = new GetRequest("https://pandemic-archive-of-voices-db.herokuapp.com/api/data");
    get.send();
    get.addHeader("Accept", "application/json");
    // println("Response Content: " +get.getContent());
    JSONObject json = parseJSONObject(get.getContent());
    audios = json.getJSONArray("audios");
    users = json.getJSONArray("users");
    println("[Archive] Loaded database with " + audios.size() + " audios");
    onArchiveLoaded();
  }

  void appendAudio (JSONObject new_audio_data) {
    audios.append(new_audio_data);
    println("[Archive] New audio data appended, with now " + audios.size() + " audios");
  }

  JSONArray getAudios () {
    return audios;
  }

  JSONArray getUsers () {
    return users;
  }
}