class WaveForm {
  // full audio data, to draw waveform
  ArrayList<Float> data = new ArrayList<Float>();
  // data with half the amout of data, since we only need one side of the waveform
  ArrayList<Float> data2 = new ArrayList<Float>();
  
  JSONArray values;
  float[] bars = new float[maxNumVoices];
  int h = 50;
  int curTime = 0;
  float curValue = 0; 
  float targetValue = 0;
  int curRange = 0;
  int curBar = 0;
  int framecount = 0;
  boolean started_after_delay = false;
  // PGraphics wavecanvas;
  WaveForm(int _h) {
    h = _h;
    // make calculation of what range of value translate to the number of voices playing at the same time
    for (int i = 0; i < maxNumVoices; i++) {
      bars[i] = (0.8 / maxNumVoices) * i;
    }
    framecount = int(cp5.getController("set_start_delay").getValue());
  }

  // data incoming from Max needs to be loaded in chunks because of osc message size limitation
  void loadDataChunk(int index, OscMessage theOscMessage) {
    if (index == 0) {
      data.clear();
      data2.clear();
    }
    String msg = theOscMessage.get(0).stringValue();
    String[] list = split(msg, ' ');
    int i = 0;
    for (String n : list) {
      // println(n);
      float val = Float.parseFloat(n);
      data.add(val);
      if (i % 2 == 0) {
        data2.add(val);
      }
      i++;
    }
    if (index == 3) {
      saveJson();
    }
  }
  
  void saveJson() {
    values = new JSONArray();
    for (int i = 0; i < data.size(); i++) {
      values.setFloat(i, data.get(i));
    }
    saveJSONArray(values, "data/waveform.json");
    loadedNewWaveform();
  }
  
  void loadJson() {
    data.clear();
    values = loadJSONArray("data/waveform.json");
    for (int i = 0; i < values.size(); i++) {
      float val = values.getFloat(i);
      data.add(val);
      if (i % 2 == 0) {
        data2.add(val);
      }
    }
  }
  
  void reset() {
    println("[waveform] reset!");
    curTime = 0; 
    framecount = startDelay;
    targetValue = 0;
    started_after_delay = false;
  }
  
  void start() {
    println("[waveform] start!");
    framecount = startDelay;
  }

  void start_after_delay () {
    println("[waveform] start_after_delay!");
    started_after_delay = true;
    oscController.sendOscStart();
  }
  
  void update() {
    if (!auto_mode) return;
    // always calculate current value
    if (auto_mode && !idle) {
      curTime = (max(framecount, 0) / fr);
      framecount += wave_speed;
      // run event for when it starts after delay... only once
      if (framecount > 0 && !started_after_delay) {
        start_after_delay();
      }
      if (curTime < data2.size()) {
        targetValue = data2.get(curTime);
      } else {
        onEnd();
      }
    }
    // get curvalue with tween
    curValue = curValue + (targetValue - curValue) * 0.1;
    // (1 / pow(10, 10))
    if (curValue < (1 / pow(10, 6))) curValue = 0;
    myChart.push("incoming", curValue);
    // find which num of voices needs to be active from curValue
    curBar = 0;
    for (int i = 0; i < bars.length; i++) {
      if (curValue >= bars[i]) {
        curBar = i + 1;
      }
    }
    // if idle mode, really make zero if thats the case
    if (idle || framecount < 0) {
      curBar = curBar - 1;
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
    if (loop) {
      startAuto();
    } else {
      idle = true;
      running = false;
    }
  }
  
  void curDraw() {
    //current data
    noFill();
    int x = 0;
    for (int i = 0; i < data.size(); i++) {
      float d = data.get(i);
      line(x, 0, x, d * h / 2);
      if (i % 2 == 0) x++; 
    }
    
    stroke(0, 255, 0);
    line(curTime, h / 2, curTime, -h / 2);
    text("current framecount:" + framecount, 0, -h / 2 - 55);
    text("current value:" + curValue, 0, -h / 2 - 40);
    text("current bar:" + curBar, 0, -h / 2 - 25);
    text("current waveform:", 0, -h / 2 - 10);
    stroke(255);
    rect(0, -h / 2, x, h);
  }
}