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
import org.gicentre.handy.*;

// Raw data tables and objects
Table dataTable;
GeoMap geoMap;

float minMag;
float maxMag;

ControlP5 cp5;
CheckBox checkbox1;
Toggle toggle1;
String[] highlightedQuake = new String[6];

Table countryIDs; 
Table cumDeaths;
String[] countries;
int minDeaths;
int maxDeaths;
int tempMin;
int tempMax;
ColorMap countriesScale;
double[] colorMapControlPts = new double[21];

ColorMap circleScale;

int yearValue = 1950;

int minRadius = 15;
int maxRadius = 30;
int minRadius2 = 31;
int maxRadius2 = 40;

HandyRenderer h;
HandyRenderer c;
java.util.Map<java.lang.Integer, Feature> features;
int[] firstRowOfEachYear = new int[72];

// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  dataTable = loadTable("Significant Earthquake Database.csv", "header");
  println("Location table:", dataTable.getRowCount(), "x", dataTable.getColumnCount());
  tempMax = TableUtils.findMaxIntInColumn(dataTable, "Earthquake : Deaths");
  tempMin = TableUtils.findMinIntInColumn(dataTable, "Earthquake : Deaths");
  
  int year = 0;
  int count = 0;
  for(int i = 0; i < dataTable.getRowCount(); i++) {
   int y = dataTable.getRow(i).getInt("Year");
   if(y != year){
     firstRowOfEachYear[count]=i;
//     System.out.println(y + " " + i);
     year = y;
     count++;
   }
  }
  
  firstRowOfEachYear[71] = 665;
  
  cumDeaths = loadTable("CumDeathsbyCountry.csv", "header");
  maxDeaths = TableUtils.findMaxIntInColumn(cumDeaths, "CumulDeaths");
  minDeaths = TableUtils.findMinIntInColumn(cumDeaths, "CumulDeaths");
  

}

void setup() {  
  // screen size setup
  size(1600,900);

  //Set window title
  surface.setTitle("Global Major and Great Earthquakes, 1950-2020");

  // load up data info
  loadRawDataTables();
  
  // create world map, scaled size
  geoMap = new GeoMap(0, 0, 1312, 738, this);
  geoMap.readFile("world");
  
  features = geoMap.getFeatures();
  System.out.println(features);
  
  h = new HandyRenderer(this);
  h.setHachureAngle(15);
 
 
  c = new HandyRenderer(this);
  c.setHachureAngle(15);
  

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
  
  //countriesScale =  new ColorMap("div3-green-brown-div (1).xml"); //original colormap
  
  countriesScale = new ColorMap("02green-9_17e.xml");
  colorMapControlPts = new double[] {0.0,0.000002,0.00008,0.0002,0.0007,0.0019,0.0023,0.0045,0.008,0.011,
                                     0.0138,0.022,0.027,0.041,0.071,0.185,0.212,0.246,0.56,0.8739,1.0};
                                     
  circleScale = new ColorMap("4-redsun1.xml");                                   
                                     
  //smooth();
  //toggle1 = cp5.addToggle("earthquake info | death info")
  //   .setPosition(1030, 790)
  //   .setSize(140, 55)
  //   .setColorLabel(0)
  //   .setValue(true)
  //   .setMode(ControlP5.SWITCH)
  //   ;
     
  
}

