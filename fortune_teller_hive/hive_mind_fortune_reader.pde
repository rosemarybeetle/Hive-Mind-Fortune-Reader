
// -----------------------
// ----
// Hive-Mind Fortune-Reader
// This sketch is the mind control of an automaton that can read the collective mind of twitter activity
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
boolean loadSettingsFirstLoadFlag=true;
boolean loadstopWordsCheckInt=true;
// <<<<<< end load flags

//  >>>>> fortune textxs - make these external later #enhancement
int tweetTextOutro = int (random(99));
String tweetSendTrigger ="fireTweet";
String fortuneGreeting = "Hello. I have stared deep. into the hive mind. Your fortune reading is."; 
String fortune = "";
String fortuneSpoken = "";
int widthRandomiser = 120;
// <<<<<<

// >>>>>>
String tfUserCurrent =""; // used to check what is in the username text box
String tfTextCurrent =""; // used to check what is in the free-text text box
int valFocus = 0; // default
color focusBackgroundColor = color (255, 255, 00);
color focusOffBackgroundColor = color (0, 0, 0);
color focusOffColor = focusBackgroundColor ;
color focusColor = focusOffBackgroundColor;
color clPanel = color(70, 130, 180);
// <<<<<<

// >>>>>> Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> stopWords = new ArrayList();
ArrayList<String> cleanTweets = new ArrayList();
ArrayList<String> words = new ArrayList(); 
ArrayList<String> hashtags = new ArrayList();
ArrayList<String> usernames = new ArrayList();
ArrayList<String> urls = new ArrayList();
ArrayList tweetster = new ArrayList();
String uberWords [] = new String[0]; //massive array to build up history of words harvested
String queryString = ""; // 
String queryType = ""; //
// <<<<<<
String adminSettings [] = {
  "#hivemind", "@rosemarybeetle", "weird", "100", "50000", "h", "500", "Psychic Hive-Mind Fortune Reader", "Greetings Master. I am a-woken"
}; 

String tweetTextIntro="";
String readingSettingText="";
int panelHeight = 60; 
int border = 40;
int boxY = 515;
int boxWidth = 270;
int boxHeight = 40;
int columnPos2_X = 310;


// admin panel height
// <<<<<< fill with defaults in case remote settings don't load 

// >>>>>>  grabTweets Timer settings  >>>>>>>>>>>
float grabTime = millis();
float timeNow = millis();
String stamp = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute();// <<<<<<

// >>>>>> GUI library and settiongs
import controlP5.*; // import the GUI library
ControlP5 cp5; // creates a controller I think!
ControlFont font;
controlP5.Button b;
controlP5.Textfield tf;
controlP5.Textlabel lb;
// <<<<<<<


// >>>>>>>  import GURU text-to-speech library
import guru.ttslib.*; // NB this also needs to be loaded (available from http://www.local-guru.net/projects/lib/ttslib-0.3.zip)
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
  tts.speak(adminSettings[8]);// preloaded, not web
  println (" adminSettings 1 " + adminSettings);
  for (int i = 0 ; i < adminSettings.length; i++) {
    println("adminSettings["+i+"]= "+adminSettings[i]);
  }
  updateDisplayVariables();
  try {
    loadRemoteAdminSettings(); // loads Twitter search parameters from remote Google spreadsheet
    println ("adminSettings 2 "+adminSettings);
    tts.speak("I am connected to the web. Master.Your commands have been loaded into my brain");
  }  
  catch (Exception e) {
    tts.speak("I am sorry. I am not able to connect to the web. Your commands have not been loaded into my brain master");
  }
  loadRemoteStopWords();// load list of stop words into an array, loaded from a remote spreadsheet
  //Set the size of the stage, 
  //size(550, 550); // TEST SETTING

  // >>>>>>> screen size and settings....
  size(screen.width-border, screen.height-border);// USE THIS SETTING FOR EXPORTED APPLICATION IN FULLSCVREEN (PRESENT) MODE
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
  buildAdminPanel();

  smooth();
  // Now call tweeting action functions...
  grabTweets();

  println ("finished grabbing tweets");
  println ();
  println ();
}  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end of setup()  <<<<<<<<<<<<<<<<<<<<<<<<<<


