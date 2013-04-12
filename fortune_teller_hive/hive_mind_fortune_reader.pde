// -----------------------
// ----
// Hive-Mind Fortune-Reader
// This sketch is the mind control or an automaton that can read the collective mind of twitter activity
// And feed it back to a physical automaton to create fortune readings...
//
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

// >>>>>>
boolean serialCheckInt=true;
boolean grabtweetCheckInt=true;
boolean loadSettingsCheckInt=true;
boolean loadstopWordsCheckInt=true;
// <<<<<< end load flags

//  >>>>> fortune textxs - make these external later #enhancement
String tweetTextIntro = "Hive fortune reading for ";
int tweetTextOutro = int (random(99));
String tweetSendTrigger ="fireTweet";
String fortuneGreeting = "Hello. I have stared deep. into the hive mind. Your fortune reading is."; 
// <<<<<<

// >>>>>>
String tfUserCurrent =""; // used to check what is in the username text box
String tfTextCurrent =""; // used to check what is in the free-text text box
// <<<<<<

// >>>>>> Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> stopWords = new ArrayList();
ArrayList<String> cleanTweets = new ArrayList();
ArrayList<String> words = new ArrayList(); 
ArrayList<String> hashtags = new ArrayList();
ArrayList<String> usernames = new ArrayList();
ArrayList<String> urls = new ArrayList();
// <<<<<<

// >>>>> adminSetting
String adminSettings [] = {
  "#hivemind", "@rosemarybeetle", "weird", "100"
}; 
// <<<<<< fill with defaults in case remote settings don't load 

// >>>>>> GUI library and settiongs
import controlP5.*; // import the GUI library
ControlP5 cp5; // creates a controller I think!
ControlFont font;
controlP5.Button b;
controlP5.Textfield tf;
controlP5.Textfield tfRand;
controlP5.Textlabel tfAlert;
controlP5.Textlabel lb;
// <<<<<<<


// >>>>>>>  import GURU text-to-speech library
import guru.ttslib.*; // NB this also needs to be loaded (available from http://www.local-guru.net/projects/ttslib/ttslib-0.3.zip)
TTS tts; // create an instance called 'tts'
// <<<<<<<

// >>>>>>> import standard processing Serial library 
import processing.serial.*;
Serial port; // create an instance called 'port'
// <<<<<<<

//  >>>>>> needed to stop Twitter overpolling from within sendTweet
float tweetTimer = 5000; // wait period (in milliseconds) after sending a tweet, before you can send the next one
float timerT=millis(); // temporary timer for sendTweet
float delayCheck; //delayCheck; // THIS IS IMPORTANT. it i what stops overpollin g of the Twitte API
//  <<<<<<


void setup() {
  tts = new TTS();
  loadRemoteAdminSettings(); // loads Twitter serch parameters from remote Google spreadsheet
  loadRemoteStopWords();// load list of stop words into an array, loaded from a remote spreadsheet
  //Set the size of the stage, 
  //size(550, 550); // TEST SETTING

  // >>>>>>> screen size and settings....
  size(screen.width-10, screen.height-10);// USE THIS SETTING FOR EXPORTED APPLICATION IN FULLSCVREEN (PRESENT) MODE
  background(0); // SET BACKGROUND TO BLACK
  // <<<<<<<

  // >>>>> Make initial serial port connection handshake
  println(Serial.list());// display communication ports (use this in test for available ports)
  try { 
    port = new Serial(this, Serial.list()[0], 115200);
  } 
  catch (ArrayIndexOutOfBoundsException ae) {
    // if errors
    println ("STOP - No PORT CONNECTION");
    println ("STOP - No PORT CONNECTION");
    println ("STOP - No PORT CONNECTION");
    println ("STOP - No PORT CONNECTION");
    println ("STOP - No PORT CONNECTION");
    println ("STOP - No PORT CONNECTION");
    println ("STOP - No PORT CONNECTION");
    println ("STOP - No PORT CONNECTION");
    println ("Exception = "+ae);  // print it
    println ("-------------------------");
    println ("-------------------------");
  }
  // <<<<<<<

  // >>>>>>> set up fonts
  //PFont font = createFont("arial",20);
  font = new ControlFont(createFont("arial", 100), 15);
  // <<<<<<<

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  set up GUI elements >>>>>>>>>>>>>>>>>>>>
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
  tfRand = cp5.addTextfield("Enter random msg text"); // where you add in tweet text strings
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


  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end of GUI <<<<<<<<<<


  // >>>>>>>>
  smooth();
  // Now call tweeting action functions...
  grabTweets();
  println ("finished grabbing tweets");
  println ();
  println ();
}  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end of setup()  <<<<<<<<<<<<<<<<<<<<<<<<<<


