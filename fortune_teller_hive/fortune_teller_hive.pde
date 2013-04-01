// -----------------------
// ----
// This is based on code by  @@@ Jer Thorp @@@
// From http://blog.blprnt.com/blog/blprnt/updated-quick-tutorial-processing-twitter
// Awesome!
// NOTE - you have to have thw twitter4j library installed in the libraries folder for this to work!
// version 5 - trying to add GUI elements, based on 
// controlP5 GUI Library by @@@ Andreas Schlegel @@@, 2012. sojamo.de
// http://www.sojamo.de/libraries/controlP5/
// For positioning see (also @@@ Andreas Schlegel @@@) - 
// https://code.google.com/p/controlp5/source/browse/trunk/examples/controlP5button/controlP5button.pde?r=6
// ----
// -----------------------


// define Twitter Developer keys (you need to register your app to get one of these
// Obviously these four variables are not real Twitter strings ones
// You need to register yor app on Twitter developer site, and get these keys.
// You can put them in a separate tab in your sketch
//String twitOAuthConsumerKey="xxxxxxxxxxxxxxx";
//String twitOAuthConsumerSecret="yyyyyyyyyyyyyyyyyyyy";
//String twitOAuthAccessToken="zzzzzzzzzzzzzzzzzzzzzzzz";
//String twitOAuthAccessTokenSecret="wwwwwwwwwwwwwwwwwwwwwwwwww";
// -----

String tweetTextIntro = "Hive fortune reading for ";
int tweetTextOutro = int (random(99));
String tweetSendTrigger ="fireTweet";

String fortuneGreeting = "Hello. I have stared deep. into the hive mind. Your fortune reading is."; 
String tfUserCurrent =""; // used to check what is in the username text box
String tfTextCurrent =""; // used to check what is in the free-text text box
//Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> words = new ArrayList();
ArrayList<String> hashtags = new ArrayList();
ArrayList<String> usernames = new ArrayList();
ArrayList<String> urls = new ArrayList();
String adminSettings [] = {
  "#museumnext", "@museumnext", "", "500"
};

import controlP5.*; // import the GUI library
//import twitterOAUTH.*;// import the twitter handshake keys
ControlP5 cp5; // creates a controller I think!
ControlFont font;
controlP5.Button b;
controlP5.Textfield tf;
controlP5.Textfield tfRand;
controlP5.Textlabel tfAlert;
controlP5.Textlabel lb;

// ---------------
// --- import GURU text-to-speech library
import guru.ttslib.*; // NB this also needs to be loaded (available from http://www.local-guru.net/projects/ttslib/ttslib-0.3.zip)
TTS tts; // create an instance called 'tts'
// ---
//----------------

// ---------------
// --- import standard processing Serial library 
import processing.serial.*;
Serial port; // create an instance called 'port'
// ---
// ---------------

//  ------------- needed to stop Twitter overpolling from within sendTweet
float tweetTimer = 5000; // wait period (in milliseconds) after sending a tweet, before you can send the next one
float timerT=millis(); // temporary timer for sendTweet
float delayCheck; //delayCheck; // THIS IS IMPORTANT. it i what stops overpollin g of the Twitte API
//  ---------------