void draw() {
  int panelTop= height-panelHeight;
  buttonCheck("HELLO"); // on screen check button every loop
 
  timeNow=millis();
  /*println (" "+timeNow);
   println ();
   println ("grabTime = "+grabTime);
   println ();
   println ("timeNow-grabTime = "+(timeNow-grabTime));
   */
  try {
    println ();
    if ((timeNow-grabTime)>float(adminSettings[4])) {
      grabTweets();
    }

    // >>>>>> Draw a faint black rectangle over what is currently on the stage so it fades over time.
    fill(0, 30); // change the latter number to make the fade deeper (from 1 to 20 is good)
    rect(0, 0, width, height-panelHeight);
    // <<<<<<

    // >>>>>>> WORDS
    // Draw a word from the list of words that we've built (using FRAMECOUNT - THIS INCREMENTS BY +1 EVERY REDRAW - %=MODULO)
    //int i = (frameCount % words.size());
    int i = (int (random (words.size())));
    String word = words.get(i);
    println ("word = "+word+" #"+i);

    // <<<<<<<

    // >>>>>>> HASHTAGS
    //Draw a hashtag from the list of words that we've built
    int j = (int (random (hashtags.size())));
    String hashtag = hashtags.get(j);
    // <<<<<<<

    // >>>>>> USERNAMES
    //Draw a username from the list of words that we've built
    int k = (int (random (usernames.size())));
    String username = usernames.get(k);
    // <<<<<<

    // >>>>>> URLS
    //Draw a url from the list of words that we've built
    int l = (int (random (urls.size())));
    String url = urls.get(l);
    // <<<<<<

    // create a random fortune ---
    // println ("testFortune= Think about: "+words.get(int(random(i)))+" or talk to "+usernames.get(int(random(k)))+" or visit "+urls.get(int(random(l)))+". Totally "+hashtags.get(int(random(j))));

    //-------------
    // >>>>> Put url somewhere random on the stage, with a random size and colour
    fill(255, 255, 0, 255);
    textSize(random(30, 40)); 
    text(url, random(width)-widthRandomiser, random(panelTop)); // 
    // <<< SEND URL TO THE SCREEN

    // >>> SENDs HASHTAG TO THE SCREEN WITH DIFFERENT SIZE 
    fill(255, 0, 0, 255);
    textSize(random(40, 45));
    text("#"+hashtag, random(width)-widthRandomiser, random (panelTop));
    // <<< END SEND HASHTAG#

    // >>>SEND WORD TO SCREEN ALSO WITH DIFFERENT SETTINGS
    textSize(random(45, 60));
    fill(255, 255);
    text(word, random(width)-widthRandomiser, random (panelTop));
    // <<< END SEND WORD

    // >>> SEND USERNAME TO SCREEN
    fill(0, 255, 22, 255);
    textSize(random(35, 45));
    text("@"+username, random(width)-widthRandomiser, random (panelTop));
    // <<< END SEND USERNAME


    // --------------
    // --------------
    // following is for text boxes background. 
    tfUserCurrent=tf.getText() ; //check the text box content every loop
    println ("tfUserCurrent= "+tfUserCurrent);
     }
  catch (Exception e) {
  }
  finally 
  {
    println ("inside DRAW()");
  }
  checkSerial() ; // check serial port every loop
}
// >>>>>>>>>>>>>>>>>>>>>>>> SEND THAT TWEET >>>>>>>>>>>>>>>
void sendTweet (String tweetText) {
      
  if ((tfUserCurrent.equals(""))!=true) {
    updateDisplayVariables();
    //@@@
    timerT=millis();  // reset the timer each time


    if (timerT-delayCheck>=tweetTimer)
      // this is needed to prevent sending multiple times rapidly to Twitter 
      // which will be frowned upon!
    {
      delayCheck=millis();

      println("tweet being sent");
      println("tfUserCurrent = "+ tfUserCurrent);
      tweetTextIntro = readingSettingText;
      readFortune(tweetText);
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
        println("Successfully tweeted the message: "+fortune + " to user: [@" + status.getText() + "].");
        delayCheck=millis();
      } 
      catch(TwitterException e) { 
        println("Send tweet: " + e + " Status code: " + e.getStatusCode());
      } // end try
      ;
    }
  }
  else {
    tts.speak("You have not entered your Twitter user nayme. Sorry. I cannot reed your fortune. without thiss") ;
  }
}
// <<<<<<<<<<<<<<<<<<<<<<<<< END SEND TWEETS <<<<<<<<<<<<<<<

