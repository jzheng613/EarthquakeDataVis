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
import java.lang.Math;
import java.text.NumberFormat;

// Raw data tables and objects
Table dataTable;
GeoMap geoMap;

float minMag;
float maxMag;

ControlP5 cp5;
CheckBox checkbox1;
Toggle toggle1;
String highlightedQuake = "";


Table countryIDs; 
Table cumDeaths;
String[] countries;
int minDeaths;
int maxDeaths;
int tempMin;
int tempMax;
ColorMap countriesScale;
double[] colorMapControlPts = new double[21];


// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("Significant Earthquake Database.csv", "header");
  println("Location table:", dataTable.getRowCount(), "x", dataTable.getColumnCount());
  tempMax = TableUtils.findMaxIntInColumn(dataTable, "Earthquake : Deaths");
  tempMin = TableUtils.findMinIntInColumn(dataTable, "Earthquake : Deaths");
  
  cumDeaths = loadTable("CumDeathsbyCountry.csv", "header");
  maxDeaths = TableUtils.findMaxIntInColumn(cumDeaths, "CumulDeaths");
  minDeaths = TableUtils.findMinIntInColumn(cumDeaths, "CumulDeaths");
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
    .setPosition(50, 790)
    .setSize(400, 55)
    .setRange(1950, 2020)
    .setValue(1950)
    .setColorLabel(color(0, 0, 0))
    .setColorValue(color(0, 0, 0))
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
                .setPosition(525, 790)
                .setSize(55, 55)
                .setItemsPerRow(4)
                .setSpacingColumn(55)
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
              
  //Generate country IDs
  countryIDs = geoMap.getAttributeTable();
  //saveTable(countryIDs, "data/countryIDs.csv");
  countries = countryIDs.getStringColumn("NAME");
 // countriesScale =  new ColorMap("div3-green-brown-div.xml"); 
  
  countriesScale =  new ColorMap("div3-green-brown-div (1).xml"); //original colormap
  colorMapControlPts = new double[] {0.0,0.000002,0.00008,0.0002,0.0007,0.0019,0.0023,0.0045,0.008,0.011,
                                     0.0138,0.022,0.027,0.041,0.071,0.185,0.212,0.246,0.56,0.8739,1.0};
                                     
  //smooth();
  toggle1 = cp5.addToggle("earthquake info | death info")
     .setPosition(1030, 790)
     .setSize(140, 55)
     .setColorLabel(0)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     ;
}

