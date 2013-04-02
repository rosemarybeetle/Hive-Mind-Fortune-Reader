
//String [] texty2 = split (texty[0], ':');
  
void setup()
{
  String [] texty = loadStrings("https://spreadsheets.google.com/feeds/list/0AgTXh43j7oFVdC12aXp1M1lJQ0JUYlF2RWtJa1RBVGc/od6/public/basic?alt=rss");
println (texty);
String paas []= split (texty [0],':');
String hashtag[]=split (paas[27], ',');
String username[]=split (paas[28], ',');

String searchterm[]=split (paas[29], ',');

String ppm[]=split (paas[30], ',');
println (hashtag[0]);
println (username[0]);
println (searchterm[0]);
println (ppm[0]);
}

void draw() {
}
