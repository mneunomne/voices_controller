class Word {
  String source_path = "C:/Users/mneunomne/archive_folder_sync/texts/";
  String dest_path = "data/points/";
  JSONObject audio;
  String audio_id;
  String user_id;
  int img_w;
  int img_h;

  Word (JSONObject audio) {
    audio_id = audio.getString("id");
    user_id = audio.getString("user_id");
  }

  void load () {
    // load svg
    String filepath = source_path + audio_id + ".svg";
    File f = dataFile(filepath);
    boolean exist = f.isFile();
    // dont continue if file already exists
    if (!exist) return;
    println("filepath", filepath, exist);
    // load svg image
    PShape svg;
    svg = loadShape(filepath);
    img_w = int(svg.width);
    img_h = int(svg.height);

    // save json file
    saveJSON(getPoints(svg));
  }

  ArrayList<PVector> getPoints (PShape svg) {
    ArrayList<PVector> points = new ArrayList<PVector>();
    // create points
    PGraphics pg;
    println("[Word] size", img_w, img_h);
    pg = createGraphics(img_w, img_h);
    pg.beginDraw();
    pg.background(255);
    pg.stroke(0);
    pg.stroke(0);
    pg.shape(svg, 0, 0);
    pg.endDraw();
    pg.loadPixels();
    for(int x = 0; x < img_w; x++) {
      for(int y = 0; y < img_h; y++) {
        int index = y * img_w + x;
        color c= pg.pixels[index];
        if (brightness(c) < 50) {
          points.add(new PVector(x, y));
        }
      }
    }
    return points;
  }

  void saveJSON (ArrayList<PVector> points) {
    println("points", points.size());
    JSONObject obj = new JSONObject();
    JSONArray array = new JSONArray();
    for (int i = 0; i < points.size(); i++) {
      JSONObject pos = new JSONObject();
      pos.setFloat("x", points.get(i).x);
      pos.setFloat("y", points.get(i).y);
      array.setJSONObject(i, pos);
    }
    obj.setInt("width", img_w);
    obj.setInt("height", img_h);
    obj.setJSONArray("points", array);
    saveJSONObject(obj, dest_path + audio_id + ".json");
    // saveJSONArray(array, dest_path + audio_id + ".json");
    println("[Word] saved " + audio_id + ".json");
  }
}