void draw() {
  c.setSeed(1234);
  
  background(230);
  
  stroke(0,0,0);
  
  highlightedQuake = getUnderMouse();  
  
  // === LEGEND BOX THINGS ===
  float filterYear = cp5.getController("Earthquake Range: 1950-").getValue();
  yearValue = (int) filterYear; // cast type float to int for Year
        
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
    
    
  fill(169, 182, 170);
  stroke(1);
  cumDeathbyYear(yearValue); //Includes draw command
  
  // === DRAWING OUT EACH EARTHQUAKE CIRCLE ===
  
  
  minMag = TableUtils.findMinFloatInColumn(dataTable, "EQ Primary");
  maxMag = TableUtils.findMaxFloatInColumn(dataTable, "EQ Primary");
  
  for (int i = 0; i < dataTable.getRowCount(); i++) {
    TableRow currentRow = dataTable.getRow(i);
    int currentYear = currentRow.getInt("Year");
    float currentMagnitude = currentRow.getFloat("EQ Primary");
    int currentDeaths = currentRow.getInt("Earthquake : Deaths");
    boolean showNone = false;
    String coord = currentRow.getString("Coordinates");
    String place = currentRow.getString("Location name");
    String month = currentRow.getString("Month");
    String day = currentRow.getString("Day");
    
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
          
          color c = circleScale.lookupColor(mag_01);
          
          //If highlighted, make color black
          if(highlightedQuake[0].equals(coord) || (highlightedQuake[1].equals(place) && ((highlightedQuake[2].equals(""+currentYear) && highlightedQuake[3].equals(month) && highlightedQuake[4].equals(day) && highlightedQuake[5].equals(""+currentMagnitude))))){
            c = color(0); 
          }
          
          float lat2 = currentRow.getFloat("Latitude");
          float lon2 = currentRow.getFloat("Longitude");
          PVector coord2 = geoMap.geoToScreen(lon2, lat2);
          
          // current year range's earthquakes are highlighted
          if ((currentYear == yearValue) | (currentYear > yearValue-10)) {
            stroke(0);
            strokeWeight(2);
            fill(c);
            
            //If Handy
         //   h.setBackgroundColour(highestMagnitudeColor);
        //    stroke(200);
            h.setFillWeight(4);
            h.setFillGap(0);
            h.ellipse(coord2.x, coord2.y, radius, radius);
          }
          else {
            stroke(200);
            fill(c);
            
            //If handy
            //h.setBackgroundColour(highestMagnitudeColor);
            //stroke(200);
          //  h.setFillGap(mag_01);
            //h.setFillWeight(mag_01*5);
            //h.ellipse(coord2.x, coord2.y, radius, radius);
            circle(coord2.x, coord2.y, radius);
          }
          
         // circle(coord2.x, coord2.y, radius);
          
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
  text("Earthquake Details", 1340, 50); 
  textSize(16);
  text("Place:", 1340, 80);
  text("Magnitude:", 1340, 110);
  text("Deaths:", 1340, 140);
  text("Date:", 1340, 170);
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
      String coord = "";
      String place = "";
      String year = "";
      String month = "";
      String day = "";
      String mag = "";
      
      for (String range : selectedRanges.keySet()) {
        float[] selectedRange = selectedRanges.get(range);
        if (currentMagnitude >= selectedRange[0] && currentMagnitude <= selectedRange[1]) {
        // Details on Demand
          coord = currentRow.getString("Coordinates");
          place = currentRow.getString("Location name");
          year = currentRow.getString("Year");
          month =  currentRow.getString("Month");
          day = currentRow.getString("Day");
          if(highlightedQuake[0].equals(coord) || (highlightedQuake[1].equals(place) && (highlightedQuake[2].equals(year) && highlightedQuake[3].equals(month) && highlightedQuake[4].equals(day) && highlightedQuake[5].equals(mag)))){
            textSize(19);
           
            text(place, 1385, 80);
            text(currentMagnitude, 1415, 110);
            text(dateMonth + "/" + dateDay + "/" + dateYear, 1378, 170);
            
            if (currentDeaths.isEmpty()) {
              text("Unknown", 1395, 140);
            }
            else {
              int deaths = Integer.parseInt(currentDeaths);
              text(deaths, 1395, 140);
            }
          }
        }
      }
    }
  }
  
  
  // === EARTHQUAKE CIRCLE SIZE LEGEND ===
  textSize(23);
  text("Earthquake", 1335, 220);
  text("Death Count", 1335, 240);
  noStroke();
  int nExamples = 6;
  float y = 245;
  for (int i=0; i<nExamples; i++) {
    textSize(18);
    float amt = 1.0 - (float)i/(nExamples - 1);
    float radius = lerp(minRadius, maxRadius2, amt);
    fill(50);
    circle(1355, y+30, radius);
    int labelValue = (int)(0 + amt*(316000 - 0));
    fill(0);
    text(NumberFormat.getInstance().format(labelValue), 1390, y+35);
    y += (1.4 * radius);//maxIslandRadius;
  }  
  
  
  // === EARTHQUAKE MAGNITUDE COLOR LEGEND ===
  textSize(23);
  fill(0);
  text("Magnitude", 1480, 240);
  strokeWeight(1);
  int cGradientHeight = 200;
  int cGradientWidth = 40;
  int labelStep = cGradientHeight / 5;
  for (int j=0; j<cGradientHeight; j++) {
    float amt = 1.0 - (float)j/(cGradientHeight-1);
    color c = circleScale.lookupColor(amt);
    stroke(c);
    line(1485, 265 + j, 1485+cGradientWidth, 265 + j);
    if ((j % labelStep == 0) || (j == cGradientHeight-1)) {
      float labelValue = (float)(minMag + amt*(maxMag - minMag));
      textSize(18);
      text(labelValue, 1540, 270 + j);
    }
  }
  
  
    
  // === CUMULATIVE DEATH COUNT LEGEND ===
  fill(0);
  stroke(1);
  textSize(22);
  text("Cumulative Deaths", 1340, 540);
  text("For Countries", 1340, 565);
  
  //strokeWeight(1);
  //int gradientWidth = 80;
  //int count = 0;
  //for(int x = 0; x < colorMapControlPts.length; x++){
  //  double amt = colorMapControlPts[x];
  //  color c = countriesScale.lookupColor((float)amt);
  //  stroke(c);
  //  fill(c);
  //  rect(1340, 550 + 15*x, gradientWidth, 15);
  //  count +=15;
  //  long labelValue = Math.round(colorMapControlPts[x]*361569);
  //  textSize(12);
  //  fill(0);
  //  text(NumberFormat.getInstance().format((int)labelValue), 1440, 545 + count);
  //}

  
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
  
  // control box (bottom)
  fill(224, 224, 224);
  stroke(0);
  rect(0, 739, 1312, 162);
  
  fill(0);
  textSize(25);
  text("Year Range: 1950-" + yearValue, 50, 775);
  text("Filter By Magnitude:", 525, 775);  
  
  textSize(23);
  fill(0);
  text("Total Earthquakes: " + totalQuakes, 1030,775);
  textSize(20);
  text("Magnitude 7.0-7.9: " + total7, 1030, 805);
  text("Magnitude 8.0-8.9: " + total8, 1030, 825);
  text("Magnitude 9.0-10.0: " + total9, 1030, 845);
  
}

