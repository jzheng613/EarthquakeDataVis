/* CSci-5609 Support Code created by Prof. Dan Keefe, Fall 2023

A color map class that supports:
 - colors defined at multiple control points that do not need to be evenly spaced
 - interpolation in Lab space
 - loading from Paraview .xml format (used on sciviscolor.org)
*/

import java.util.Collections;


class ColorMap {

  // Creates an empty ColorMap -- use addControlPt() to add colors to the map.  Then, 
  // use lookupColor() to access an interpolated color by data value.
  ColorMap() {
    controlPts = new ArrayList<ControlPt>();
  }


  // Creates a ColorMap from control points stored in ParaView's XML ColorMap format.
  // This is the format used for the maps published on sciviscolor.org
  ColorMap(String xmlFile) {
    controlPts = new ArrayList<ControlPt>();

    XML xml = loadXML(xmlFile); 
    XML[] xmlControlPts = xml.getChildren("ColorMap/Point");
    for (int i=0; i < xmlControlPts.length; i++) {
      float x = xmlControlPts[i].getFloat("x");
      float r = xmlControlPts[i].getFloat("r");
      float g = xmlControlPts[i].getFloat("g");
      float b = xmlControlPts[i].getFloat("b");
      addControlPt(x, color(r * 255.0, g * 255.0, b * 255.0));
    }
  }

  void addControlPt(float dataVal, color col) {
    controlPts.add(new ControlPt(dataVal, col));
    Collections.sort(controlPts);
  }


  color lookupColor(float dataVal) {
    if (controlPts.size() == 0) {
      println("ColorMap::lookupColor called for an empty color map!");
      return color(255);
    }
    else if (controlPts.size() == 1) {
      return controlPts.get(1).col;
    }
    else {
      float minVal = controlPts.get(0).dataVal;
      float maxVal = controlPts.get(controlPts.size()-1).dataVal;

      // check bounds
      if (dataVal >= maxVal) {
        return controlPts.get(controlPts.size()-1).col;
      }
      else if (dataVal <= minVal) {
        return controlPts.get(0).col;
      }
      else {  // value within bounds

        // make i = upper control pt and (i-1) = lower control point
        int i = 1;
        while (controlPts.get(i).dataVal < dataVal) {
          i++;
        }

        // find the amount to interpolate between the two control points
        float v1 = controlPts.get(i-1).dataVal;
        float v2 = controlPts.get(i).dataVal;
        float amt  = (dataVal - v1) / (v2 - v1);

        // use lab space to interpolate between the colors at the two control points
        color c1 = controlPts.get(i-1).col;
        color c2 = controlPts.get(i).col;
        color cInterp = lerpColorLab(c1, c2, amt);
        return cInterp;
      }
    }
  }
  
  
  void editControlPt(float origDataVal, float newDataVal, color newColor) {
    int i = 0;
    while (i < controlPts.size()) {
      if (controlPts.get(i).dataVal == origDataVal) {
        controlPts.get(i).dataVal = newDataVal;
        controlPts.get(i).col = newColor;
        Collections.sort(controlPts);
        return;
      }
      i++;
    }
    println("ColorMap::editControlPt no control point with data val = " + origDataVal);
  }


  void removeControlPt(float dataVal) {
    int i = 0;
    while (i < controlPts.size()) {
      if (controlPts.get(i).dataVal == dataVal) {
        controlPts.remove(i);
        return;
      }
      i++;
    }
    println("ColorMap::removeControlPt no control point with data val = " + dataVal);
  }

  
  // small internal class to store control points
  class ControlPt implements Comparable<ControlPt> {
    ControlPt(float d, color c) { 
      dataVal = d; 
      col = c; 
    }
    
    public int compareTo(ControlPt o) {
      return dataVal.compareTo(o.dataVal);
    }
    
    Float dataVal;
    color col;
  }
 
  // member vars 
  ArrayList<ControlPt> controlPts;
}
