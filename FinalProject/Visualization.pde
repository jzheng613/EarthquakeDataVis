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
CheckBox checkbox1;
CheckBox checkbox2;
int controlColor = color(0, 0, 0);
int myColorBackground;
String highlightedQuake = "";
processing.data.Table countryIDs; 


// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("Significant Earthquake Database.csv", "header");
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
  
  cp5.addSlider("Earthquake Range: 1950-")
    .setPosition(100, 790)
    .setSize(500, 55)
    .setRange(1950, 2020)
    .setValue(1950)
    .setColorLabel(controlColor)
    .setColorValue(controlColor)
    .setNumberOfTickMarks(8)
    .setSliderMode(Slider.FIX)
    .showTickMarks(false)
    .snapToTickMarks(true)
    ;
    
  cp5.getController("Earthquake Range: 1950-")
    .getValueLabel()
    .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(10)
    ;
    
  cp5.getController("Earthquake Range: 1950-")
    .getCaptionLabel()
    .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(40)
    ;
    
  checkbox1 = cp5.addCheckBox("magnitudes")
                .setPosition(700, 790)
                .setSize(55, 55)
                .setItemsPerRow(4)
                .setSpacingColumn(55)
                .setSpacingRow(20)
                .addItem("7.0-7.9", 0)
                .addItem("8.0-8.9", 1)
                .addItem("9.0-10.0", 2)
                .addItem("All Magnitudes", 3)
                .setColorLabel(0)
                ;
                
  checkbox1.getValueLabel()
          .align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
          .setPaddingX(10)
          ;
          
  checkbox1.activate("All Magnitudes");
          
  //checkbox2 = cp5.addCheckBox("years")
  //      .setPosition(100, 835)
  //      .setSize(55, 55)
  //      .setItemsPerRow(2)
  //      .setSpacingColumn(225)
  //      .addItem("Show All Earthquakes Since 1950", 0)
  //      .addItem("Show Earthquakes From Past Decade", 1)
  //      .setColorLabel(0)
  //      ;
                
  //checkbox2.getValueLabel()
  //        .align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
  //        .setPaddingX(10)
  //        ;
          
  //checkbox2.activate("Show All Earthquakes Since 1950");
    
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
  
  // === LEGEND BOX THINGS ===
  float filterYear = cp5.getController("Earthquake Range: 1950-").getValue();
  int yearValue = (int) filterYear; // cast type float to int for Year
  
  // mapping circles for earthquakes for specified Year and Magnitude
  int minRadius = 15;
  int maxRadius = 40;
  minMag = TableUtils.findMinFloatInColumn(dataTable, "EQ Primary");
  maxMag = TableUtils.findMaxFloatInColumn(dataTable, "EQ Primary");
  /*float minDeaths = TableUtils.findMinFloatInColumn(dataTable2, "Earthquake : Deaths");
  float maxDeaths = TableUtils.findMaxFloatInColumn(dataTable2, "Earthquake : Deaths");*/
  color lowestMagnitudeColor = color(255, 224, 121);
  color highestMagnitudeColor = color(232, 81, 21);
  
  // filtering by magnitude
  boolean showFirst = checkbox1.getState(0);
  boolean showSecond = checkbox1.getState(1);
  boolean showThird = checkbox1.getState(2);
  boolean showAllMags = checkbox1.getState(3);
  //boolean showAllYears = checkbox2.getState(0);
  //boolean showPastDecade = checkbox2.getState(1);
  
  //if (showNone) {
  //  checkbox1.deactivate("7.0-7.9");
  //  checkbox1.deactivate("8.0-8.9");
  //  checkbox1.deactivate("9.0-10.0");
  //  checkbox1.deactivate("All Magnitudes");
  //  checkbox2.deactivate("Show Earthquakes From Past Decade");
  //  checkbox2.deactivate("Show All Earthquakes Since 1950");
  //}
  if (showAllMags) {
    checkbox1.deactivate("7.0-7.9");
    checkbox1.deactivate("8.0-8.9");
    checkbox1.deactivate("9.0-10.0");
  }
  if (showFirst && showSecond && showThird) {
    checkbox1.deactivate("7.0-7.9");
    checkbox1.deactivate("8.0-8.9");
    checkbox1.deactivate("9.0-10.0");
    checkbox1.activate("All Magnitudes");
  }
  //if (showAllYears) {
  //  checkbox2.deactivate("Show Earthquakes From Past Decade");
  //  checkbox2.activate("Show All Earthquakes Since 1950");
  //}
  //if (showPastDecade) {
  //  checkbox2.deactivate("Show All Earthquakes Since 1950");
  //  checkbox2.activate("Show Earthquakes From Past Decade");
  //}
  Hashtable<String, float[]> selectedRanges = new Hashtable<>();
  if (showFirst) {
    selectedRanges.put("A", new float[]{7.0, 7.9});
  }
  if (showSecond) {
    selectedRanges.put("B", new float[]{8.0, 8.9});
  }
  if (showThird) {
    selectedRanges.put("C", new float[]{9.0, 10.0});
  }
  if (showAllMags) {
    selectedRanges.put("A", new float[]{7.0, 7.9});
    selectedRanges.put("B", new float[]{8.0, 8.9});
    selectedRanges.put("C", new float[]{9.0, 10.0});

  }

  for (int i = 0; i < dataTable.getRowCount(); i++) {
    TableRow currentRow = dataTable.getRow(i);
    //TableRow currentRow2 = dataTable2.getRow(i);
    int currentYear = currentRow.getInt("Year");
    float currentMagnitude = currentRow.getFloat("EQ Primary");
    //println("currentMag: ", currentMagnitude);
    //float currentDeaths = currentRow2.getFloat("Earthquake : Deaths");
    
    boolean showNone = false;
    if (!showFirst && !showSecond && !showThird && !showAllMags) {
      showNone = true;
    }
    // confirming earthquake year is <= current slider max and that a magnitude box is checked
    if ((currentYear <= yearValue) && (!showNone)) {  
      for (String range : selectedRanges.keySet()) {
        float[] selectedRange = selectedRanges.get(range);
        if (currentMagnitude >= selectedRange[0] && currentMagnitude <= selectedRange[1]) {
          String place = currentRow.getString("Location name");
          //float death_01 = (currentDeaths - minDeaths) / (maxDeaths - minDeaths);
          float mag_01 = (currentMagnitude - minMag) / (maxMag - minMag);
          float radius = lerp(minRadius, maxRadius, mag_01);
          color c = lerpColorLab(lowestMagnitudeColor, highestMagnitudeColor, mag_01);
          fill(c);
          float lat2 = currentRow.getFloat("Latitude");
          float lon2 = currentRow.getFloat("Longitude");
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


  // legend box (right)
  stroke(0);
  fill(200);
  rect(1312, 0, 288, 900);
  
  // control box (bottom)
  fill(230);
  rect(0, 739, 1312, 162);
  
  fill(0);
  textSize(20);
  text("Choose Year Range:", 100, 775);
  text("Choose Earthquake Magnitude:", 700, 775);  
  
  int totalQuakes = 0;
  int total7 = 0;
  int total8 = 0;
  int total9 = 0;
  for (int i= 0; i < dataTable.getRowCount(); i++) {
    TableRow currentRow = dataTable.getRow(i);
    int currentYear = currentRow.getInt("Year");
    float currentMag = currentRow.getFloat("EQ Primary");
    if (currentYear <= yearValue) {
      totalQuakes++;
      if (currentMag < 8.0) {
        total7++;
      }
      else if (currentMag >=8.0 && currentMag < 9.0) {
        total8++;
      }
      else {
        total9++;
      }
    }
  }
  textSize(28);
  if (yearValue == 1950) {
    text("Year: 1950", 1340, 75);
    textSize(20);
    text("Total Earthquakes in " + yearValue + ": " + totalQuakes, 1340, 115);
    text("Magnitude 7.0-7.9: " + total7, 1340, 155);
    text("Magnitude 8.0-8.9: " + total8, 1340, 175);
    text("Magnitude 9.0-10.0: " + total9, 1340, 195);

  }
  else {
    text("Year: 1950-" + yearValue, 1340, 75);
    textSize(20);
    text("Total Earthquakes", 1340, 115);
    text("From 1950-" + yearValue + ": " + totalQuakes, 1340, 135);
    text("Magnitude 7.0-7.9: " + total7, 1340, 175);
    text("Magnitude 8.0-8.9: " + total8, 1340, 195);
    text("Magnitude 9.0-10.0: " + total9, 1340, 215);
  }
  
  
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
    String place = rowData.getString("Location name");
    float mag = rowData.getFloat("EQ Primary");
    float latitude = rowData.getFloat("Latitude");
    float longitude = rowData.getFloat("Longitude");
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
