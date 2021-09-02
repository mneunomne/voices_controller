class Word {
  PGraphics pg;
  PShape svg;
  String path = "texts/";
  JSONObject audio;
  String audio_id;
  String user_id;
  int img_w;
  int img_h;

  ArrayList<PVector> points = new ArrayList<PVector>();

  Word (JSONObject _audio) {
    audio_id = audio.getString("id");
    user_id = audio.getString("user_id");
    loadSvg();
  }

  void loadSvg () {
    // load svg
    String filepath = path + id + ".svg";
    File f = dataFile(filepath);
    boolean exist = f.isFile();
    // dont continue if file already exists
    if (exists) return;
    svg = loadShape(filepath)
    img_w = int(svg.width);
    img_h = int(svg.height);
    createPoints();
  }

  void createPoints () {
    // create points
    PGraphics pg;
    pg = createGraphics(img_w, img_h, P2D);
    pg.beginDraw();
    pg.shape(svg, 0, 0);
    pg.endDraw();
    pg.loadPixels();
    for(int x = 0; x < img_w; x++) {
      for(int y = 0; y < img_h; y++) {
        int index = y * img_w + x;
        color c= pg.pixels[index];
        if (brightness(c) > 50) {
          points.add(new PVector(x, y));
        }
      }
    }
    // save json file
    saveJSON();
  }

  void saveJSON () {
    JSONArray array = new JSONArray();
    for (int i = 0; i < points.size(); i++) {
      JSONObject pos = new JSONObject();
      pos.setFloat("x", points.get(i).x);
      pos.setFloat("y", points.get(i).y);
      array.setJSONObject(i, pos);
    }
    saveJSONArray(values, "points/" + id + ".json");
    println("[Word] saved " + id + ".json")
  }
}