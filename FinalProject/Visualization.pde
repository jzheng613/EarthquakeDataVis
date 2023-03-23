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
//HI THISIS A CHANGE
import org.gicentre.geomap.*;

// Raw data tables and objects
Table dataTable;
PImage img;
GeoMap geoMap;

// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("EarthquakeData.csv", "header");
  println("Location table:", dataTable.getRowCount(), "x", dataTable.getColumnCount()); 
}

void setup() {
  size(1600,900);
  img = loadImage("earth.png");
  loadRawDataTables();
  
  geoMap = new GeoMap(this);
  geoMap.readFile("world");
}

void draw() {
  background(230);
  
  stroke(0,0,0);
  fill(114,114,114);
  
  geoMap.draw();
  //image(img, 0, 0);
  
  fill(235,55,52);
  
  TableRow first = dataTable.getRow(1); //7.86 mag at 57.09 lat, -153.48 long, in Alaska
  float lat = first.getFloat("latitude"); //Rounded to 60
  float lon = first.getFloat("longitude"); //Rounded to -160
  //System.out.println(lon);
  
  circle(lat,lon, 20);  //For first: Need the -1 bc the lon was negative 
  //What does it mean when the longitude is negative/positive? How to translate this into geomaps coordinates. 
  
}
