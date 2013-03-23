/*

 alewis cc-zero licence
 [06/10/2012] virtual_twitr_janus_15 - Starting point for this sketch
 [22/3/2012] tweetbox_2 - cleaned out redundant code
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
color faceColour = color (155, 240, 240);
color off = color(47, 79, 111);
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


// ---------------------------------------------------------------------------------------------

// @@@@@@@@@@ Twitter checking or initialising variables 
int currentM = millis(); // used to store sets current time since app launched in milliseconds
int timer = 0; // a timer variable to compare it with to see if a fixed period is over
int period =29000; // this is the interval between checks made for new tweets
String tweetText = "initialised";
String tweetCheck = tweetText;
int tweetLength = 0; // used to measure length of incoming tweet
String twitterUsername = "twitr_janus";
 String hashtag="museweb"; // change this as required
 
// @@@@@@@@@@ Twitter end

// ---------------------------------------------------------------------------------------------


void setup ()
{
  tts = new TTS();
  size(120,50);  
  background (faceColour);
  
  println(Serial.list());// display communication ports (use this in test to establish fee ports)
     port = new Serial(this, Serial.list()[1], 115200); 
  getTweet();
   //
}

void draw ()
{
  currentM= millis();
  drawBox();
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


// ------------------------------------------