// >>>>>>>>>>>>>>>>>>>>>>>>> GRAB THOSE TWEETS  >>>>>>>>>>>>>
void grabTweets() {


  color cl3 = color(70, 130, 180);
  fill (cl3);
  rect(0, (height/2)-120, width, 90);

  fill(0, 25, 89, 255);
  textSize(70); 
  text("Reading the collective mind...", (width/8)-120, (height/2)-50); // 
  loadRemoteAdminSettings();
  // reGrabTweets=false; // reset the flag
  //Credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("twitOAuthConsumerKey");
  cb.setOAuthConsumerSecret("twitOAuthConsumerSecret");
  cb.setOAuthAccessToken("twitOAuthAccessToken");
  cb.setOAuthAccessTokenSecret("twitOAuthAccessTokenSecret");

  //Make the twitter object and prepare the query
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  try { /// TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
    // these IF statements are testing to see the search mode [h,u,s]

    Query query = new Query(queryString); // this is default you check the first of 4 admin settings, but should be extended to include passing a selctor param
    query.setRpp(int(adminSettings[3])); // rrp is the number of tweets returned per page
    // The factory instance is re-useable and thread safe.

    //Try making the query request.

    QueryResult result = twitter.search(query); // gets the query

      tweetster = (ArrayList) result.getTweets(); // creates an array to store tweets in
    // then fills it up!

    println ("number of  = "+tweetster.size()+" in tweets Arraylist()");
    for (int i = 0; i < tweetster.size(); i++) {
      Tweet t = (Tweet) tweetster.get(i); 
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
          } // end if
        } //end for (ii++) //stopword c
      }// end clean this msg
    }// end of all tweet cleaning
    println ("cleanTweets = "+cleanTweets);

    for (int k = 0;  k < cleanTweets.size(); k++) {
      words.add(cleanTweets.get(k));
      if (words.size() >int(adminSettings[6])) 
      {
        words.remove(0);
      } // keeps aray to a finite length by dropping off first element as new one is added 
      /*if (loadSettingsFirstLoadFlag==false)
       {
       if (words.size() >1) {words.remove(0);
       }
       }
       */

      // >>>>>> make the list of hashtags
      String hashtag= cleanTweets.get(k);

      String hashtagArray[] = hashtag.split("#");
      if (hashtagArray.length>1)
      {
        //println ("inside checker");
        hashtags.add(hashtagArray[1]);
        int v=words.size()-1;
        words.remove(v);
        if (queryType.equals("hashtag"))
        {
          if (hashtagArray[1].equals("#"+queryString)) {
            hashtags.remove(hashtagArray[1]);
          } 
          else if (hashtags.size() >int(adminSettings[6])/10) 
          {
            hashtags.remove(0);
          } // keeps aray to a finite length by dropping off first element as new one is added
        }
        println ("hashtagArray["+k+"]= "+hashtagArray[1]);
      }
      // <<<<<<<

      // >>>>>>> set up list of usernames
      String username= cleanTweets.get(k);
      String usernameArray[] = username.split("@");
      // println ("usernameArray = ");
      //println (usernameArray);
      if (usernameArray.length>1)
      {
        usernames.add(usernameArray[1]);
        int vv=words.size()-1; // takes out the username by removing last entry in words() 
        words.remove(vv);//
        // println ("usernameArray["+j+"]= "+usernameArray[1]);
      }  
      else if (usernames.size() >int(adminSettings[6])/6) 
      {
        usernames.remove(0);
      } // keeps aray to a finite length by dropping off first element as new one is added 

      // <<<<<<<<

      // >>>>>>>> set up urls >>>>>>
      String url = cleanTweets.get(k);
      String urlArray[] = url.split("h");
      if (urlArray.length>1)
      {
        String urlArray2[] = urlArray[1].split("t");
        if (urlArray2.length>2)
        {
          urls.add(url);
          int vvv=words.size()-1;
          words.remove(vvv);
        } 
        else  if (urls.size() >int(adminSettings[6])/6) 
        {
          urls.remove(0);
        } // keeps aray to a finite length by dropping off first element as new one is added 

        // <<<<<<<<<< end

        // >>>>>>>>>>
      }
    };



    println ("WORDS.SIZE () = "+words.size());
    println ("words = "+words);
    println ("@@@@@@@@@@@@@@@@@@@@@@@");

    for (int p =0;p<words.size(); p++)
    {
      uberWords  = append (uberWords, words.get(p).toString());
    }

    saveStrings ("words-"+stamp+".txt", uberWords);
  } // <<<<<< end try 


  catch (Exception e)
  {
    println("no adminsettings from internet");
  }
  grabTime=millis(); // reset grabTime
  if (loadSettingsFirstLoadFlag==true)
  { 
    loadSettingsFirstLoadFlag =false; //
    //this is the line that will cause subsequqnt updates to remove the first word(0)
  } 
  cleanTweets.clear();
  tweetster.clear();
} // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end grabTweets() <<<<<<<<

