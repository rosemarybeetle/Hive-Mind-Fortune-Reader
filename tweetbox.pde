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
float f = random(260000);
int bk =int(f);
int spacer=35;
int rectHeight=0;
int movex=0;
int count=0;
int countStop=40;
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
String gssText="initialised"; // will be used store data to use for eye ball servo
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
    //port.write(gssEyeballUpDown);// send up down value to board
    tts.speak(gssText);
  loop();
    // }
  };

}// end gssTextCheck;

// ------------------------------------------
