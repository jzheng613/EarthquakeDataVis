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
CheckBox checkbox2;
int controlColor = color(0, 0, 0);
int myColorBackground;
String highlightedQuake = "";


Table countryIDs; 
Table cumDeaths;
String[] countries;
int minDeaths;
int maxDeaths;
ColorMap countriesScale;
double[] colorMapControlPts = new double[21];


// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("Significant Earthquake Database.csv", "header");
  println("Location table:", dataTable.getRowCount(), "x", dataTable.getColumnCount());
  
  cumDeaths = loadTable("CumDeathsbyCountry.csv", "header");
  maxDeaths = int(TableUtils.findMaxFloatInColumn(cumDeaths, "CumulDeaths"));
  minDeaths = int(TableUtils.findMinFloatInColumn(cumDeaths, "CumulDeaths"));
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
              
  //Generate country IDs
  countryIDs = geoMap.getAttributeTable();
  //saveTable(countryIDs, "data/countryIDs.csv");
  countries = countryIDs.getStringColumn("NAME");
 // countriesScale =  new ColorMap("div3-green-brown-div.xml"); 
  
  countriesScale =  new ColorMap("div3-green-brown-div (1).xml"); //original colormap
  colorMapControlPts = new double[] {0.0,0.000002,0.00008,0.0002,0.0007,0.0019,0.0023,0.0045,0.008,0.011,0.0138,0.022,0.027,0.041,0.071,0.185,0.212,0.246,0.56,0.8739,1.0};
}

void draw() {
  background(230);
  
  stroke(0,0,0);
  fill(114,114,114);
  
  //geoMap.draw();
  
  fill(235,55,52);
  
  highlightedQuake = getUnderMouse();  
  
  // === LEGEND BOX THINGS ===
  float filterYear = cp5.getController("Earthquake Range: 1950-").getValue();
  int yearValue = (int) filterYear; // cast type float to int for Year
  
  cumDeathbyYear(yearValue); //Includes draw command
  
 // System.out.println(geoMap.getID(mouseX, mouseY));
  
  // mapping circles for earthquakes for specified Year and Magnitude
  int minRadius = 15;
  int maxRadius = 30;
  int minRadius2 = 31;
  int maxRadius2 = 40;
  
  minMag = TableUtils.findMinFloatInColumn(dataTable, "EQ Primary");
  maxMag = TableUtils.findMaxFloatInColumn(dataTable, "EQ Primary");
  color lowestMagnitudeColor = color(255, 224, 121);
  color highestMagnitudeColor = color(232, 81, 21);
  
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

  for (int i = 0; i < dataTable.getRowCount(); i++) {
    TableRow currentRow = dataTable.getRow(i);
    int currentYear = currentRow.getInt("Year");
    float currentMagnitude = currentRow.getFloat("EQ Primary");
    int currentDeaths = currentRow.getInt("Earthquake : Deaths");
    boolean showNone = false;
    if (!showFirst && !showSecond && !showThird && !showAllMags) {
      showNone = true;
    }
    // confirming earthquake year is <= current slider max and that a magnitude box is checked    
    if ((currentYear <= yearValue) && (!showNone)) {  
      for (String range : selectedRanges.keySet()) {
        float radius;
        float[] selectedRange = selectedRanges.get(range);
        if (currentMagnitude >= selectedRange[0] && currentMagnitude <= selectedRange[1]) {
          String place = currentRow.getString("Location name");
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
  
  /*
  legend box (right): moved this to after earthquake circles are drawn so that circles don't go over the legend box
  so there may be some repetitive code below
  */
  stroke(0);
  fill(200);
  rect(1312, 0, 288, 900);
  
  //CUMULATIVE DEATH COUNT LEGEND
  fill(0);
  stroke(1);
  text("Cumulative Death Count", 1340, 500, 145, 350);
  strokeWeight(1);
  int gradientHeight = 200;
  int gradientWidth = 80;
//  int labelStep = gradientHeight / 2;
  int count = 0;
  for(int y = 0; y < colorMapControlPts.length; y++){
    double amt = colorMapControlPts[y];
    color c = countriesScale.lookupColor((float)amt);
    stroke(c);
    fill(c);
    //line(1400, 525 + count, 1400+gradientWidth, 525 + count);
    rect(1340, 575 + 15*y, gradientWidth, 15);
    count +=15;
   // if ((y % labelStep == 0) || (y == gradientHeight-1)) {
      long labelValue = Math.round(colorMapControlPts[y]*361569);
      textSize(12);
      fill(0);
      text(NumberFormat.getInstance().format((int)labelValue), 1430, 570 + count);
   // }
  }
  
  
  stroke(0);
  fill(200);
  textSize(20);
  for (int i = 0; i < dataTable.getRowCount(); i++) {
    TableRow currentRow = dataTable.getRow(i);
    int currentYear = currentRow.getInt("Year");
    float currentMagnitude = currentRow.getFloat("EQ Primary");
    int currentDeaths = currentRow.getInt("Earthquake : Deaths");
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
          //Details on Demand
          if(highlightedQuake.equals(place)){
            fill(0);
            // CHANGE BELOW SO IF DEATHS=0, WRITE "UNKNOWN" INSTEAD OF "0"
            text("---------------------", 1340, 230);
            if (currentDeaths == 0) {
              text("Current Place: " + place + "\nCurrent Magnitude: " + currentMagnitude + "\nDeaths: Unknown", 1340, 230, 250, 350);
            }
            else {
              text("Current Place: " + place + "\nCurrent Magnitude: " + currentMagnitude + "\nDeaths: " + currentDeaths, 1340, 230, 250, 350);
            }
            textSize(20);
          }
        }
      }
    }
  }
  
  
  // colormap legend
  fill(0);
  text("Magnitude", 1495, 600);

  strokeWeight(1);
  int cGradientHeight = 200;
  int cGradientWidth = 40;
  int labelStep = cGradientHeight / 5;
  for (int y=0; y<cGradientHeight; y++) {
    float amt = 1.0 - (float)y/(cGradientHeight-1);
    color c = lerpColorLab(lowestMagnitudeColor, highestMagnitudeColor, amt);
    stroke(c);
    line(1495, 650 + y, 1495+cGradientWidth, 650 + y);
    if ((y % labelStep == 0) || (y == cGradientHeight-1)) {
      float labelValue = (float)(minMag + amt*(maxMag - minMag));
      text(labelValue, 1540, 650 + y);
    }
  }
            
  // circle size legend
  fill(0);
  text("Death Count", 1480, 390, 145, 350);

  noStroke();
  int nExamples = 6;
  float y = 340;
  for (int i=0; i<nExamples; i++) {
    float amt = 1.0 - (float)i/(nExamples - 1);
    float radius = lerp(minRadius, maxRadius, amt);
    
    circle(1470 + radius, y+100, radius);
    int labelValue = (int)(minDeaths + amt*(maxDeaths - minDeaths));
    text(labelValue, 1520, y+106);
    y += radius;//maxIslandRadius;
  }  
  
  
  
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