float getRadius(String coord) {
  float radius;
  TableRow rowData = dataTable.findRow(coord, "Coordinates");
  int currentDeaths = rowData.getInt("Earthquake : Deaths");
  float death_01 = (float(currentDeaths) - float(0)) / (float(5000) - float(0));
  //min=5,001 and max=316,000
  float death_02 = (float(currentDeaths) - float(5001)) / (float(320000) - float(5001));
 
            
  if (currentDeaths < 5001) {
    radius = lerp(minRadius, maxRadius, death_01);
  }
  else {
    radius = lerp(minRadius2, maxRadius2, death_02);
  }
  
  return radius;
}



////////////
//HELPER FUNCTIONS


//Returns array of information about country under mouse or null if no country is available
String[] getUnderMouse() {
  float smallestRadiusSquared = Float.MAX_VALUE;
  String[] underMouse = {"", "" , "", "", "", ""}; //{coordinates, location name}
  TableRow rowData;
  String place, coordinates, year, month, day, mag;
  float latitude, longitude, screenX, screenY, distSquared, radius, radiusSquared;
  
  
 // System.out.println(firstRowOfEachYear[1]);
  
  for (int i=firstRowOfEachYear[yearValue-1950+1]-1; i>=0; i--) {
    rowData = dataTable.getRow(i);
    place = rowData.getString("Location name");
    coordinates = rowData.getString("Coordinates");
    year = rowData.getString("Year");
    month = rowData.getString("Month");
    day = rowData.getString("Day");
    mag = rowData.getString("EQ Primary");
    latitude = rowData.getFloat("Latitude");
    longitude = rowData.getFloat("Longitude");
    PVector screenXY = geoMap.geoToScreen(longitude,latitude);
    screenX = screenXY.x;
    screenY = screenXY.y;
    distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
    radius = getRadius(coordinates);
    radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse[0] = coordinates;
      underMouse[1] = place;
      underMouse[2] = year;
      underMouse[3] = month;
      underMouse[4] = day;
      underMouse[5] = mag;
      smallestRadiusSquared = radiusSquared;
    }
  }
 // System.out.println(underMouse[0] + " " + underMouse[1]);
  return underMouse;  
}

