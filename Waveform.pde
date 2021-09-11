class WaveForm {
  // full audio data, to draw waveform
  ArrayList<Float> curData = new ArrayList<Float>();
  // data with half the amout of data, since we only need one side of the waveform
  ArrayList<Float> curData2 = new ArrayList<Float>();
  // for next loaded audio
  
  // full audio data, to draw waveform
  ArrayList<Float> nextData = new ArrayList<Float>();
  // data with half the amout of data, since we only need one side of the waveform
  ArrayList<Float> nextData2 = new ArrayList<Float>();
  
  JSONArray values;
  float[] bars = new float[maxNumVoices];
  int h = 50;
  int curTime = 0;
  float curValue = 0; 
  float targetValue = 0;
  int curRange = 0;
  int curBar = 0;
  int framecount = 0;
  // PGraphics wavecanvas;
  WaveForm(int _h) {
    h = _h;
    for (int i = 0; i < maxNumVoices; i++) {
      bars[i] = (1.0 / maxNumVoices) * i;
    }
    framecount = startInterval;
  }
  
  void loadDataChunk(int index, OscMessage theOscMessage) {
    if (index == 0) {
      nextData.clear();
    }
    String msg = theOscMessage.get(0).stringValue();
    String[] list = split(msg, ' ');
    int i = 0;
    for (String n : list) {
      // println(n);
      float val = Float.parseFloat(n);
      nextData.add(val);
      if (i % 2 == 0) {
        nextData2.add(val);
      }
      i++;
    }
    if (index == 3) {
      saveJson();
    }
  }
  
  void saveJson() {
    values = new JSONArray();
    for (int i = 0; i < curData.size(); i++) {
      values.setFloat(i, curData.get(i));
    }
    saveJSONArray(values, "data/waveform.json");
  }
  
  void loadJson() {
    nextData.clear();
    values = loadJSONArray("data/waveform.json");
    for (int i = 0; i < values.size(); i++) {
      float val = values.getFloat(i);
      nextData.add(val);
      if (i % 2 == 0) {
        nextData2.add(val);
      }
    }
  }
  
  void reset() {
    curTime = 0; 
    framecount = startInterval;
    targetValue = 0;
  }
  
  void start() {
    println("[waveform] start!");
    framecount = startInterval;
    curData = nextData;
    curData2 = nextData2;
  }
  
  void update() {
    if (!auto_mode) return;
    // always calculate current value
    if (auto_mode && !idle) {
      curTime = (max(framecount, 0) / fr);
      framecount += wave_speed;
      if (curTime < curData2.size()) {
        targetValue = curData2.get(curTime);
      } else {
        onEnd();
      }
      
    }
    // get curvalue with tween
    curValue = curValue + (targetValue - curValue) * 0.1;
    if (curValue < (1 / pow(10, 6))) curValue = 0;
    myChart.push("incoming", curValue);
    // find which num of voices needs to be active from curValue
    curBar = 0;
    for (int i = 0; i < bars.length; i++) {
      if (curValue > bars[i]) {
        curBar = i + 1;
      }
    }
    orchestration.setActiveVoices(curBar);
    
    // update gui 
    for (int i = 0; i < maxNumVoices; i++) {
      if (curBar > i) {
        cp5.getController("_" + i).setValue(1.0);
      } else {
        cp5.getController("_" + i).setValue(0.0);
      }
    }
    
  }
  
  void onEnd() {
    println("[waveform] onEnd!", playedNewAudio);
    reset();
    if (playedNewAudio) {
      idle = true;
      running = false;
    } else {
      startAuto();
    }
  }
  
  void curDraw() {
    //current data
    noFill();
    int x = 0;
    for (int i = 0; i < curData.size(); i++) {
      float d = curData.get(i);
      line(x, 0, x, d * h / 2);
      if (i % 2 == 0) x++; 
    }
    
    stroke(0, 255, 0);
    line(curTime, h / 2, curTime, -h / 2);
    text("current value:" + curValue, 0, -h / 2 - 40);
    text("current bar:" + curBar, 0, -h / 2 - 25);
    text("current waveform:", 0, -h / 2 - 10);
    stroke(255);
    rect(0, -h / 2, x, h);
  }
  void nextDraw() {
    //current data
    noFill();
    int x = 0;
    stroke(200);
    for (int i = 0; i < nextData.size(); i++) {
      float d = nextData.get(i);
      line(x, 0, x, d * h / 2);
      if (i % 2 == 0) x++; 
    }
    text("next waveform:", 0, -h / 2 - 10);
    stroke(255);
    rect(0, -h / 2, x, h);
  }
}