void draw() {
  background(230);
  
  stroke(0,0,0);
  
  highlightedQuake = getUnderMouse();  
  
  // === LEGEND BOX THINGS ===
  float filterYear = cp5.getController("Earthquake Range: 1950-").getValue();
  int yearValue = (int) filterYear; // cast type float to int for Year
        
  // filtering by magnitude
  boolean showFirst = checkbox1.getState(0);
  boolean showSecond = checkbox1.getState(1);
  boolean showThird = checkbox1.getState(2);
  boolean showAllMags = checkbox1.getState(3);
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
  if (showFirst) {    
    checkbox1.setColorActive(color(255, 219, 83));
  }
  if (showSecond) {    
    checkbox1.setColorActive(color(255, 142, 39));
  }
  if (showThird) {    
    checkbox1.setColorActive(color(253, 74, 0));
  }
  if (showAllMags) {
    checkbox1.setColorActive(color(0, 152, 255));
  }
  
  // === TOGGLING THE MAP TO SHOW EARTHQUAKE OR DEATH ===
    
  if (toggle1.getState()) {
    fill(0);
    text("TRUE ON", 1030, 885);
    
    fill(169, 182, 170);
    //fill(255,255,220);
    stroke(1);
    geoMap.draw();
    
    // === DRAWING OUT EACH EARTHQUAKE CIRCLE ===
    int minRadius = 15;
    int maxRadius = 30;
    int minRadius2 = 31;
    int maxRadius2 = 40;
    
    minMag = TableUtils.findMinFloatInColumn(dataTable, "EQ Primary");
    maxMag = TableUtils.findMaxFloatInColumn(dataTable, "EQ Primary");
    color lowestMagnitudeColor = color(255, 224, 121);
    color highestMagnitudeColor = color(232, 81, 21);
  
    for (int i = 0; i < dataTable.getRowCount(); i++) {
      TableRow currentRow = dataTable.getRow(i);
      int currentYear = currentRow.getInt("Year");
      float currentMagnitude = currentRow.getFloat("EQ Primary");
      int currentDeaths = currentRow.getInt("Earthquake : Deaths");
      boolean showNone = false;
      if (!showFirst && !showSecond && !showThird && !showAllMags) {
        showNone = true;
      }
      //confirming earthquake year is <= current slider max and that a magnitude box is checked    
      if ((currentYear <= yearValue) && (!showNone)) {  
        for (String range : selectedRanges.keySet()) {
          float radius;
          float[] selectedRange = selectedRanges.get(range);
          if (currentMagnitude >= selectedRange[0] && currentMagnitude <= selectedRange[1]) {
            //min=0 and max=5,000
            float death_01 = (float(currentDeaths) - float(0)) / (float(5000) - float(0));
            //min=5,001 and max=316,000
            float death_02 = (float(currentDeaths) - float(5001)) / (float(320000) - float(5001));
            float mag_01 = (currentMagnitude - minMag) / (maxMag - minMag);
            
            if (currentDeaths < 5001) {
              radius = lerp(minRadius, maxRadius, death_01);
            }
            else {
              radius = lerp(minRadius2, maxRadius2, death_02);
            }
            
            color c = lerpColorLab(lowestMagnitudeColor, highestMagnitudeColor, mag_01);
            float lat2 = currentRow.getFloat("Latitude");
            float lon2 = currentRow.getFloat("Longitude");
            PVector coord2 = geoMap.geoToScreen(lon2, lat2);
            
            // current year range's earthquakes are highlighted
            if ((currentYear == yearValue) | (currentYear > yearValue-10)) {
              stroke(0);
              strokeWeight(2);
              fill(c);
            }
            else {
              stroke(200);
              fill(c);
            }
            circle(coord2.x, coord2.y, radius);
          }
        }
      }
    }
    
    // drawing right legend box
    stroke(0);
    fill(224, 224, 224);
    rect(1312, 0, 288, 900);
    
    
    
    // === DETAILS ON DEMAND FOR EACH EARTHQUAKE ===
    stroke(0);
    fill(0);
    textSize(23);
    text("Earthquake Details", 1340, 170);
    textSize(16);
    text("Place:", 1340, 200);
    text("Magnitude:", 1340, 230);
    text("Deaths:", 1340, 260);
    text("Date:", 1340, 290);
    for (int i = 0; i < dataTable.getRowCount(); i++) {
      TableRow currentRow = dataTable.getRow(i);
      int currentYear = currentRow.getInt("Year");
      float currentMagnitude = currentRow.getFloat("EQ Primary");
      String currentDeaths = currentRow.getString("Earthquake : Deaths");
      int dateMonth = currentRow.getInt("Month");
      int dateDay = currentRow.getInt("Day");
      int dateYear = currentRow.getInt("Year");
      boolean showNone = false;
      if (!showFirst && !showSecond && !showThird && !showAllMags) {
        showNone = true;
      }
      // confirming earthquake year is <= current slider max and that a magnitude box is checked
      if ((currentYear <= yearValue) && (!showNone)) {  
        for (String range : selectedRanges.keySet()) {
          float[] selectedRange = selectedRanges.get(range);
          if (currentMagnitude >= selectedRange[0] && currentMagnitude <= selectedRange[1]) {
          // Details on Demand
            String place = currentRow.getString("Country");
            if(highlightedQuake.equals(place)){
              textSize(19);
              text(place, 1385, 200);
              text(currentMagnitude, 1415, 230);
              text(dateMonth + "/" + dateDay + "/" + dateYear, 1378, 290);
              
              if (currentDeaths.isEmpty()) {
                text("Unknown", 1395, 260);
              }
              else {
                int deaths = Integer.parseInt(currentDeaths);
                text(deaths, 1395, 260);
              }
            }
          }
        }
      }
    }
    
    
    // === EARTHQUAKE CIRCLE SIZE LEGEND ===
    textSize(23);
    text("Earthquake Death Count", 1340, 340);
    noStroke();
    int nExamples = 6;
    float y = 345;
    for (int i=0; i<nExamples; i++) {
      float amt = 1.0 - (float)i/(nExamples - 1);
      float radius = lerp(minRadius, maxRadius2, amt);
      fill(50);
      circle(1360, y+30, radius);
      int labelValue = (int)(minDeaths + amt*(maxDeaths - minDeaths));
      fill(0);
      text(labelValue, 1395, y+35);
      y += (1.4 * radius);//maxIslandRadius;
    }  
    
    
    // === EARTHQUAKE MAGNITUDE COLOR LEGEND ===
    textSize(23);
    fill(0);
    text("Magnitude", 1340, 635);
    strokeWeight(1);
    int cGradientHeight = 200;
    int cGradientWidth = 40;
    int labelStep = cGradientHeight / 5;
    for (int j=0; j<cGradientHeight; j++) {
      float amt = 1.0 - (float)j/(cGradientHeight-1);
      color c = lerpColorLab(lowestMagnitudeColor, highestMagnitudeColor, amt);
      stroke(c);
      line(1345, 660 + j, 1345+cGradientWidth, 660 + j);
      if ((j % labelStep == 0) || (j == cGradientHeight-1)) {
        float labelValue = (float)(minMag + amt*(maxMag - minMag));
        textSize(18);
        text(labelValue, 1400, 665 + j);
      }
    }
  } 
  
  
  else {
    // drawing right legend box
    stroke(0);
    fill(224, 224, 224);
    rect(1312, 0, 288, 900);
    
    cumDeathbyYear(yearValue); //Includes draw command
    
    // === CUMULATIVE DEATH COUNT LEGEND ===
    fill(0);
    stroke(1);
    textSize(22);
    text("Cumulative Deaths", 1340, 500);
    text("For Countries", 1340, 525);
    strokeWeight(1);
    int gradientWidth = 80;
    int count = 0;
    for(int x = 0; x < colorMapControlPts.length; x++){
      double amt = colorMapControlPts[x];
      color c = countriesScale.lookupColor((float)amt);
      stroke(c);
      fill(c);
      rect(1340, 550 + 15*x, gradientWidth, 15);
      count +=15;
      long labelValue = Math.round(colorMapControlPts[x]*361569);
      textSize(12);
      fill(0);
      text(NumberFormat.getInstance().format((int)labelValue), 1440, 545 + count);
    }
  }  
  
  // === TOTAL EARTHQUAKE INFO ===
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
  textSize(23);
  fill(0);
  text("Total Earthquakes: " + totalQuakes, 1340, 50);
  textSize(20);
  text("Magnitude 7.0-7.9: " + total7, 1340, 80);
  text("Magnitude 8.0-8.9: " + total8, 1340, 100);
  text("Magnitude 9.0-10.0: " + total9, 1340, 120);
    
    
  
  // control box (bottom)
  fill(224, 224, 224);
  stroke(0);
  rect(0, 739, 1312, 162);
  
  fill(0);
  textSize(25);
  text("Year Range: 1950-" + yearValue, 50, 775);
  text("Filter By Magnitude:", 525, 775);  
  text("Toggle Map:", 1030, 775);

  
}