void draw() {

  // >>>>>> Draw a faint black rectangle over what is currently on the stage so it fades over time.
  fill(0, 20); // change the latter number to make the fade deeper (from 1 to 20 is good)
  rect(0, 0, width, height);
  // <<<<<<

  // >>>>>>> WORDS
  // Draw a word from the list of words that we've built (using FRAMECOUNT - THIS INCREMENTS BY +1 EVERY REDRAW - %=MODULO)
  int i = (frameCount % words.size());
  String word = words.get(i);
  println ("word = "+word+" #"+i);
  // <<<<<<<

  // >>>>>>> HASHTAGS
  //Draw a hashtag from the list of words that we've built
  int j = (frameCount % hashtags.size());
  String hashtag = hashtags.get(j);
  // <<<<<<<

  // >>>>>> USERNAMES
  //Draw a username from the list of words that we've built
  int k = (frameCount % usernames.size());
  String username = usernames.get(k);
  // <<<<<<

  // >>>>>> URLS
  //Draw a url from the list of words that we've built
  int l = (frameCount % urls.size());
  String url = urls.get(l);
  // <<<<<<

  // create a random fortune ---
  // println ("testFortune= Think about: "+words.get(int(random(i)))+" or talk to "+usernames.get(int(random(k)))+" or visit "+urls.get(int(random(l)))+". Totally "+hashtags.get(int(random(j))));

  //-------------
  // >>>>> Put url somewhere random on the stage, with a random size and colour
  fill(0,25,89, 255);
  textSize(random(10, 20)); 
  text(url, random(width), random(height)); // 
  // <<< SEND URL TO THE SCREEN

  // >>> SEND HASHTAG TO THE SCREEN WITH DIFFERENT SIZE ETC 
  fill(255, 0,0,255);
  textSize(random(10, 15));
  text("#"+hashtag, random(width), random (height));
  // <<< END SEND HASHTAG#

  // >>>SEND WORD TO SCREEN ALSO WITH DIFFERENT SETTINGS
  textSize(random(15, 30));
  fill(255,255);
  text(word, random(width), random (height));
  // <<< END SEND WORD

  // >>> SEND USERNAME TO SCREEN
  fill(0,255, 22,random(50, 100));
  textSize(random(10, 15));
  text("@"+username, random(width), random (height));
  // <<< END SEND USERNAME


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
// >>>>>>>>>>>>>>>>>>>>>>>> SEND THAT TWEET >>>>>>>>>>>>>>>
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
// <<<<<<<<<<<<<<<<<<<<<<<<< END SEND TWEETS <<<<<<<<<<<<<<<

// >>>>>>>>>>>>>>>>>>>>>>>>> GRAB THOSE TWEETS  >>>>>>>>>>>>>
void grabTweets() {
  //Credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("twitOAuthConsumerKey");
  cb.setOAuthConsumerSecret("twitOAuthConsumerSecret");
  cb.setOAuthAccessToken("twitOAuthAccessToken");
  cb.setOAuthAccessTokenSecret("twitOAuthAccessTokenSecret");

  //Make the twitter object and prepare the query
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  Query query = new Query(adminSettings[0]); // this is assuming you check the first of 4 admin settings, but should be extended to include passing a selctor param

  query.setRpp(int(adminSettings[3])); // rrp is the number of tweets returned per page
  // The factory instance is re-useable and thread safe.

  //Try making the query request.
  try {
    QueryResult result = twitter.search(query); // gets the query
    ArrayList tweets = (ArrayList) result.getTweets(); // creates an array to store tweets in
    // then fills it up!

    println ("number of tweets = "+tweets.size());
    for (int i = 0; i < tweets.size(); i++) {
      Tweet t = (Tweet) tweets.get(i);
      String user = t.getFromUser();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet #"+i+" by " + user + " at " + d + ": " + msg);

      //Break the tweet into words
      String[] input = msg.split(" ");
      for (int j = 0;  j < input.length; j++) {
        cleanTweets.add(input[j]);
        for (int ii = 0 ; ii < stopWords.size(); ii++) {

          if (stopWords.get(ii).equals(input[j])) {
            cleanTweets.remove(input[j]);
            println("Word removed due to matched stopword: "+input[j]);
          }
        }
      }
      println ("cleanTweets = "+cleanTweets);
    }for (int j = 0;  j < cleanTweets.size(); j++) {
        words.add(cleanTweets.get(j));

        // >>>>>> make the list of hashtags
        String hashtag= cleanTweets.get(j);
        //println ("hashtag= "+hashtag);
        String hashtagArray[] = hashtag.split("#");
        if (hashtagArray.length>1)
        {
          //println ("inside checker");
          hashtags.add(hashtagArray[1]);
          words.remove(hashtagArray[1]);
          //println ("hashtagArray["+j+"]= "+hashtagArray[1]);
        }
        // <<<<<<<

        // >>>>>>> set up list of usernames
        String username= cleanTweets.get(j);
        String usernameArray[] = username.split("@");
        // println ("usernameArray = ");
        //println (usernameArray);
        if (usernameArray.length>1)
        {
          usernames.add(usernameArray[1]);
          words.remove(usernameArray[1]);
          // println ("usernameArray["+j+"]= "+usernameArray[1]);
        }
        // <<<<<<<<

        // >>>>>>>> set up urls >>>>>>
        String url = cleanTweets.get(j);
        String urlArray[] = url.split("h");
        if (urlArray.length>1)
        {
          String urlArray2[] = urlArray[1].split("t");
          if (urlArray2.length>2)
          {
            urls.add(url);
            words.remove(url);
          }
          // <<<<<<<<<< end

          // >>>>>>>>>>
        
      }
    };
    println ("LLLLLLLLLLLLLL");
    println ("words = "+words);
  } // <<<<<< end try 
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  }; // <<<<<< end catch
} // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end grabTweets() <<<<<<<<

