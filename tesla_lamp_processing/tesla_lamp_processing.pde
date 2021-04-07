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

ControlP5 cp5;
DropdownList d1;
//ColorPicker cp;
Button b1;
Button b2;
ColorPicker cw;
Textlabel label_com;
Range range;

Serial myPort;  // Create object from Serial class


int r = 0;
int g = 0;
int b = 0;
int a = 0;

int numMin = 0;
int numMax = 10;
int Max = 60;

String portName;

color[] LED = new color[Max];

void setup() {
  size(1000, 400 );

  for (int i = 0; i<Max; i++)
  {
    LED[i] = color(r, g, b);
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


  b2 = cp5.addButton("SEND!")
    //.setValue(0)
    .setPosition(100, 70)
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

void write()
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
      print("read");
      print(myPort.readString());
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
  }
}

void controlEvent(ControlEvent theEvent) {




  if (theEvent.isFrom(d1)) 
  {
    portName = Serial.list()[int(theEvent.getController().getValue())];
    myPort = new Serial(this, portName, 250000);
  }

  if (theEvent.isFrom(b2)) 
  {
    //portName = Serial.list()[int(theEvent.getController().getValue())];
    write();
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
  {n = 1;}
  for (int i=0; i<LED.length; i++) {
    if (numMin-1<i && i<numMax+1) 
    {
      if(n>0)
      {
      fill(LED[i]);
      }
      else fill(color(r,g,b));
    }
    else fill(color(red(LED[i]),green(LED[i]),blue(LED[i])));
    
    rect(70+i*8, 280, 3, 30);
    fill(alpha(LED[i]));
    rect(70+i*8, 320, 3, 30);
  }
}

/* 
 a list of all methods available for the DropdownList Controller
 use ControlP5.printPublicMethodsFor(DropdownList.class);
 to print the following list into the console.
 
 You can find further details about class DropdownList in the javadoc.
 
 Format:
 ClassName : returnType methodName(parameter type)
 
 
 controlP5.Controller : CColor getColor() 
 controlP5.Controller : ControlBehavior getBehavior() 
 controlP5.Controller : ControlWindow getControlWindow() 
 controlP5.Controller : ControlWindow getWindow() 
 controlP5.Controller : ControllerProperty getProperty(String) 
 controlP5.Controller : ControllerProperty getProperty(String, String) 
 controlP5.Controller : ControllerView getView() 
 controlP5.Controller : DropdownList addCallback(CallbackListener) 
 controlP5.Controller : DropdownList addListener(ControlListener) 
 controlP5.Controller : DropdownList addListenerFor(int, CallbackListener) 
 controlP5.Controller : DropdownList align(int, int, int, int) 
 controlP5.Controller : DropdownList bringToFront() 
 controlP5.Controller : DropdownList bringToFront(ControllerInterface) 
 controlP5.Controller : DropdownList hide() 
 controlP5.Controller : DropdownList linebreak() 
 controlP5.Controller : DropdownList listen(boolean) 
 controlP5.Controller : DropdownList lock() 
 controlP5.Controller : DropdownList onChange(CallbackListener) 
 controlP5.Controller : DropdownList onClick(CallbackListener) 
 controlP5.Controller : DropdownList onDoublePress(CallbackListener) 
 controlP5.Controller : DropdownList onDrag(CallbackListener) 
 controlP5.Controller : DropdownList onDraw(ControllerView) 
 controlP5.Controller : DropdownList onEndDrag(CallbackListener) 
 controlP5.Controller : DropdownList onEnter(CallbackListener) 
 controlP5.Controller : DropdownList onLeave(CallbackListener) 
 controlP5.Controller : DropdownList onMove(CallbackListener) 
 controlP5.Controller : DropdownList onPress(CallbackListener) 
 controlP5.Controller : DropdownList onRelease(CallbackListener) 
 controlP5.Controller : DropdownList onReleaseOutside(CallbackListener) 
 controlP5.Controller : DropdownList onStartDrag(CallbackListener) 
 controlP5.Controller : DropdownList onWheel(CallbackListener) 
 controlP5.Controller : DropdownList plugTo(Object) 
 controlP5.Controller : DropdownList plugTo(Object, String) 
 controlP5.Controller : DropdownList plugTo(Object[]) 
 controlP5.Controller : DropdownList plugTo(Object[], String) 
 controlP5.Controller : DropdownList registerProperty(String) 
 controlP5.Controller : DropdownList registerProperty(String, String) 
 controlP5.Controller : DropdownList registerTooltip(String) 
 controlP5.Controller : DropdownList removeBehavior() 
 controlP5.Controller : DropdownList removeCallback() 
 controlP5.Controller : DropdownList removeCallback(CallbackListener) 
 controlP5.Controller : DropdownList removeListener(ControlListener) 
 controlP5.Controller : DropdownList removeListenerFor(int, CallbackListener) 
 controlP5.Controller : DropdownList removeListenersFor(int) 
 controlP5.Controller : DropdownList removeProperty(String) 
 controlP5.Controller : DropdownList removeProperty(String, String) 
 controlP5.Controller : DropdownList setArrayValue(float[]) 
 controlP5.Controller : DropdownList setArrayValue(int, float) 
 controlP5.Controller : DropdownList setBehavior(ControlBehavior) 
 controlP5.Controller : DropdownList setBroadcast(boolean) 
 controlP5.Controller : DropdownList setCaptionLabel(String) 
 controlP5.Controller : DropdownList setColor(CColor) 
 controlP5.Controller : DropdownList setColorActive(int) 
 controlP5.Controller : DropdownList setColorBackground(int) 
 controlP5.Controller : DropdownList setColorCaptionLabel(int) 
 controlP5.Controller : DropdownList setColorForeground(int) 
 controlP5.Controller : DropdownList setColorLabel(int) 
 controlP5.Controller : DropdownList setColorValue(int) 
 controlP5.Controller : DropdownList setColorValueLabel(int) 
 controlP5.Controller : DropdownList setDecimalPrecision(int) 
 controlP5.Controller : DropdownList setDefaultValue(float) 
 controlP5.Controller : DropdownList setHeight(int) 
 controlP5.Controller : DropdownList setId(int) 
 controlP5.Controller : DropdownList setImage(PImage) 
 controlP5.Controller : DropdownList setImage(PImage, int) 
 controlP5.Controller : DropdownList setImages(PImage, PImage, PImage) 
 controlP5.Controller : DropdownList setImages(PImage, PImage, PImage, PImage) 
 controlP5.Controller : DropdownList setLabel(String) 
 controlP5.Controller : DropdownList setLabelVisible(boolean) 
 controlP5.Controller : DropdownList setLock(boolean) 
 controlP5.Controller : DropdownList setMax(float) 
 controlP5.Controller : DropdownList setMin(float) 
 controlP5.Controller : DropdownList setMouseOver(boolean) 
 controlP5.Controller : DropdownList setMoveable(boolean) 
 controlP5.Controller : DropdownList setPosition(float, float) 
 controlP5.Controller : DropdownList setPosition(float[]) 
 controlP5.Controller : DropdownList setSize(PImage) 
 controlP5.Controller : DropdownList setSize(int, int) 
 controlP5.Controller : DropdownList setStringValue(String) 
 controlP5.Controller : DropdownList setUpdate(boolean) 
 controlP5.Controller : DropdownList setValue(float) 
 controlP5.Controller : DropdownList setValueLabel(String) 
 controlP5.Controller : DropdownList setValueSelf(float) 
 controlP5.Controller : DropdownList setView(ControllerView) 
 controlP5.Controller : DropdownList setVisible(boolean) 
 controlP5.Controller : DropdownList setWidth(int) 
 controlP5.Controller : DropdownList show() 
 controlP5.Controller : DropdownList unlock() 
 controlP5.Controller : DropdownList unplugFrom(Object) 
 controlP5.Controller : DropdownList unplugFrom(Object[]) 
 controlP5.Controller : DropdownList unregisterTooltip() 
 controlP5.Controller : DropdownList update() 
 controlP5.Controller : DropdownList updateSize() 
 controlP5.Controller : Label getCaptionLabel() 
 controlP5.Controller : Label getValueLabel() 
 controlP5.Controller : List getControllerPlugList() 
 controlP5.Controller : Pointer getPointer() 
 controlP5.Controller : String getAddress() 
 controlP5.Controller : String getInfo() 
 controlP5.Controller : String getName() 
 controlP5.Controller : String getStringValue() 
 controlP5.Controller : String toString() 
 controlP5.Controller : Tab getTab() 
 controlP5.Controller : boolean isActive() 
 controlP5.Controller : boolean isBroadcast() 
 controlP5.Controller : boolean isInside() 
 controlP5.Controller : boolean isLabelVisible() 
 controlP5.Controller : boolean isListening() 
 controlP5.Controller : boolean isLock() 
 controlP5.Controller : boolean isMouseOver() 
 controlP5.Controller : boolean isMousePressed() 
 controlP5.Controller : boolean isMoveable() 
 controlP5.Controller : boolean isUpdate() 
 controlP5.Controller : boolean isVisible() 
 controlP5.Controller : float getArrayValue(int) 
 controlP5.Controller : float getDefaultValue() 
 controlP5.Controller : float getMax() 
 controlP5.Controller : float getMin() 
 controlP5.Controller : float getValue() 
 controlP5.Controller : float[] getAbsolutePosition() 
 controlP5.Controller : float[] getArrayValue() 
 controlP5.Controller : float[] getPosition() 
 controlP5.Controller : int getDecimalPrecision() 
 controlP5.Controller : int getHeight() 
 controlP5.Controller : int getId() 
 controlP5.Controller : int getWidth() 
 controlP5.Controller : int listenerSize() 
 controlP5.Controller : void remove() 
 controlP5.Controller : void setView(ControllerView, int) 
 controlP5.DropdownList : DropdownList addItem(String, Object) 
 controlP5.DropdownList : DropdownList addItems(List) 
 controlP5.DropdownList : DropdownList addItems(Map) 
 controlP5.DropdownList : DropdownList addItems(String[]) 
 controlP5.DropdownList : DropdownList clear() 
 controlP5.DropdownList : DropdownList close() 
 controlP5.DropdownList : DropdownList open() 
 controlP5.DropdownList : DropdownList removeItem(String) 
 controlP5.DropdownList : DropdownList removeItems(List) 
 controlP5.DropdownList : DropdownList setBackgroundColor(int) 
 controlP5.DropdownList : DropdownList setBarHeight(int) 
 controlP5.DropdownList : DropdownList setBarVisible(boolean) 
 controlP5.DropdownList : DropdownList setItemHeight(int) 
 controlP5.DropdownList : DropdownList setItems(List) 
 controlP5.DropdownList : DropdownList setItems(Map) 
 controlP5.DropdownList : DropdownList setItems(String[]) 
 controlP5.DropdownList : DropdownList setOpen(boolean) 
 controlP5.DropdownList : DropdownList setScrollSensitivity(float) 
 controlP5.DropdownList : DropdownList setType(int) 
 controlP5.DropdownList : List getItems() 
 controlP5.DropdownList : Map getItem(String) 
 controlP5.DropdownList : Map getItem(int) 
 controlP5.DropdownList : boolean isBarVisible() 
 controlP5.DropdownList : boolean isOpen() 
 controlP5.DropdownList : int getBackgroundColor() 
 controlP5.DropdownList : int getBarHeight() 
 controlP5.DropdownList : int getHeight() 
 controlP5.DropdownList : void controlEvent(ControlEvent) 
 controlP5.DropdownList : void keyEvent(KeyEvent) 
 controlP5.DropdownList : void setDirection(int) 
 controlP5.DropdownList : void updateItemIndexOffset() 
 java.lang.Object : String toString() 
 java.lang.Object : boolean equals(Object) 
 
 created: 2015/03/24 12:21:05
 
 */
