// -----------------------
// ----
// This is based on code by Jer Thorp
// From http://blog.blprnt.com/blog/blprnt/updated-quick-tutorial-processing-twitter
// Awesome!
// version 5 - trying to add GUI elements, based on controlP5 GUI Library from 
// by Andreas Schlegel, 2012. sojamo.de
// http://www.sojamo.de/libraries/controlP5/
// For positioning see also - https://code.google.com/p/controlp5/source/browse/trunk/examples/controlP5button/controlP5button.pde?r=6
// ----
// -----------------------
//Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> words = new ArrayList();
 
import controlP5.*; // import the GUI library
ControlP5 cp5; // creates a controller I think!
ControlFont font;
controlP5.Button b;
controlP5.Textfield tf;
controlP5.Textlabel lb;

void setup() {
  //Set the size of the stage, and the background to black.
  size(550,550);
  background(0);
  //PFont font = createFont("arial",20);
  font = new ControlFont(createFont("arial",100),15);
  
  // ------------------
  noStroke();
  cp5 = new ControlP5(this); // adds in a control instance to add buttons and text field to
  
  
   // create a new button with name 'Tell my Fortune'
  b = cp5.addButton("Now tell me my #MuseumNextHive fortune",20,100,50,80,20);
  b.setId(2);  // id to target this element
  b.setWidth(400); // width
  b.setHeight(50);
  b.setPosition(150,500);
    
  b.captionLabel().setControlFont(font);
  b.captionLabel().style().marginLeft = 20;
  b.captionLabel().style().marginTop = 12;
     

     noStroke();
     tf = cp5.addTextfield("@@@@@@");
     tf.setPosition(350,400);
     tf.setStringValue("@");
     tf.setSize(400,50);
     tf.setFont(font);
     tf.setFocus(true);
     tf.setColor(color(255,255,255));
     tf.setText ("@");
     tf.captionLabel().setControlFont(font);
     
     //
     lb = cp5.addTextlabel("My Twitter username is..."); 
     
     lb.setSize(400,50);
     lb.setFont(font);
     lb.setColor(color(255,255,255));
     
     lb.setPosition(150,150);
 

  // -----------------
  
  smooth();
  
   //Credentials
ConfigurationBuilder cb = new ConfigurationBuilder();
cb.setOAuthConsumerKey("*****************************");
cb.setOAuthConsumerSecret("******************************");
cb.setOAuthAccessToken("******************************");
cb.setOAuthAccessTokenSecret("******************************");

  //Make the twitter object and prepare the query
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  Query query = new Query("@museumnext");
  query.setRpp(100);
  // The factory instance is re-useable and thread safe.
   try {
     Status status = twitter.updateStatus("test after adding GUI components");
     println("Successfully updated the status to [" + status.getText() + "].");
  } catch(TwitterException e) { 
    println("Send tweet: " + e + " Status code: " + e.getStatusCode());
  } // end try 
  
     //Try making the query request.
  try {
    QueryResult result = twitter.search(query);
    ArrayList tweets = (ArrayList) result.getTweets();
 
    for (int i = 0; i < tweets.size(); i++) {
      Tweet t = (Tweet) tweets.get(i);
      String user = t.getFromUser();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet by " + user + " at " + d + ": " + msg);
       
      //Break the tweet into words
      String[] input = msg.split(" ");
      for (int j = 0;  j < input.length; j++) {
       //Put each word into the words ArrayList
       words.add(input[j]);
      }
    };
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  };
}
 void sendTweet(String tweetText) {
  
 }
void draw() {
  //Draw a faint black rectangle over what is currently on the stage so it fades over time.
  fill(0,1);
  rect(0,0,width,height);
   
  //Draw a word from the list of words that we've built
  int i = (frameCount % words.size());
  String word = words.get(i);
   
  //Put it somewhere random on the stage, with a random size and colour
  fill(255,random(50,150));
  textSize(random(10,30));
  text(word, random(width), random(height));
}