// >>>>>>>>>>>>>>>>>>>
void buttonCheck(String tweetTextIntro)
{
  if (b.isPressed()) {
    println("button being pressed");
    sendTweet ("digital (onscreen) Button");
    b.setWidth(50);
    // action for onscreen button press
  }
}
// <<<<<<<<<<<<<<<<<<<<<<< end of BUTTONCHECK

// >>>>>>>>>>>>>>> check the open serial port >>>>>>>>>>
void checkSerial() {
  try {
    // >>>>>> see if the port is sending you stuff
    while (port.available () > 0) {
      String inByte = port.readString();
      println ("Safe from OUSIDE IF . inByte = "+inByte);
      int w=int(random(150));
      b.setWidth(w);
      println ();
      port.clear();
      sendTweet ("physical Button");
    }
  } // end try
  catch (NullPointerException npe) {
    println ("Check serial exception = "+npe);
  }
} // <<<<<<<<<<<<<<<<<<<<< end checkSerial <<<<<<<<<<<<<<<<<<<<<


// >>>>>>>>>>>>>>>>>>> load remote  admin settings   >>>>>>>>>>>>>>
void loadRemoteAdminSettings ()
{
  adminSettings = loadStrings("https://docs.google.com/spreadsheet/pub?key=0AgTXh43j7oFVdFNOcGtMaXZnS3IwdTJacllUT1hLQUE&output=txt");
  if (loadSettingsCheckInt==true)
  {  
    for (int i = 0 ; i < adminSettings.length; i++) {
      println("adminSettings["+i+"]= "+adminSettings[i]);
    }
    loadSettingsCheckInt =false;
  }
}

// >>>>
void loadRemoteStopWords ()
{
  String stopWordsLoader [] = loadStrings("https://docs.google.com/spreadsheet/pub?key=0AgTXh43j7oFVdFByYk41am9jRnRkeU9LWnhjZFJTOEE&output=txt");
  if (loadstopWordsCheckInt==true)
  {
    for (int i = 0 ; i < stopWordsLoader.length; i++) {
      //stop
      stopWords.add(stopWordsLoader[i]);
      println("stopWords["+i+"]= "+stopWords.get(i)+". Length now: "+stopWords.size());
    }
    loadstopWordsCheckInt=false;
  }
}
