/* CSci-5609 Final Project: Global Major/ Great Earthquakes from 1900-2023
*/

// === GLOBAL DATA VARIABLES ===

/*Imports 
If it doesn't work automatically: see 
https://discourse.processing.org/t/why-wont-processing-find-my-library/1483
https://www.gicentre.net/geomap/using

You may need to: drag .jar file (in geoMap libraries folder) and world.dhp/shp files onto the sketch; add jar file or geomap file to your libraries folder in processing
I'm not sure what combination of these allowed this to run
*/
import org.gicentre.geomap.*;
import controlP5.*;
import java.awt.Color;

// Raw data tables and objects
Table dataTable;
GeoMap geoMap;

ControlP5 cp5;
int controlColor = color(0, 0, 0);

String highlightedQuake = "";

// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("EarthquakeData.csv", "header");
  println("Location table:", dataTable.getRowCount(), "x", dataTable.getColumnCount()); 
}

void setup() {
  // screen size setup
  size(1600,900);
  
  // load up data info
  loadRawDataTables();
  
  // create world map, scaled size
  geoMap = new GeoMap(0, 0, 1312, 738, this);
  geoMap.readFile("world");
  
// === SLIDER SETUP ===
  cp5 = new ControlP5(this);
  
  cp5.addSlider("Earthquake Year")
    .setPosition(100, 760)
    .setSize(500, 55)
    .setRange(1900, 2023)
    .setValue(1900)
    .setColorLabel(controlColor)
    .setColorValue(controlColor)
    .setNumberOfTickMarks(124)
    .setSliderMode(Slider.FLEXIBLE)
    .showTickMarks(false)
    .snapToTickMarks(true)
    ;
    
  cp5.getController("Earthquake Year")
    .getValueLabel()
    .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(10)
    ;
    
  cp5.getController("Earthquake Year")
    .getCaptionLabel()
    .align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(10)
    ;
  
  cp5.addSlider("Earthquake Magnitude")
    .setPosition(700, 760)
    .setSize(250, 55)
    .setRange(7.0, 10.0)
    .setValue(7.0)
    .setColorLabel(controlColor)
    .setColorValue(controlColor)
    .setNumberOfTickMarks(31)
    .setSliderMode(Slider.FLEXIBLE)
    .showTickMarks(false)
    .snapToTickMarks(true)
    ;
    
  cp5.getController("Earthquake Magnitude")
    .getValueLabel()
    .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(10)
    ;
  cp5.getController("Earthquake Magnitude")
    .getCaptionLabel()
    .align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(10)
    ;
}

void draw() {
  background(230);
  
  stroke(0,0,0);
  fill(114,114,114);
  
  geoMap.draw();
  fill(235,55,52);
  
  // drawing legend box (right)
  stroke(0);
  fill(200);
  rect(1312, 0, 288, 900);
  
  // drawing control box (bottom)
  fill(230);
  rect(0, 739, 1312, 162);
  
  // === LEGEND BOX THINGS ===
  float filterYear = cp5.getController("Earthquake Year").getValue();
  int yearValue = (int) filterYear; // cast type float to int for Year
  float magnitudeValue = cp5.getController("Earthquake Magnitude").getValue();
  fill(0);
  textSize(28);
  text("Year: " + yearValue, 1350, 75);
  text("Magnitude: " + magnitudeValue, 1350, 110);
  
  //getting data from CSV
  //TableRow first = dataTable.getRow(6); //7.86 mag at 57.09 lat, -153.48 long, in Alaska
  //float lat = first.getFloat("latitude"); 
  //System.out.println(lat);
  //float lon = first.getFloat("longitude"); 
  //System.out.println(lon);
   
//  PVector coord = geoMap.geoToScreen(lon, lat);
  //circle(coord.x, coord.y, 20);
  
  // mapping circles for all earthquakes in 1905 (hard-coded)
  int minRadius = 15;
  int maxRadius = 40;

   fill(255,0,0);
   stroke(200);
  // for (int i = 0; i < dataTable.getRowCount(); i++) { //for all years
  for (int i = 11; i < 31; i++) { 
    TableRow second = dataTable.getRow(i);
    float magnitude = second.getFloat("magnitude");
    String place = second.getString("place");
    float mag = second.getFloat("magnitude");
    float mag_01 = (magnitude - 7) / (7.95 - 7);
    float radius = lerp(minRadius, maxRadius, mag_01);
    float lat2 = second.getFloat("latitude");
    float lon2 = second.getFloat("longitude");
    PVector coord2 = geoMap.geoToScreen(lon2, lat2);
    
    //Details on Demand
    if(highlightedQuake.equals(place)){
      System.out.println(place);
      textSize(14);
      fill(255,255,255);
      rect(mouseX+5,mouseY-20, 300, 45);
      fill(0);
      text("Place: " + place + "\nMagnitude: " + mag,  mouseX+10, mouseY-5);
      fill(5,250,38);
    }
    circle(coord2.x, coord2.y, radius);
    fill(255,0,0);
  }

}

//Implementing Details on Demand
//Revised from Keefe's Paafu code

float getRadius (float mag){
  int minRadius = 15;
  int maxRadius = 40;
  mag = (mag-7)/(7.95-7);
  float radius = lerp(minRadius, maxRadius, mag);
  return radius;
}

String getUnderMouse() {
  float smallestRadiusSquared = Float.MAX_VALUE;
  String underMouse = "";
  for (int i=0; i<dataTable.getRowCount(); i++) {
    TableRow rowData = dataTable.getRow(i);
    String place = rowData.getString("place");
    float mag = rowData.getFloat("magnitude");
    float latitude = rowData.getFloat("latitude");
    float longitude = rowData.getFloat("longitude");
    PVector screenXY = geoMap.geoToScreen(longitude,latitude);
    float screenX = screenXY.x;
    float screenY = screenXY.y;
    float distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
    float radius = getRadius(mag);
    float radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse = place;
      smallestRadiusSquared = radiusSquared;
    }
  }
  return underMouse;  
}
