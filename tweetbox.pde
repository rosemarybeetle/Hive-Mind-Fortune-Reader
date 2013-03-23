/*

 alewis cc-zero licence
 [06/10/2012] virtual_twitr_janus_15 - Starting point for this sketch
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/
import processing.serial.*;
import guru.ttslib.*; // NB this also needs to be loaded (available from http://www.local-guru.net/projects/ttslib/ttslib-0.3.zip)
Serial port;
TTS tts;

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// @@@@@@@@@@@@@@@@ BETWEEN FIVE LINE BARS, CODE NOT USED IN hashtag_avatar @@ >>>>>>>>>>>>>
color faceColour = color (255, 240, 240);
color off = color(4, 79, 111);
color on = color(84, 145, 158);
int chompFactor = 3; // this is to scale down the length of the received data 
int chompDelay = 50; // gap between chomps up and chomps down in milliseconds
int chompRand = 100;



//  <<<<<<@@@@@@@@@@@@@@@@ END OF: NOT (OR NOT YET) USED IN hashtag_avatar <<<<<<<<<<<<
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------


// @@@@@@@@@@ Googlespreadsheet variables
String gssText="initialised"; // will be used store data to use for eyeball servo
String gssTextCheck = gssText;
int gssTextLength = 0; // initialise text length for reading from Google Spreadsheet
int gssTimer=0; // used to reset timer for Google spreadsheet calls
int gssPeriod = 2500; // interval between checks on google spreadsheet
//String gssApiString = "https://docs.google.com/spreadsheet/tq?key=0AgTXh43j7oFVdDJSaHU1ejFqdVRTZU1ZZ1Fabmt2UXc&range=E2%3AG2&headers=0";
String gssApiString = "https://spreadsheets.google.com/feeds/list/0AgTXh43j7oFVdFZJdklXTU1lTzY5U25sc3BJNjRLRUE/od6/public/basic?alt=rss";
// @@@@@@@@@@ Googlespreadsheet end

// ---------------------------------------------------------------------------------------------

// @@@@@@@@@@ Twitter checking or initialising variables 
int currentM = millis(); // used to store sets current time since app launched in milliseconds
int timer = 0; // a timer variable to compare it with to see if a fixed period is over
int period =29000; // this is the interval between checks made for new tweets
String tweetText = "initialised";
String tweetCheck = tweetText;
int tweetLength = 0; // used to measure length of incoming tweet
String twitterUsername = "twitr_janus";
// @@@@@@@@@@ Twitter end

// ---------------------------------------------------------------------------------------------


void setup ()
{
  tts = new TTS();
  size(50, 600);  
  background (faceColour);
  
  println(Serial.list());// display communication ports (use this in test to establish fee ports)
     port = new Serial(this, Serial.list()[1], 115200); 
  getGssData();
  getTweet();
   //
}

void draw ()
{
  currentM= millis();
  if (currentM-gssTimer > gssPeriod)
  {
    gssTimer=currentM; // reset gssTimer to current time elapsed since start
    getGssData ();
  }

  if (currentM-timer > period) { //this is checking tweet based upon a time interval"period"
    getTweet();
    timer=currentM;
    println ("Timer = "+currentM);
  } //@@ end  period @@
}

//---------------functions from processing_PC
void drawBox() {
  background(off);
  stroke(on);
  int intx=0;
  int inty=120;
  if (count>countStop) {
    count=0;
    movex=0;
    f = random(20000);
    bk =int(f);
  } 
  else {
    if (rectHeight>120)
    {
      rectHeight=0;
    } 
    else
    {
      rectHeight+=1;
    };
    count++;
    movex+= spacer;
  };

  //background(bk); 
  color c1 = color(3, 88, 170);
  fill(c1);
  noStroke();
  rect(intx+movex, inty, 55, 55 );
}
void getTweet ()
{
  String hashtag="bits2blogs"; // change this as required
  // uses Twitter API to get public tweets from username (sent in function argument)

  tweetCheck = tweetText;
  
  try {String twitterApiString = "http://search.twitter.com/search.json?q=%23"+hashtag+"&rpp=1";
 if (twitterApiString != null )  {
    println ("@@@");
  println ("[Start Inside printTweet]");
  println ();
  String [] texty = loadStrings(twitterApiString);
  String [] texty2 = split (texty[0], '"');
  int chainlink=75;
   String [] texty3 = split (texty2[chainlink], ':');
  println ("texty3= "+ texty2 [chainlink]);
 //tweetText = texty3[1];
  tweetText = texty3[0];
  tweetLength= texty3.length; // get number of elements in the final array
  for (int i=1;i<tweetLength;i++)
  {
  tweetText +=texty3[i]; 
  }
  println ("tweetText is loaded with the last tweet from Rosemarybeetle was: ");
  //println (currentTweet);
  println (tweetText);
  println ();
  println ("and...");
  println ();
  println ("tweetLength ="+tweetLength);
  // following lines return the contents of tweet check (last new tweet)
  print ("tweetCheck value = ");
  println (tweetCheck);
  print ("tweetText length = ");
  println (tweetText.length());
  println ();
  println ("[End Inside printTweet]");
  println ("@@@");
  println ();

  if (tweetText.equals(tweetCheck)==false)
  {
     noLoop(); /// pause the polling
  println ("polling stopped inside getTweet");
 
    println ("inside tweet checking IF");
    print (tweetText);
    println ("@");
    print (tweetCheck);
    println ("@");
    
    port.write(30);
    
    tts.speak(tweetText);
    loop();  // restart the polling

  };
}// end null detection
  } catch (Exception e) {
  }//end try
} /// end get Tweet
void getGssData ()
{
  // uses Google SpreadSheets API to get public tweets from twitr_janus_eyeballs published spreadsheet

  gssTextCheck = gssText;

  println ("@@@");
  println ("[Start Inside printGSS]");
   
  println ();
  String [] texty = loadStrings(gssApiString);
  String [] texty2 = split (texty[0], '¬'); //  pulling out data with stop character

  String [] texty3 = split (texty2[4], '<'); // get rid of trailing text after <
  gssText = texty3[0];
  gssTextLength= gssText.length();
  // @@@@@@@@@@@@@@@@
  String [] texty4 = split (texty2[2], ',');
  gssEyeballUpDown = int (texty4 [0]);
  print ("gssEyeballUpDown = ");
  println (gssEyeballUpDown);
  println ();
  // @@@@@@@@@@@@@@@@
  String [] texty5 = split (texty2[3], ',');
  gssEyeballLeftRight = int (texty5 [0]);
  print ("gssEyeballLeftRight = ");
  println (gssEyeballLeftRight);
  println ();

  // @@@@@@@@@@@@@@@@
  println ();
  print ("gssText = ");
  println (gssText);

  println ();
  // following lines return the contents of tweet check (last new tweet)

  println ("[End Inside getGSS]");
  println ("@@@");
  println ();

  if (gssText.equals(gssTextCheck)==false)
  {
     noLoop(); /// pause the polling
  println ("polling stopped inside 'gssTextCheck ()'");
    println ("inside GSS checking IF");
    print (gssText);
    println ("");
    print (gssTextCheck);
    println ("@");
    port.write(gssEyeballUpDown);// send up down value to board
    tts.speak(gssText);
  loop();
    // }
  };

}// end gssTextCheck;

// ------------------------------------------
void keyPressed() {
  // @@@@@@@@@@@@@@@@
  // these lines will be superceded by data from the Internet
  if (keyCode==49) {
    println (" key 1 pressed ");
    eyeHLT-=inc;
    eyeHRT-=inc;

    println ("eyeHLT = "+eyeHLT);
    println ("eyeHRT = "+eyeHRT);
  }
  if (keyCode==50) {
    println (" key 2 pressed ");
    eyeHLT+=inc;
    eyeHRT+=inc;

    println ("eyeHLT = "+eyeHLT);
    println ("eyeHRT = "+eyeHRT);
  }

  if (keyCode==57) {
    println (" key 9 pressed ");
    eyeVLT+=inc;
    eyeVRT+=inc;
  }
  if (keyCode==48) {
    println (" key 0 pressed ");
    eyeVRT-=inc;
    eyeVLT-=inc;
  } 
  // @@@@@@@@@@@@@@@@
  checkEyePos2();
}// end ifKeyPressed()

// @@@@@@@@@@@@@@@@@@@@@@@@@@@
void checkEyePos()
{
  checkH = eyeHLinit-eyeHL; //calculate if horizontal eye position has reached limit
  checkV = eyeVinit-eyeVL;
  checkHP = eyeHLinit-pupilHL; //calculate if horizontal pupil position has reached limit
  checkVP = eyeVinit-pupilVL;
  if ((checkH <0)) {
    negFactorH=-1;
  } 
  else if ((checkH >=0)) { 
    negFactorH=1;
  }
  if ((checkV <0)) {
    negFactorV=-1;
  } 
  else if ((checkV >=0)) { 
    negFactorV=1;
  }
  if ((checkHP <0)) {
    negFactorHP=-1;
  } 
  else if ((checkHP >=0)) { 
    negFactorHP=1;
  }
  if ((checkVP <0)) {
    negFactorVP=-1;
  } 
  else if ((checkVP >=0)) { 
    negFactorVP=1;
  }
  int checkZH = int (negFactorH*sqrt(sq(checkH)+sq(checkV)));
  int checkZV = int (negFactorV*sqrt(sq(checkH)+sq(checkV)));
  int checkZHP = int (negFactorHP*sqrt(sq(checkHP)+sq(checkVP)));
  int checkZVP = int (negFactorVP*sqrt(sq(checkHP)+sq(checkVP)));

  //if (key == CODED) 
  //{
  if (eyeHLT==1)
  {

    if (checkZH <(eyeDiameter/4)) {
      eyeHL-= inc; 
      eyeHR-= inc;
      println("EEK - eyeHL = "+eyeHL);
    }
    if (checkZHP <(eyeDiameter/4+(irisD/4))) {

      pupilHL-= incPupil;
      pupilHR-= incPupil;
    }
  } 
  else if (eyeHLT==3)
  {
    if (checkZH >=(-eyeDiameter/4)) {

      eyeHL+= inc; 
      eyeHR+= inc;
      println("EEK - eyeHL = "+eyeHL);
    }
    if (checkZHP >=(-eyeDiameter/4-(irisD/4))) {

      pupilHL += incPupil; 
      pupilHR += incPupil;
    }
  }
  if (eyeVLT==8)
  {
    if (checkZV <((eyeDiameter/4))) {

      eyeVL-=inc; 
      eyeVR-=inc;
      println("EEK - eyeVL = "+eyeVL);
    }

    if (checkZVP <(eyeDiameter/4+(irisD/4))) {

      pupilVL-= incPupil; 
      pupilVR -= incPupil;
    }
  }


  else if (eyeVLT==0)
  {
    if (checkZV >=(-eyeDiameter/4)) {

      eyeVL+=inc; 
      eyeVR+=inc;
      println("EEK - eyeVL = "+eyeVL);
    }
    if (checkZVP >=(-eyeDiameter/4-(irisD/4))) {

      pupilVL += incPupil; 
      pupilVR += incPupil;
    }
  } // end DOWN
  //}// end hey==coded
}// end checkEyePos ()

// -----------------------

void checkEyePos2()
{
  checkH = eyeHLinit-eyeHL; //calculate if horizontal eye position has reached limit
  checkV = eyeVinit-eyeVL;
  checkHP = eyeHLinit-pupilHL; //calculate if horizontal pupil position has reached limit
  checkVP = eyeVinit-pupilVL;
  if ((checkH <0)) {
    negFactorH=-1;
  } 
  else if ((checkH >=0)) { 
    negFactorH=1;
  }
  if ((checkV <0)) {
    negFactorV=-1;
  } 
  else if ((checkV >=0)) { 
    negFactorV=1;
  }
  if ((checkHP <0)) {
    negFactorHP=-1;
  } 
  else if ((checkHP >=0)) { 
    negFactorHP=1;
  }
  if ((checkVP <0)) {
    negFactorVP=-1;
  } 
  else if ((checkVP >=0)) { 
    negFactorVP=1;
  }
  int checkZH = int (negFactorH*sqrt(sq(checkH)+sq(checkV)));
  int checkZV = int (negFactorV*sqrt(sq(checkH)+sq(checkV)));
  int checkZHP = int (negFactorHP*sqrt(sq(checkHP)+sq(checkVP)));
  int checkZVP = int (negFactorVP*sqrt(sq(checkHP)+sq(checkVP)));

  //if (key == CODED) 
  //{
  if (eyeHLT<eyeHL)
  {

    eyeHL-= inc; 
    eyeHR-= inc;
    println("EEK - eyeHL = "+eyeHL);
  }

  if (eyeHLT>eyeHL) {

    eyeHL+= inc; 
    eyeHR+= inc;
    println("EEK - eyeHL = "+eyeHL);
  }

  if (eyeVLT<eyeVL)
  {
    eyeVL-=inc; 
    eyeVR-=inc;
    println("EEK - eyeVL = "+eyeVL);
  }

  if (eyeVLT>eyeVL) {
    eyeVL+=inc; 
    eyeVR+=inc;
    println("EEK - eyeVL = "+eyeVL);
  } // end DOWN
  //}// end hey==coded
}// end checkEyePos ()

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

void drawEyes ()
{
  drawHead();
  fill (0, 0, 255);

  ellipse (eyeHL, eyeVL, irisD, irisD);
  ellipse (eyeHR, eyeVR, irisD, irisD);
  fill (0, 0, 0);
  // use these if you want the pupils to move more realistically for 2d rendering
  //ellipse (pupilHR, pupilVR, pupilD, pupilD);
  //ellipse (pupilHL, pupilVL, pupilD, pupilD);
  // use these if you want pupils to move exactly with the iris (less realistic) 
  //ellipse (eyeHL, eyeVL, pupilD, pupilD);
  //ellipse (eyeHR, eyeVR, pupilD, pupilD);
}
void drawMouth ()
{
  fill (mouthColour);
  rect (lipUH, lipUV, lipWidth, lipHeight);
  rect (lipLH, lipLV, lipWidth, lipHeight);
  
  lipUV=lipUVshut;
  lipLV=lipLVshut;
  println ("shut");
  println ("lipUV = "+lipUV);
  println ("lipLVshut= "+lipLVshut);
  //drawEyes();

}
void drawHead () {
  //draw left eye
  background (faceColour);
  fill (eyeColor);
  ellipse (eyeHLinit, eyeVinit, eyeWidth, eyeHeight);
  //draw right eye
  ellipse (eyeHRinit, eyeVinit, eyeWidth, eyeHeight);
  // draw teeth
  for (int i=0; i<teethNum; i++) {
    rect (teethHLinit+(i*teethSpacer), teethVL, teethWidth, teethHeight);
  }
  drawMouth();
}
void updateEyeTargetPosition ()
{
  /*// first check it is not out of limits (that is, must be in Arduino range 0 - 180, the standard servo control range)
   if (gssEyeballUpDown<0)
   {
   gssEyeballUpDown = 0;
   } 
   else if (gssEyeballUpDown>180)
   {
   gssEyeballUpDown=180;
   }
   if (gssEyeballLeftRight<0)
   {
   gssEyeballLeftRight = 0;
   } 
   else if (gssEyeballLeftRight>180)
   {
   gssEyeballLeftRight=180;
   }
   */
  // map 

  // map(gssEyeballLeftRight, 0, 180, eyeHLmin, eyeHLmax);
  // map(gssEyeballUpDown, 0, 180, eyeVLmin, eyeVLmax);
  gssEyeballLeftRight = int (gssEyeballLeftRight);
  gssEyeballUpDown = int (gssEyeballUpDown);
  eyeHLT=gssEyeballLeftRight;
  eyeVLT=gssEyeballUpDown;

  println ("Inside updateEyeTargetPosition.");
  println ("gssEyeballLeftRight = "+gssEyeballLeftRight);
  println ("gssEyeballUpDown = "+gssEyeballUpDown);
  println("-----------");
  println ("eyeHL = "+eyeHL);
  println ("eyeHR = "+eyeHR);
  println ("eyeVL = "+eyeVL);
  println ("eyeVR = "+eyeVR);
  println("-----------");
  println ("eyeHLT = "+eyeHLT);
  println ("eyeHRT = "+eyeHRT);
  println ("eyeVLT = "+eyeVLT);
  println ("eyeVRT = "+eyeVRT);
  println("-----------");
  println ("eyeHLmin = "+eyeHLmin+", , eyeHLmax= " +eyeHLmax);
  println ("eyeVLmin = "+eyeVLmin+", , eyeHLmax= " +eyeVLmax);
}
void jawChomper () {
  lipTimer = millis();


  while ( (millis()- lipTimer) <lipOpenTimer) {
    lipUV=lipUVopen;
    lipLV=lipLVopen;
    drawEyes();

    println ("open");
    println ("lipLV = "+lipLV);
    println ("lipUV = "+lipUV);
    println ("lipLVopen= "+lipLVopen);
  } 

}
