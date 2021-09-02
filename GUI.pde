public class Gui {

  int padding = 10;
  int label_padding_top = 10;
  int label_padding_right = 80;
  Gui () {
    // 
  }

  void init () {
    setup_movement();
    setup_voices();
    setup_general();
  }

  void setup_movement () {
    int w = 582;
    int py = w + padding + label_padding_top;
    int px = padding;
    int group_width = w - (padding * 2);
    int group_height = height - w - padding * 2 - label_padding_top;
    int cp_width = group_width - (padding * 2) - label_padding_right;
    int cp_height = 32;

    Group group = cp5.addGroup("movement")
      .setWidth(group_width)
      .setPosition(px,py)
      .setBackgroundHeight(group_height)
      .setBackgroundColor(color(255,25))
      .disableCollapse()
      ;
    px = padding;
    py = padding;
    cp5.addRange("radius")
     .setPosition(px,py)
     .setSize(cp_width,cp_height)
     .setHandleSize(10)
     .setRange(0,1)
     .setRangeValues(0, 1)
     .setGroup(group)
     ;
    py+= cp_height + padding; 
    // angle velocity slider
    cp5.addSlider("angle_vel")
      .setPosition(px,py)
      .setSize(cp_width,cp_height)
      .setValue(10)
      .setRange(1, 500)
      .setGroup(group)
      ;
    py+= cp_height + padding; 
    // radius velocity slider
    cp5.addSlider("radius_vel")
      .setPosition(px,py)
      .setSize(cp_width,cp_height)
      .setValue(10)  
      .setRange(1, 500)
      .setGroup(group)
     ;
  }

  void setup_voices () {
    int w = 306;
    int px = 582 + padding;
    int group_width = w - (padding * 2);
    int group_height = (height / 8) - padding * 2;
    int cp_width = group_width - (padding * 2) - label_padding_right;
    int cp_height = 10;
    for (int i = 0; i < maxNumVoices; i++) {
      int py = padding + (group_height + padding + label_padding_top ) * i + label_padding_top; 
      Group group = cp5.addGroup("voice_" + i)
        .setWidth(group_width)
        .setPosition(px,py)
        .setBackgroundHeight(group_height)
        .setBackgroundColor(color(255,25))
        .disableCollapse()
        ;
      int padding_right = 35;
      int fx_y = padding;
      int fx_x = padding_right + padding;
      cp5.addSlider("reverb_" + i)
        .setPosition(fx_x,fx_y)
        .setSize(cp_width,cp_height)
        .setRange(0, 1)
        .setValue(0.5)
        .setGroup(group)
        ;
      fx_y+=cp_height+padding;
      cp5.addSlider("filter_" + i)
        .setPosition(fx_x,fx_y)
        .setSize(cp_width,cp_height)
        .setRange(0, 1)
        .setValue(0.5)
        .setGroup(group)
        ;
      fx_y+=cp_height+padding;
      cp5.addSlider("echo_" + i)
        .setPosition(fx_x,fx_y)
        .setSize(cp_width,cp_height)
        .setRange(0, 1)
        .setValue(0.5)
        .setGroup(group)
        ;
      fx_y+=cp_height+padding;
      cp5.addSlider("bit_" + i)
        .setPosition(fx_x,fx_y)
        .setSize(cp_width,cp_height)
        .setRange(0, 1)
        .setValue(0.5)
        .setGroup(group)
        ;
    }
  }

  void setup_general () {
    int width = 306;
  }

  void draw () {
    pg.beginDraw();
    pg.background(25);
    pg.ellipseMode(RADIUS);
    pg.noFill();
    if (dbLoaded) {
      // translate to center
      pg.translate(pg.width/2, pg.height/2);
      // min/max radius
      pg.stroke(255, 0, 0);
      pg.ellipse(0, 0, maxRadius * debug_scale, maxRadius * debug_scale);
      pg.ellipse(0, 0, minRadius * debug_scale, minRadius * debug_scale);
      // projection radius
      pg.stroke(0, 0, 255);
      pg.ellipse(0, 0, projection_radius * debug_scale, projection_radius * debug_scale);
      // draw moving circles
      pg.stroke(255);
      for (NoiseCircularWalker walker : walkers) {
        walker.draw(pg);
      }
    }
    pg.endDraw();
    image(pg, padding, padding); 
  }

}