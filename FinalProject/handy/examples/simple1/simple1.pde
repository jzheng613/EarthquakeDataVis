import org.gicentre.handy.*;    // For Handy rendering.
import java.text.NumberFormat;
// Displays a simple rectangle in a hand-drawn style.
// Version 2.0, 4th April, 2016
// Author Jo Wood

HandyRenderer c;      // This does all the hard work of rendering.
float[] colorMapControlPts ;
// Set up the sketch and renderer.
void setup()
{
  size(1600,900); 
  c = new HandyRenderer(this);    // Creates the renderer.
  println(Version.getText());
  colorMapControlPts = new float[] {0.0,0.000002, 0.00003,0.00008, 0.0002,.0007,0.0019,0.0023,0.0045, .0055,0.008,.011,
                                     0.0138,.022,0.027,.041,0.063,.071,0.185,.212,0.246,.56,0.8739, 1.0};
}

// Draw a rectangle in a sketchy style
void draw()
{
  background(247,230,197);
  //c.rect(width/4,height/4,width/2,height/2);
  float[] gapWeight = new float[2];
  int gradientWidth = 80;
  int count =0;
   for(int x = 0; x < colorMapControlPts.length; x++){
    c.setFillColour(color(4,148,147));
    c.setBackgroundColour(color(213, 213, 224));
    fill(color(4,148,147));
    stroke(color(213, 213, 224));
    noStroke();
    c.setStrokeColour(color(213, 213, 224));
    float amt = colorMapControlPts[x];
  //  System.out.println(amt);
    gapWeight[0] = getTexture(amt)[0];
    gapWeight[1] = getTexture(amt)[1];
    c.setFillGap(gapWeight[0]);
    c.setFillWeight(gapWeight[1]);
    c.rect(100, 100 + 25*x, gradientWidth, 25);
    count +=25;
    
    long labelValue = Math.round(colorMapControlPts[x]*361569);
    textSize(12);
    fill(0);
    text(NumberFormat.getInstance().format((int)labelValue), 100, 100 + count);
  }
  
  noLoop();  // No need to redraw.
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
    gapWeight[0] = 7;
    gapWeight[1] = 6.5;
  
    return gapWeight;
  }
  else if(lerpedDeaths<=.56 && lerpedDeaths>.246){
    gapWeight[0] =9;
    gapWeight[1] = 6;
  
    return gapWeight;
  }
  else if(lerpedDeaths<=.246 && lerpedDeaths>.212){
    gapWeight[0] =11;
    gapWeight[1] = 5.8;
    
    return gapWeight;
  }
  else if(lerpedDeaths>.185 && lerpedDeaths<=.212){
    gapWeight[0] = 12; 
    gapWeight[1] = 5.8; 

    return gapWeight;
  }
  else if(lerpedDeaths<=.185 && lerpedDeaths>.071){
    gapWeight[0] = 13;
    gapWeight[1] = 5.5;
  
    return gapWeight;
  }
  else if(lerpedDeaths>.063 && lerpedDeaths<=.071){
    gapWeight[0] = 15;
    gapWeight[1] = 5.3;

    return gapWeight;
  }
  else if(lerpedDeaths<=.063 && lerpedDeaths>.041){
    gapWeight[0] =16;
    gapWeight[1] = 5.3;

    return gapWeight;
  }
  else if(lerpedDeaths>.027 && lerpedDeaths<=.041){
    gapWeight[0] =17;
    gapWeight[1] = 4.6;

    return gapWeight;
  }
  else if(lerpedDeaths<=.027 && lerpedDeaths>.022){
    gapWeight[0] = 18;
    gapWeight[1] = 4;

    return gapWeight;
  }
  else if(lerpedDeaths>.0138 && lerpedDeaths<=.022){
    gapWeight[0] = 20;
    gapWeight[1] = 3.7;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0138 && lerpedDeaths>.011){
    gapWeight[0] = 21;
    gapWeight[1] = 3.2;

    return gapWeight;
  }
  else if(lerpedDeaths>.008 && lerpedDeaths<=.011){
    gapWeight[0] = 22;
    gapWeight[1] = 2.8;

    return gapWeight;
  }
  else if(lerpedDeaths<=.008 && lerpedDeaths>.0055){
    gapWeight[0] = 22;
    gapWeight[1] = 2;

    return gapWeight;
  }
  else if(lerpedDeaths>.0045 && lerpedDeaths<=.0055){
    gapWeight[0] = 23;
    gapWeight[1] = 1.8;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0045 && lerpedDeaths>.0023){
    gapWeight[0] = 24;
    gapWeight[1] = 1.4;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0045 && lerpedDeaths>.0023){
    gapWeight[0] = 25;
    gapWeight[1] = 1;

    return gapWeight;
  }
  else if(lerpedDeaths>.0019 && lerpedDeaths<=.0023){
    gapWeight[0] = 25;
    gapWeight[1] = .7;

    return gapWeight;
  }
  else if(lerpedDeaths<=.0019 && lerpedDeaths>.0007){
    gapWeight[0] = 25;
    gapWeight[1] = .5;

    return gapWeight;
  }
  else if(lerpedDeaths>0.0002 && lerpedDeaths<=.0007){
    gapWeight[0] = 32;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths<=0.0002 && lerpedDeaths>.00008){
    gapWeight[0] = 40;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths>.00003 && lerpedDeaths<=.00008){
    gapWeight[0] = 50;
    gapWeight[1] = .3;

    return gapWeight;
  }
  else if(lerpedDeaths<=.00003 && lerpedDeaths>0){
    gapWeight[0] = 50;
    gapWeight[1] = .1;

    return gapWeight;
  }
  else{
     gapWeight[0] = 100000;
    gapWeight[1] = 0;

  }
  return gapWeight;
}