float getMag(String placeName) {
  TableRow rowData = dataTable.findRow(placeName, "Country");
  float mag = rowData.getFloat("EQ Primary");
  float mag_01 = (mag-minMag)/(maxMag-minMag);
  return mag_01;
}

float getRadius (String placeName){
  int minRadius = 15;
  int maxRadius = 40;
  float mag = getMag(placeName);
  return lerp(minRadius, maxRadius, mag);
}

String getUnderMouse() {
  float smallestRadiusSquared = Float.MAX_VALUE;
  String underMouse = "";
  for (int i=0; i<dataTable.getRowCount(); i++) {
    TableRow rowData = dataTable.getRow(i);
    String place = rowData.getString("Country");
    float latitude = rowData.getFloat("Latitude");
    float longitude = rowData.getFloat("Longitude");
    PVector screenXY = geoMap.geoToScreen(longitude,latitude);
    float screenX = screenXY.x;
    float screenY = screenXY.y;
    float distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
    float radius = getRadius(place);
    float radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse = place;
      smallestRadiusSquared = radiusSquared;
    }
  }
  return underMouse;  
}

void cumDeathbyYear(int year){
  TableRow row;
  int deaths;
  int ID;
  float lerpedDeaths;
  int firstRow = 242*(year-1950);
  
  for(int i = 0; i<countries.length;i++){
   row = cumDeaths.getRow(firstRow+i);
   
   deaths = row.getInt("CumulDeaths");
   lerpedDeaths = (float(deaths)-float(minDeaths))/(float(maxDeaths)-float(minDeaths));
   ID = countryIDs.getRow(i).getInt("id");
   
   fill(countriesScale.lookupColor(lerpedDeaths));
   stroke(1);
   geoMap.draw(ID);
  }
}