// >>>>>>>>>>>>>>>>>>>
void buttonCheck(String tweetTextIntro)
{
  if (b.isPressed()) {
    println("button being pressed");
    sendTweet ("digital (onscreen) Button MOUSE");
    b.setWidth(50);
    // action for onscreen button press
  }
}
// <<<<<<<<<<<<<<<<<<<<<<< end of BUTTONCHECK

// >>>>>>>>>>>>>>> check the open serial port >>>>>>>>>>
void checkSerial() {
  println ();
  //println ("inside checkSerial()");
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
  catch (Exception e) {
    println ("Check serial exception = "+e);
  }
} // <<<<<<<<<<<<<<<<<<<<< end checkSerial <<<<<<<<<<<<<<<<<<<<<


// >>>>>>>>>>>>>>>>>>> load remote  admin settings   >>>>>>>>>>>>>>
void loadRemoteAdminSettings ()
{
  try {
    String checkRandomSpeech = adminSettings[8];
    adminSettings = loadStrings("https://docs.google.com/spreadsheet/pub?key=0AgTXh43j7oFVdFNOcGtMaXZnS3IwdTJacllUT1hLQUE&output=txt");
    if ((checkRandomSpeech.equals(adminSettings[8]))!=true) {
      tts.speak(adminSettings[8]);
    }
    for (int i = 0 ; i < adminSettings.length; i++) {
      println("adminSettings["+i+"]= "+adminSettings[i]);
    } // end for

    if (adminSettings[5].equals("h")) {
      println ("use hashtag for search");
      queryString = adminSettings[0];
      queryType = "hashtag";
    } 
    if (adminSettings[5].equals("u"))
    {
      println ("use username phrase for search");
      queryString = adminSettings[1];
      queryType = "username";
    }
    if (adminSettings[5].equals("s"))
    {
      println ("use search term for search");
      queryString = adminSettings[2];
      queryType = "search term";
    }
    updateDisplayVariables();

    // end if
  }
  catch (Exception e) {
    println ("no CONNECTION");
  }
}

