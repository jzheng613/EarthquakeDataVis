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
  
  // legend box (right)
  stroke(0);
  fill(200);
  rect(1312, 0, 288, 900);
  
  // control box (bottom)
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
 // TableRow first = dataTable.getRow(6); //7.86 mag at 57.09 lat, -153.48 long, in Alaska
  //float lat = first.getFloat("latitude"); 
  //System.out.println(lat);
  //float lon = first.getFloat("longitude"); 
  //System.out.println(lon);
  
//<<<<<<< Updated upstream
 
//  PVector coord = geoMap.geoToScreen(lon, lat);
  //circle(coord.x, coord.y, 20);
//=======

  fill(50, 127, 212);
  stroke(200);
  circle(lat,lon, 20);  //For first: Need the -1 bc the lon was negative 
  //What does it mean when the longitude is negative/positive? How to translate this into geomaps coordinates. 
//  circle(lon,lat, 20);  
  
//>>>>>>> Stashed changes
  
//mapping circles for all earthquakes in 1905 (hard-coded)
  int minRadius = 15;
  int maxRadius = 40;

  fill(255,0,0);
  //for (int i = 0; i < dataTable.getRowCount(); i++) { //for all years
  for (int i = 11; i < 31; i++) { 
    TableRow second = dataTable.getRow(i);
    int magnitude = second.getInt("magnitude");//NEW
    float mag_01 = (magnitude - 7) / (7.95 - 7);//NEW
    float radius = lerp(minRadius, maxRadius, mag_01);//NEW
    float lat2 = second.getFloat("latitude");
    float lon2 = second.getFloat("longitude");
    PVector coord2 = geoMap.geoToScreen(lon2, lat2);
    circle(coord2.x, coord2.y, radius);
  }
  
  
}
