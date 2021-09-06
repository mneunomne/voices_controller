class WaveForm {
  ArrayList<Float> data = new ArrayList<Float>();
  JSONArray values;
  int h = 300;
  WaveForm (int _h) {
    // 
    h = _h;
  }

  void loadDataChunk(int index, OscMessage theOscMessage) {
    if (index == 0) {
      data.clear();
    }
    String msg = theOscMessage.get(0).stringValue();
    String[] list = split(msg, ' ');
    for (String n : list) {
      // println(n);
      float val = Float.parseFloat(n);
      data.add(val);
    }
    if (index == 3) {
      saveJson();
    }
  }

  void saveJson () {
    values = new JSONArray();
    for (int i = 0; i < data.size(); i++) {
      values.setFloat(i, data.get(i));
    }
    saveJSONArray(values, "data/waveform.json");
  }

  void loadJson () {
    data.clear();
    values = loadJSONArray("data/waveform.json");
    for (int i = 0; i < values.size(); i++) {
      data.add(values.getFloat(i));
    }
  }

  void draw () {
    stroke(255);
    noFill();
    int x = 0;
    for (float d : data) {
      line(x, 0, x, d * h/2);
      x++;
    }
    rect(0, -h/2, x, h);
  } 
}