//Simple GUI and datalogger for Senior Design
//Author: Jacob Lurvey
import processing.serial.*;
Serial arduino;
String fromSrl;

//data storage
Table table;
String fileName = "dataLog_1p2bar.csv";

boolean loggingActive = false;
boolean zeroedOnce = false;
boolean plottingActive = false;

int newY;
int x1;
int x2;
int y1;
int y2;



int pAbs = 0;
int pGage = 0;
int zeroLevel = 0;

//plotting variables
ArrayList wave = new ArrayList();//arraylist allows for easy add/remove on plotting data
ArrayList xvals = new ArrayList();
final int waveLength = 100;//how many values are stored and plotted
int prevX = 0;//for plotting
int prevY = 0;
int totalCounter = 0;
int textX;
int textY;

//color constants
final int BLACK = #000000;
final int GREY = #808080;
final int WHITE = #FFFFFF;
final int RED = #FF0000;

//location constants
final int BUTTON_RADIUS = 40;

final int ZBUTTON_X = 75;
final int ZBUTTON_Y = 800;

final int WBUTTON_X = 150;
final int WBUTTON_Y = 800;

final int LBUTTON_X = 225;
final int LBUTTON_Y = 800;

final int PBUTTON_X = 300;
final int PBUTTON_Y = 800;

final int HEIGHT = 1000;
final int WIDTH = 1000;

//other graph constants
final int GSX = 8;//graph scale x
final int GSY = 4;//graph scale y, inverse

final int MINIMUM_GRAPH_VALUE = 0;//value below which data points are cut off
final int INCREMENT = 100;//y-axis graph marker increment

final int OFFSETX = 70;//x-axis offset from left of screen
final int OFFSETY = 2 * HEIGHT / 3;//y-axis offset from top of screen

void setup() {
  size(1000, 1000);
  
  //initialize Serial object (this is our Mega)
  arduino = new Serial(this, "COM3", 57600);
  arduino.clear();
  
  //create table to store logged data
  table = new Table();
  table.addColumn("Millis");
  table.addColumn("Time");
  table.addColumn("Pressure (Pa)");
  table.addColumn("Zero Pressure (Pa)");
}

void draw() {
  //if there are bytes in the Serial port
  if(arduino.available() > 0){
     //read the line in the Serial port
     fromSrl = arduino.readStringUntil('\n');
     //if the String exists
     fromSrl = trim(fromSrl);
     if(fromSrl != null && !fromSrl.equals("")){
       //try to parse the string as an integer, this is our pressure reading (in Pa)
       try{
         pAbs = Integer.parseInt(fromSrl);
         pGage = pAbs - zeroLevel;
       } catch(Exception e){
         print("Error Caught");
       }    
   }  
  }
  
  //if logging is on, add this data point to the table
  if(loggingActive){
    updateTable();
  }
  
  if(plottingActive){
    updateLivePlot();
  }
  
  drawGUI();
}

void mouseClicked(){
  //Plot Button
  if(abs(mouseX - PBUTTON_X) < BUTTON_RADIUS && abs(mouseY - PBUTTON_Y) < BUTTON_RADIUS/2){
    plottingActive = !plottingActive;
    print("Plotting: " + plottingActive);
    if(!plottingActive){
      totalCounter += wave.size();
      wave.clear();
    }
  }
  
  //Zero Button
  if(abs(mouseX - ZBUTTON_X) < BUTTON_RADIUS && abs(mouseY - ZBUTTON_Y) < BUTTON_RADIUS/2){
    totalCounter += wave.size();
    wave.clear();
    zeroLevel = pAbs; 
    zeroedOnce = true;
    print("Zeroed");
    println(str(mouseX)+","+str(mouseY));
  }
  
  //Write Button
  if(abs(mouseX - WBUTTON_X) < BUTTON_RADIUS && abs(mouseY - WBUTTON_Y) < BUTTON_RADIUS){
    saveTable(table,fileName);
    print("Log Saved");
  }  
  
  //Logging Button
  if(abs(mouseX - LBUTTON_X) < BUTTON_RADIUS && abs(mouseY - LBUTTON_Y) < BUTTON_RADIUS){
    loggingActive = !loggingActive;
    print("Logging " + loggingActive);
  }  
}