void setup() {
  tts = new TTS();
  //Set the size of the stage, and the background to black.
  size(550, 550);
  background(0);
  // now draw the admin panel
  println(Serial.list());// display communication ports (use this in test to establish fee ports)
  //if (Serial.list()[2] != null){ // error handling for port death on PC
  port = new Serial(this, Serial.list()[2], 115200); 
  //}

  //PFont font = createFont("arial",20);
  font = new ControlFont(createFont("arial", 100), 15);

  // ------------------
  noStroke();
  cp5 = new ControlP5(this); // adds in a control instance to add buttons and text field to



  noStroke();
  tf = cp5.addTextfield("Enter your twitter username");
  tf.setPosition(10, 475);
  // tf.setStringValue("@");
  tf.setSize(250, 25);
  tf.setFont(font);
  tf.setFocus(true);
  //tf.setAutoClear(true);
  tf.setColor(color(255, 255, 255));
  tf.setText ("@");
  tf.captionLabel().setControlFont(font);
  // @@@ 
  tfRand = cp5.addTextfield("Enter random msg text");
  tfRand.setPosition(10, 415);
  // tf.setStringValue("@");
  tfRand.setSize(250, 25);
  tfRand.setFont(font);
  tfRand.setFocus(false);
  //tf.setAutoClear(true);
  tfRand.setColor(color(255, 255, 255));
  tfRand.setText ("");
  tfRand.captionLabel().setControlFont(font);

  // @@@

  tfAlert = cp5.addTextlabel("please wait");
  tfAlert.setPosition(150, 400);
  tfAlert.setSize(250, 25);
  tfAlert.setFont(font);

  //tf.setAutoClear(true);
  tfAlert.setColor(color(255, 255, 255));
  tfAlert.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  tfAlert.setText ("Reading the twitter hive mind");

  //tfAlert.setVisible(false) 
  tfAlert.captionLabel().setControlFont(font);



  // create a new button with name 'Tell my Fortune'
  b = cp5.addButton("Press to tell your fortune", 20, 100, 50, 80, 20);
  b.setId(2);  // id to target this element
  b.setWidth(250); // width
  b.setHeight(25);
  b.setPosition(290, 475);

  b.captionLabel().setControlFont(font);
  b.captionLabel().style().marginLeft = 1;
  b.captionLabel().style().marginTop = 1;
  b.setVisible(true);
  b.isOn();


  //


  // -----------------

  smooth();
  // Now call tweeting action functions...
  grabTweets();
  println ("finished grabbing tweets");
  println ();
}

void draw() {
  //Draw a faint black rectangle over what is currently on the stage so it fades over time.
  fill(0, 20); // change the latter number to make the fade deeper (from 1 to 20 is good)
  rect(0, 0, width, height);
  // ---------------
  // WORDS
  //Draw a word from the list of words that we've built
  int i = (frameCount % words.size());
  String word = words.get(i);

  // HASHTAGS
  //Draw a hashtag from the list of words that we've built
  int j = (frameCount % hashtags.size());
  String hashtag = hashtags.get(j);
  
  // USERNAMES
  //Draw a username from the list of words that we've built
  int k = (frameCount % usernames.size());
  String username = usernames.get(j);
  
  // URLS
  //Draw a url from the list of words that we've built
  int l = (frameCount % urls.size());
  String url = urls.get(l);
  
  //-------------
  //Put it somewhere random on the stage, with a random size and colour
  fill(255, random(50, 150));
  textSize(random(15, 30));
  // next line is what is getting printed to the screen... 
  text(url, random(width), random(height));
  fill(255, random(50, 150));
  textSize(random(20, 40));
  text("#"+hashtag, random(width), random (height));
  // --------------
  // --------------
  // following is for text boxes
  color c1 = color(70, 130, 180);
  fill (c1);
  rect(0, 400, 550, 150);
  tfUserCurrent=tf.getText() ; //check the text box content every loop
  tfTextCurrent=tfRand.getText(); 
  buttonCheck(tfTextCurrent); // on screen check button every loop 
  checkSerial() ; // check serial port every loop
}

