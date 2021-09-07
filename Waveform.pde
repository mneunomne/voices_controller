class WaveForm {
  ArrayList<Float> data = new ArrayList<Float>();
  JSONArray values;
  float [] bars = new float [maxNumVoices];
  int h = 50;
  int framecount = 0;
  int curtime = 0;
  float curValue = 0; 
  int curRange = 0; 
  // PGraphics wavecanvas;
  WaveForm (int _h) {
    h = _h;
    for (int i = 0; i < maxNumVoices; i++) {
      bars[i] = (1.0/maxNumVoices) * i;
    }
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

  void update () {
    curtime = (framecount/fr) % (data.size()-1);
    framecount+=10;
    float value = data.get(curtime);
    myChart.push("incoming", value); 
    int curbar = 0;
    for (int i = 0; i < bars.length; i++) {
      if (abs(value) >= bars[i]) {
        curbar = i;
      }
    }
    orchestration.setActiveVoices(curbar+1);
    // update gui
    for (int i = 0; i < maxNumVoices; i++) {
      if (curbar >= i) {
        cp5.getController("_" + i).setValue(1.0);
      } else {
        cp5.getController("_" + i).setValue(0.0);
      }
    }
    // rintln("curbar", curbar);
    // curValue = data.get()
  }

  void draw () {
    noFill();
    int x = 0;
    stroke(255);
    rect(0, -h/2, x, h);
    for (int i = 0; i < data.size(); i++) {
      float d = data.get(i);
      line(x, 0, x, d * h/2);
      if (i % 2 == 0) x++;
    }

    stroke(0, 255, 0);
    line(curtime/2, h/2, curtime/2, -h/2);

    stroke(255,0,0);
    for (int i = 0; i < bars.length; i++) {
      line(0, bars[i] * h/2, x, bars[i] * h/2);
      line(0, bars[i] * -h/2, x, bars[i] * -h/2);
    }
  } 
}