void drawGUI(){
  background(WHITE);
  
  //draw buttons and populate with text
  rectMode(CORNER);
  
  fill(BLACK);
  rect(0,1.05 * OFFSETY,width/2,height/3);
  
  fill(BLACK);
  rect(width/2,1.05 * OFFSETY,width/2,height/3);
  
  fill(WHITE);
  rectMode(RADIUS);
  rect(ZBUTTON_X,ZBUTTON_Y,BUTTON_RADIUS,BUTTON_RADIUS);
  rect(LBUTTON_X,LBUTTON_Y,BUTTON_RADIUS,BUTTON_RADIUS);
  rect(WBUTTON_X,WBUTTON_Y,BUTTON_RADIUS,BUTTON_RADIUS);
  rect(PBUTTON_X,PBUTTON_Y,BUTTON_RADIUS,BUTTON_RADIUS);
  
  fill(BLACK);
  textAlign(CENTER);
  textSize(20);
  text("ZERO",ZBUTTON_X,ZBUTTON_Y + 5);
  text("LOG\nON/OFF",LBUTTON_X,LBUTTON_Y - 10);
  text("WRITE\nDATA",WBUTTON_X,WBUTTON_Y - 10);
  text("PLOT\nON/OFF",PBUTTON_X,PBUTTON_Y - 10);
  
  fill(WHITE);
  text("Zero Level: " + zeroLevel + "Pa",width/2,1.2*OFFSETY);
  if(plottingActive){
    text("Current Reading: " + pGage + "Pa Gauge",width/2,1.3*OFFSETY);
  }
  text("Logging Active: " + loggingActive,3*width/4,1.2 * OFFSETY);
  text("Plotting Active: " + plottingActive,3*width/4,1.3*OFFSETY);
  fill(BLACK);
  
  prevX = 0;
  prevY = 0;
  
  for(int i = 0; i < wave.size(); i++){
      strokeWeight(1);
      stroke(RED);
      newY = (Integer)wave.get(i);
      
      x1 = OFFSETX + (prevX * GSX);
      
      x2 = OFFSETX + (i * GSX);
      
      y1 = OFFSETY - (prevY / GSY);
      
      y2 = OFFSETY - (newY / GSY);
      
      if(y2 > OFFSETY){
        y2 = OFFSETY;
      }
      
      if(y1 > OFFSETY){
        y1 = OFFSETY;
      }
      
      line(x1,y1,x2,y2);
      
      strokeWeight(1);
      stroke(BLACK);
      
      prevX = i;
      prevY = (Integer)wave.get(i); 
    
      //draw x-axis numbers
      for(int k = 0;k < (2 * (width - OFFSETX)) / INCREMENT;k++){
        text(totalCounter + (INCREMENT * k / 2),OFFSETX + (INCREMENT*GSX*k / 2),OFFSETY+20);
      }
    }

  textSize(20);
  int j = 0;
  while(OFFSETY - (j * INCREMENT / GSY) > 50){
    textX = OFFSETX - 30;
    textY = OFFSETY - (j * INCREMENT / GSY);
    text(str(j * INCREMENT),textX,textY);
    line(textX + 15,textY,width,textY);
    j++;
  }
  text("Gauge Pressure (Pa)",OFFSETX + 20,30);
  line(OFFSETX,OFFSETY,OFFSETX,50);
  textSize(40);
 }

void updateLivePlot(){
  //add gage pressure to plotting waveform
  wave.add(pGage);
  //remove old data from plotting waveform
  if(wave.size() >= waveLength){
    wave.clear();
    prevX = 0;
    prevY = 0;
    totalCounter += waveLength;
  }
}

void updateTable(){
  long mil = millis();
  int h = hour();
  int min = minute();
  int s = second();
  TableRow newRow = table.addRow();
  newRow.setString("Pressure (Pa)",str(pAbs));
  newRow.setString("Zero Pressure (Pa)",str(zeroLevel));
  newRow.setString("Time",str(h) + ":" + str(min) + ":" + str(s));
  newRow.setString("Millis", str(mil));
}
