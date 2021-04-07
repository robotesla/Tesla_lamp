/**
 *
 * DEPRECATED, use ScrollableList instead.
 * 
 * Control5 DropdownList
 * A dropdownList controller, extends the ListBox controller.
 * the most recently selected dropdownlist item is displayed inside
 * the menu bar of the DropdownList.
 *
 * find a list of public methods available for the DropdownList Controller 
 * at the bottom of this sketch's source code
 *
 *
 * by andreas schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 */

import controlP5.*;
import processing.serial.*;
import drop.*;

ControlP5 cp5;
DropdownList d1;
//ColorPicker cp;
Button b1;
Button b2;
Button b3;
ColorPicker cw;
Textlabel label_com;
Range range;
SDrop drop;
Serial myPort;  // Create object from Serial class


int r = 0;
int g = 0;
int b = 0;
int a = 0;

int numMin = 0;
int numMax = 10;
int Max = 60;

PImage m;
String portName;

color[] LED = new color[Max];
color[] LED_PIC = new color[Max*5];

void setup() {
  size(1000, 400 );
  drop = new SDrop(this);

  for (int i = 0; i<Max; i++)
  {
    LED[i] = color(r, g, b);
  }
  for (int i = 0; i<Max*5; i++)
  {
    LED_PIC[i] = color(r, g, b);
  }


  cp5 = new ControlP5(this);

  // create a DropdownList, 
  d1 = cp5.addDropdownList("COM-ports")
    .setPosition(100, 100)
    ;

  customize(d1); // customize the first list

  b1 = cp5.addButton("Save color")
    //.setValue(0)
    .setPosition(100, 200)
    .setSize(100, 19)
    ;


  b2 = cp5.addButton("SEND_LINE!")
    //.setValue(0)
    .setPosition(100, 70)
    .setSize(100, 19)
    ;


  b3 = cp5.addButton("SEND_PIC!")
    //.setValue(0)
    .setPosition(250, 70)
    .setSize(100, 19)
    ;

  cw = cp5.addColorPicker("picker")
    .setPosition(250, 100)
    .setSize(300, 300)
    .setColorValue(color(255, 128, 0, 128))
    ;

  label_com = cp5.addTextlabel("label")
    .setText("Disconnected")
    .setPosition(100, 50)
    .setColorValue(0xffffffff)
    .setHeight(10)
    ;

  range = cp5.addRange("rangeController")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
    .setPosition(50, 250)
    .setSize(510, 20)
    .setHandleSize(20)
    .setRange(0, 60)
    .setRangeValues(0, 10)
    .setColorForeground(color(255, 100))
    .setColorBackground(color(15, 40))
    .setColorCaptionLabel(color(205, 40))
    .showTickMarks(true)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)

    ;
}


void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.getCaptionLabel().set("COM-ports");
  ddl.addItems(Serial.list());

  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void write_line()
{
  for (int j = 0; j<5; j++)
  {
    for (int i = 0; i<Max; i++)
    {
      String s;
      if (j%2==0)
      {
        s = str(i+j*60)+","+int(red(LED[i]))+","+int(green(LED[i]))+","+int(blue(LED[i]))+","+int(alpha(LED[i]))+".";
      } else
      {
        s = str((j+1)*60-i-1)+","+int(red(LED[i]))+","+int(green(LED[i]))+","+int(blue(LED[i]))+","+int(alpha(LED[i]))+".";
      }
      myPort.write(s);
      delay(10);
      print("read:");
      println(myPort.readString());
      //print("i:");print(i);
      //print("j:");print(j);
      //print("255,0,255,0,0,");
      println(s);
    }
  }
}

void write_pic()
{
  for (int j = 0; j<5; j++)
  {
    for (int i = 0; i<Max; i++)
    {
      String s;
      if (j%2==0)
      {
        s = str(i+j*60)+","+int(red(LED_PIC[i+j*60]))+","+int(green(LED_PIC[i+j*60]))+","+int(blue(LED_PIC[i+j*60]))+","+int(0)+".";
      } else
      {
        s = str((j+1)*60-i-1)+","+int(red(LED_PIC[(j+1)*60-i-1]))+","+int(green(LED_PIC[(j+1)*60-i-1]))+","+int(blue(LED_PIC[(j+1)*60-i-1]))+","+int(0)+".";
      }
      myPort.write(s);
      delay(10);
      print("read:");
      println(myPort.readString());
      //print("i:");print(i);
      //print("j:");print(j);
      //print("255,0,255,0,0,");
      println(s);
    }
  }
}

void update_color()
{
  for (int i = numMin; i<numMax+1; i++)
  {
    LED[i] = color(r, g, b, a);
    //println(LED[i]);
  }
  for (int i = 0; i<5; i++)
  {
    for (int j = 0; j<Max; j++)
    {
      //println("i:"+str(i)+"j:"+str(j));
      //println("(i*60)+j = "+str((i*60)+j));
      color c = m.get(i, j);
      //println("LED_PIC["+str((i*60)+j)+"]");
      LED_PIC[(i*60)+j] = color(c);
      println(LED_PIC[(i*60)+j]);
    }
  }
}

void controlEvent(ControlEvent theEvent) {




  if (theEvent.isFrom(d1)) 
  {
    portName = Serial.list()[int(theEvent.getController().getValue())];
    myPort = new Serial(this, portName, 115200);
  }

  if (theEvent.isFrom(b2)) 
  {
    //portName = Serial.list()[int(theEvent.getController().getValue())];
    write_line();
  }

  if (theEvent.isFrom(b2)) 
  {
    //portName = Serial.list()[int(theEvent.getController().getValue())];
    write_line();
  }

  if (theEvent.isFrom(b3)) 
  {
    //portName = Serial.list()[int(theEvent.getController().getValue())];
    write_pic();
  }
  if (theEvent.isFrom(b1)) 
  {
    //portName = Serial.list()[int(theEvent.getController().getValue())];
    update_color();
  }

  if (theEvent.isFrom(cw)) {
    r = int(theEvent.getArrayValue(0));
    g = int(theEvent.getArrayValue(1));
    b = int(theEvent.getArrayValue(2));
    a = int(theEvent.getArrayValue(3));
    ;
    //write();
  }

  if (theEvent.isFrom(range)) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    numMin = int(theEvent.getController().getArrayValue(0));
    numMax = int(theEvent.getController().getArrayValue(1));
    //println("range update, done.");
  }


  if (myPort != null)
  {
    label_com.setText("Connect to:"+portName);
  } else
  {
    label_com.setText("Disconnected");
  }
}
void draw() {
  background(128);
  noStroke();
  int n = 0;
  if (millis()%500>250)
  {
    n = 1;
  }
  for (int i=0; i<LED.length; i++) {
    if (numMin-1<i && i<numMax+1) 
    {
      if (n>0)
      {
        fill(LED[i]);
      } else fill(color(r, g, b));
    } else fill(color(red(LED[i]), green(LED[i]), blue(LED[i])));

    rect(70+i*8, 280, 3, 30);
    fill(alpha(LED[i]));
    rect(70+i*8, 320, 3, 30);

    if (m !=null) {
      m.resize(5, 60);
      image(m, 10, 10);
    }
  }
}

void dropEvent(DropEvent theDropEvent) {

  // if the dropped object is an image, then 
  // load the image into our PImage.
  if (theDropEvent.isFile()) {

    m = theDropEvent.loadImage();
  }
}