void sendTweet (String tweetText) {
  //@@@
  timerT=millis();  // reset the timer each time


  if (timerT-delayCheck>=tweetTimer)
    // this is needed to prevent sending multiple times rapidly to Twitter 
    // which will be frowned upon!
  {
    delayCheck=millis();

    println("tweet being sent");
    println("tfUserCurrent = "+ tfUserCurrent);
    String fortune = tweetTextIntro + tfUserCurrent + " from "+tweetText+ ", " +tfTextCurrent+". "+tweetTextOutro;
    String fortuneSpoken = (fortuneGreeting + tfUserCurrent+ "How. do. you. feel about. "+fortune);
    tts.speak(fortuneSpoken);
    println("tweet Send actions complete over");
    println();

    //@@@
    ConfigurationBuilder cb2 = new ConfigurationBuilder();
    // ------- NB - the variables twitOAuthConsumerKey, etc. need to be in a 
    // seperate 
    cb2.setOAuthConsumerKey(twitOAuthConsumerKey);
    cb2.setOAuthConsumerSecret(twitOAuthConsumerSecret);
    cb2.setOAuthAccessToken(twitOAuthAccessToken);
    cb2.setOAuthAccessTokenSecret(twitOAuthAccessTokenSecret);

    Twitter twitter2 = new TwitterFactory(cb2.build()).getInstance();

    try {
      Status status = twitter2.updateStatus(fortune);
      println("Successfully tweeted the message: "+fortune + " to user: [" + status.getText() + "].");
      delayCheck=millis();
    } 
    catch(TwitterException e) { 
      println("Send tweet: " + e + " Status code: " + e.getStatusCode());
    } // end try
    b.setWidth (250);
  }
}

void grabTweets() {
  //Credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("twitOAuthConsumerKey");
  cb.setOAuthConsumerSecret("twitOAuthConsumerSecret");
  cb.setOAuthAccessToken("twitOAuthAccessToken");
  cb.setOAuthAccessTokenSecret("twitOAuthAccessTokenSecret");

  //Make the twitter object and prepare the query
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  Query query = new Query(adminSettings[1]);
  query.setRpp(int(adminSettings[3])); // rrp is the number of tweets returned per page
  // The factory instance is re-useable and thread safe.

  //Try making the query request.
  try {
    QueryResult result = twitter.search(query); // gets the query
    ArrayList tweets = (ArrayList) result.getTweets(); // creates an array to store tweets in
    // then fills it up!
    for (int i = 0; i < tweets.size(); i++) {
      Tweet t = (Tweet) tweets.get(i);
      String user = t.getFromUser();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet by " + user + " at " + d + ": " + msg);

      //Break the tweet into words
      String[] input = msg.split(" ");
      for (int j = 0;  j < input.length; j++) {
        //  Put each word into the words ArrayList
        words.add(input[j]);
        //  Check each word and if starts with a # add to a list of hashtags
        println("--------------- start");
        String hashtag= input[j];
        println ("hashtag= "+hashtag);
        String hashtagArray[] = hashtag.split("#");
        println ("hashtagArray = ");
        println(hashtagArray);
        println();
        if (hashtagArray.length>1)
        {
          println ("inside checker");
          hashtags.add(hashtagArray[1]);
          println ("hashtagArray["+j+"]= "+hashtagArray[1]);
          println();

          println();
        }
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@
        String username= input[j];
        println ("username= "+username);
        String usernameArray[] = username.split("@");
        println ("usernameArray = ");
        println(usernameArray);
        println();
        if (usernameArray.length>1)
        {
          println ("inside checker");
          usernames.add(usernameArray[1]);
          println ("usernameArray["+j+"]= "+usernameArray[1]);
          println();
        }
        
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@
        //@@=====
        String url =input[j];
        String urlArray[] = url.split("h");
        if (urlArray.length>1)
        {
          
          println ("urlArray["+j+"]= "+urlArray[1]);
          String urlArray2[] = urlArray[1].split("t");
            if (urlArray2.length>2)
        {
           urls.add(url);
        }
          println("@@@@@@@@@@@@@@@@@@@@@@@@");

          println();
        } 
        //========
        println("------------- end");
        println();

        //@@
      }
    };
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  };
}

void buttonCheck(String tweetTextIntro)
{

  if (b.isPressed()) {

    println("button being pressed");
    sendTweet ("digital (onscreen) Button");
    b.setWidth(50);
    // action for onscreen button press
  }
}

void checkSerial() {
  while (port.available () > 0) {

    String inByte = port.readString();
    println ("Safe from OUSIDE IF . inByte = "+inByte);
    int w=int(random(150));
    b.setWidth(w);


    println ();

    port.clear();
    sendTweet ("physical Button");
  }
}