//Returns texture gradient
float[] getTexture(float lerpedDeaths){
  float[] gapWeight = {100000, 0.3};
  
  if(lerpedDeaths<=1.0 && lerpedDeaths>.8739){
    gapWeight[0] = .1; 
    gapWeight[1] = .3; 
    return gapWeight;
  }
  else if(lerpedDeaths>.56 && lerpedDeaths<=.8739){
    gapWeight[0] = .45;
    gapWeight[1] = 1;
  
    return gapWeight;
  }
  else if(lerpedDeaths<=.56 && lerpedDeaths>.246){
    gapWeight[0] = .5;
    gapWeight[1] = 1;
  
    return gapWeight;
  }
  else if(lerpedDeaths<=.246 && lerpedDeaths>.212){
    gapWeight[0] =.2;
    gapWeight[1] = .3;
    
    return gapWeight;
  }
  else if(lerpedDeaths>.185 && lerpedDeaths<=.212){
    gapWeight[0] = .5; 
    gapWeight[1] = .7; 

    return gapWeight;
  }
  else if(lerpedDeaths<=.185 && lerpedDeaths>.071){
    gapWeight[0] = 1;
    gapWeight[1] = 1;
  
    return gapWeight;
  }
  else if(lerpedDeaths>.063 && lerpedDeaths<=.071){
    gapWeight[0] = 2;
    gapWeight[1] = 1.7;

    return gapWeight;
  }
  else if(lerpedDeaths<=.063 && lerpedDeaths>.041){
    gapWeight[0] =2;
    gapWeight[1] = 1;

    return gapWeight;
  }
  else if(lerpedDeaths>.027 && lerpedDeaths<=.041){
    gapWeight[0] =3;
    gapWeight[1] = 1.2;

    return gapWeight;
  }
  else if(lerpedDeaths<=.027 && lerpedDeaths>.022){
    gapWeight[0] = 4;
    gapWeight[1] = 1.2;

    return gapWeight;
  }
  else if(lerpedDeaths>.0138 && lerpedDeaths<=.022){
    gapWeight[0] = 5.5;
    gapWeight[1] = 1.2;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0138 && lerpedDeaths>.011){
    gapWeight[0] = 5.5;
    gapWeight[1] = .8;

    return gapWeight;
  }
  else if(lerpedDeaths>.008 && lerpedDeaths<=.011){
    gapWeight[0] = 8;
    gapWeight[1] = .8;

    return gapWeight;
  }
  else if(lerpedDeaths<=.008 && lerpedDeaths>.0055){
    gapWeight[0] = 8;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths>.0045 && lerpedDeaths<=.0055){
    gapWeight[0] = 10;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0045 && lerpedDeaths>.0023){
    gapWeight[0] = 12;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0045 && lerpedDeaths>.0023){
    gapWeight[0] = 15;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths>.0019 && lerpedDeaths<=.0023){
    gapWeight[0] = 20;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0019 && lerpedDeaths>.0007){
    gapWeight[0] = 25;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths>0.0002 && lerpedDeaths<=.0007){
    gapWeight[0] = 32;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths<=0.0002 && lerpedDeaths>.00008){
    gapWeight[0] = 37;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths>.00003 && lerpedDeaths<=.00008){
    gapWeight[0] = 50;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths<=.00003 && lerpedDeaths>.000002){
    gapWeight[0] = 100;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else{
     gapWeight[0] = 100000;
    gapWeight[1] = .3;

  }
  return gapWeight;
}

//To set color of countries and draw map
void cumDeathbyYear(int year){

  TableRow row;
  int deaths;
  int ID;
  float lerpedDeaths;
  int firstRow = 242*(year-1950);
  c.setBackgroundColour(color(184,194,185));
  

//  for(int i = 0; i<countries.length;i++){
//   row = cumDeaths.getRow(firstRow+i);
   
//   deaths = row.getInt("CumulDeaths");
//   lerpedDeaths = (float(deaths)-float(minDeaths))/(float(maxDeaths)-float(minDeaths));
//   ID = countryIDs.getRow(i).getInt("id");
   
//   fill(countriesScale.lookupColor(lerpedDeaths));
   
   
// //  setHandyRenderer();
//   //Handy option
//////   fill(countriesScale.lookupColor(0));
////   System.out.println("handy");
////   c.setFillGap(lerpedDeaths);
////   System.out.println("handyq");
////   c.setFillWeight(lerpedDeaths*5);

// //  System.out.println("handydraw");
////   System.out.println(geoMap.getNumPolys());
//   setHandyRenderer();
//   geoMap.draw(ID);

//  }

  DrawableFactory factory = new DrawableFactory();
  Drawable cDraw = factory.createHandyRenderer(c);
 // c.setFillGap(2);
  c.setIsAlternating(false);
  
  for(java.util.Map.Entry<java.lang.Integer, Feature> set: features.entrySet()){
   ID = set.getKey(); 
   
   row = cumDeaths.getRow(firstRow+ID-1);
   
   deaths = row.getInt("CumulDeaths");
   lerpedDeaths = (float(deaths)-float(minDeaths))/(float(maxDeaths)-float(minDeaths));
  // ID = countryIDs.getRow(i).getInt("id");
   
   fill(countriesScale.lookupColor(0));
   float[] gapWeight = getTexture(lerpedDeaths);
   c.setFillGap(gapWeight[0]);
   c.setFillWeight(gapWeight[1]);
  
   set.getValue().setRenderer(cDraw);
   
   geoMap.draw(ID);

  }

}
