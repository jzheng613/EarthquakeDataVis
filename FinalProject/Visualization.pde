/* CSci-5609 Final Project: Global Major/ Great Earthquakes from 1900-2023
*/

// === GLOBAL DATA VARIABLES ===

// Raw data tables and objects
Table dataTable;
PImage img;

// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("EarthquakeData.csv", "header");
  println("Location table:", dataTable.getRowCount(), "x", dataTable.getColumnCount()); 
  
}

void setup() {
  size(1600,900);
  img = loadImage("earth.png");
  loadRawDataTables();
}

void draw() {
  background(230);
  image(img, 0, 0);
}
