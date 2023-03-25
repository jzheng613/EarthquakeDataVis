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
  
  
  TableRow first = dataTable.getRow(1); //7.86 mag at 57.09 lat, -153.48 long, in Alaska
  float lat = first.getFloat("latitude"); //Rounded to 60
  float lon = first.getFloat("longitude"); //Rounded to -160
  //System.out.println(lon);
  
  circle(lat,lon, 20);  //For first: Need the -1 bc the lon was negative 
  //What does it mean when the longitude is negative/positive? How to translate this into geomaps coordinates. 
  
// === LEGEND BOX THINGS ===
  float filterYear = cp5.getController("Earthquake Year").getValue();
  int yearValue = (int) filterYear; // cast type float to int for Year
  float magnitudeValue = cp5.getController("Earthquake Magnitude").getValue();
  fill(0);
  textSize(28);
  text("Year: " + yearValue, 1350, 75);
  text("Magnitude: " + magnitudeValue, 1350, 110);
  
  
}
