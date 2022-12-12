#include <Wire.h>
#include <SparkFun_MicroPressure.h>

#define EOC_PIN 2
#define RES_PIN -1
#define MIN_PRESS 0
#define MAX_PRESS 25
#define I2C_ADDRESS 0x18
#define WIRE_PORT Wire

long reading;
long sum;
long nSamples = 10;

SparkFun_MicroPressure sensor(EOC_PIN,RES_PIN,MIN_PRESS,MAX_PRESS);

void setup() {
  Serial.begin(57600);
  Wire.begin();

  pinMode(EOC_PIN,INPUT);

  if(!sensor.begin(I2C_ADDRESS,WIRE_PORT))
  {
    Serial.println("ERROR");
  }
}

void loop() {
  for(int i = 0; i < nSamples; i++){
    sum += sensor.readPressure(PA);
  }
  reading = sum / nSamples;
  Serial.println(reading,DEC);
  delay(30);
  sum = 0L;
}