// >>>>
void loadRemoteStopWords ()
{
  try {
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
  catch (Exception e)
  {
    println("jjjjjjjjjjjjj");
  }
}
void keyReleased() {
  if (key==TAB) {
    println ("Tab key released");

    //tfToggleFocus(valFocus);
  } 
  else if  ((key == ENTER )|(key == RETURN)) {
    
    sendTweet("pressed return");
  }
}

void tfToggleFocus (int val)
{
  /*if (val==0)
   {
   tf.setFocus(true);
   tf.setColorBackground(focusBackgroundColor);
   tf.setColor(focusColor);
   valFocus=1;
   }
   else if (val==1) {
   tf.setFocus(false);
   tf.setColorBackground(focusOffBackgroundColor);
   tf.setColor(focusOffColor);
   valFocus=0;
   }*/
  tf.setFocus(true);
  tf.setColorBackground(focusBackgroundColor);
  tf.setColor(focusColor);
}
void updateDisplayVariables() {
  // Reading the mind queryString
  String currentHashtag = adminSettings [0];
  String displayHashtag = "hashtag = "+adminSettings [0]+"   ";
  if (adminSettings[0]=="")
  {
    displayHashtag="";
  }
  String currentUserName = adminSettings [1];
  String displayUserName = "@username = "+adminSettings [1]+"   ";
  if (adminSettings[1]=="")
  {
    displayUserName="";
  }
  String currentSearchTerms = adminSettings [2];
  String displaySearchTerms = "search = "+adminSettings [2];
  if (adminSettings[2]=="")
  {
    displayUserName="";
  }
  readingSettingText = "Reading the hive mind for "+queryType+"= "+ queryString;
  color cl = color(70, 30, 180);// not in use
  color cl2 = color(70, 230, 180);//not in use
  fill (clPanel);
  //rect(30, boxY+15, width, 105);
  fill(0, 0, 0, 255);
  textSize(40);
  //text(readingSettingText, 10, boxY+40);
  //rect(0, boxY+13, width, 1);
  textSize(40);
  text("@", 2, boxY+33);


  fill (clPanel);
  rect(columnPos2_X, boxY-10, width, 50);
  fill(0, 0, 0, 255);
  textSize(35);
  //text(adminSettings[7], columnPos2_X+30, boxY-25);


  text("<enter @username + press my button!", columnPos2_X, boxY+30);


  //displayHashtag+displayUserName+displaySearchTerms;
}

void buildAdminPanel() {
  int  panelTop = height-panelHeight;

  fill (clPanel);
  rect(0, panelTop, width, panelHeight);
  // >>>>>>> set up fonts
  //PFont font = createFont("arial",20);
  font = new ControlFont(createFont("arial", 100), 40);
  // <<<<<<<

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  set up GUI elements >>>>>>>>>>>>>>>>>>>>
  noStroke();
  cp5 = new ControlP5(this); // adds in a control instance to add buttons and text field to
  noStroke();
  tf = cp5.addTextfield("");
  tf.setPosition(border, boxY);
  tf.setSize(boxWidth, boxHeight);
  tf.setColorBackground(focusBackgroundColor);
  tf.setColor(focusColor);
  tf.setFont(font);
  tf.setFocus(true);
  //tf.setAutoClear(true);
  tf.captionLabel().setControlFont(font);
  // @@@ 



  // create a new button with name 'Tell my Fortune'
  b = cp5.addButton("but", 20, 100, 50, 80, 20);
  b.setId(2);  // id to target this element
  b.setWidth(250); // width
  b.setHeight(25);
  b.setPosition(border, boxY+100);

  b.captionLabel().setControlFont(font);
  b.captionLabel().style().marginLeft = 1;
  b.captionLabel().style().marginTop = 1;
  b.setVisible(true);
  b.isOn();
  b.setColorBackground(focusOffBackgroundColor);


  // @@@



  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end of GUI <<<<<<<<<<


  // >>>>>>>>
}

void readFortune (String tweetText)
{

  fortune = "@"+tfUserCurrent + " from "+tweetText+ ", " +tfTextCurrent+". "+tweetTextOutro;
  fortuneSpoken = (fortuneGreeting + tfUserCurrent+ "How. do. you. feel about. "+fortune);
}
