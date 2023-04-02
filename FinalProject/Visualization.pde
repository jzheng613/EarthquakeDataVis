/* CSci-5609 Final Project: Global Major/ Great Earthquakes from 1950-2020
*/

// === GLOBAL DATA VARIABLES ===
import org.gicentre.geomap.*;
import controlP5.*;
import java.awt.Color;
import java.io.FileWriter;
import com.opencsv.CSVWriter;
import java.util.Dictionary;
import java.util.Hashtable;

// Raw data tables and objects
Table dataTable;
//Table dataTable2;
GeoMap geoMap;

float minMag;
float maxMag;

ControlP5 cp5;
int controlColor = color(0, 0, 0);
String highlightedQuake = "";
processing.data.Table countryIDs; 


// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("EarthquakeData.csv", "header");
  println("Location table:", dataTable.getRowCount(), "x", dataTable.getColumnCount());
  
  //dataTable2 = loadTable("Significant Earthquake Database.csv");
  //println("Location table2:", dataTable2.getRowCount(), "x", dataTable2.getColumnCount());
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
    .setNumberOfTickMarks(310)
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
    
  //Generate country IDs
  countryIDs = geoMap.getAttributeTable();
  //saveTable(countryIDs, "data/countryIDs.csv");
  String[] countries = countryIDs.getStringColumn("NAME");
  
  
  
}

void draw() {
  background(230);
  
  stroke(0,0,0);
  fill(114,114,114);
  
  geoMap.draw();
  fill(235,55,52);
  
  highlightedQuake = getUnderMouse();
  
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
  magnitudeValue = Float.parseFloat(String.format("%.2f", magnitudeValue)); // limit to two decimal places
  fill(0);
  textSize(28);
  text("Year: " + yearValue, 1340, 75);
  text("Magnitude: " + magnitudeValue, 1340, 110);
  textSize(20);
  int quakesInYear = 0;
  for (int i= 0; i < dataTable.getRowCount(); i++) {
    TableRow currentRow = dataTable.getRow(i);
    int currentYear = currentRow.getInt("year");
    if(currentYear == yearValue) {
      quakesInYear++;
    }
  }
  text("Total Earthquakes in " + yearValue + ": " + quakesInYear, 1340, 145);
  
  // mapping circles for earthquakes for specified Year and Magnitude
  int minRadius = 15;
  int maxRadius = 40;
  minMag = TableUtils.findMinFloatInColumn(dataTable, "magnitude");
  maxMag = TableUtils.findMaxFloatInColumn(dataTable, "magnitude");
  /*float minDeaths = TableUtils.findMinFloatInColumn(dataTable2, "Earthquake : Deaths");
  float maxDeaths = TableUtils.findMaxFloatInColumn(dataTable2, "Earthquake : Deaths");*/
  color lowestMagnitudeColor = color(255, 224, 121);
  color highestMagnitudeColor = color(232, 81, 21);
  
  
  for (int i = 0; i < dataTable.getRowCount(); i++) {
    TableRow currentRow = dataTable.getRow(i);
    //TableRow currentRow2 = dataTable2.getRow(i);
    int currentYear = currentRow.getInt("year");
    float currentMagnitude = currentRow.getFloat("magnitude");
    //float currentDeaths = currentRow2.getFloat("Earthquake : Deaths");
    
    
    if(currentYear == yearValue && currentMagnitude == magnitudeValue) {      
      String place = currentRow.getString("place");
      //float death_01 = (currentDeaths - minDeaths) / (maxDeaths - minDeaths);
      float mag_01 = (currentMagnitude - minMag) / (maxMag - minMag);
      float radius = lerp(minRadius, maxRadius, mag_01);
      color c = lerpColorLab(lowestMagnitudeColor, highestMagnitudeColor, mag_01);
      fill(c);
      float lat2 = currentRow.getFloat("latitude");
      float lon2 = currentRow.getFloat("longitude");
      PVector coord2 = geoMap.geoToScreen(lon2, lat2);
      
      //fill(255,0,0);
      stroke(200);

      //Details on Demand
      if(highlightedQuake.equals(place)){
       // System.out.println(geoMap.getID(mouseX, mouseY));
        
        //box by circle, can delete
        /*textSize(14);
        fill(255,255,255);
        rect(mouseX+5,mouseY-20, 300, 45);
        fill(0);
        text("Place: " + place + "\nMagnitude: " + currentMagnitude,  mouseX+10, mouseY-5);
        fill(5,250,38);*/
        
        text("Current Place: " + place + "\nCurrent Magnitude: " + currentMagnitude, 1340, 180, 250, 320);
        textSize(20);
      }
      circle(coord2.x, coord2.y, radius);
      //fill(255,0,0);
    }
  }
  
  
// leaving for now, can we erase this? 
//    //Details on Demand
//    if(highlightedQuake.equals(place)){
//      System.out.println(place);
//      textSize(14);
//      fill(255,255,255);
//      rect(mouseX+5,mouseY-20, 300, 45);
//      fill(0);
//      text("Place: " + place + "\nMagnitude: " + magnitude,  mouseX+10, mouseY-5);
//      fill(5,250,38);
//    }
//    circle(coord2.x, coord2.y, radius);
//    fill(255,0,0);
//  }
  
  
}

float getRadius (float mag){
  int minRadius = 15;
  int maxRadius = 40;
  mag = (mag-minMag)/(maxMag-minMag);
  return lerp(minRadius, maxRadius, mag);
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
