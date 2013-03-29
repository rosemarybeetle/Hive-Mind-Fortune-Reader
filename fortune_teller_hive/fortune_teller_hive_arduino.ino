/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */
 
// Pin 13 has an LED connected on most Arduino boards.
// give it a name:
int switchPin = A0; // Analogue in = A0, called switchSensor.
int led = 13;
int analogValue = 0; // this is used to determine whether to make a call to Twitter (if high) 

// the setup routine runs once when you press reset:
void setup() {   
  Serial.begin(115200);  
  Serial.write("Serial connection initiated");
  
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT);     
}

// the loop routine runs over and over again forever:
void loop() {
  // digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  //delay(1000);// wait for a second
  analogValue = analogRead(switchPin);   
  if (analogValue >=900) {
  Serial.println("fireTwitterCall");
  analogValue = 0; // reset - this is used to ensure the value is reset after a successful release of the switch
  }
 // digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  //delay(1000);               // wait for a second
}
