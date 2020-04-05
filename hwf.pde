import org.gicentre.geomap.*;

GeoMap geoMap;                // Declare the geoMap object.
ArrayList<Game> games; // arraylist of game objects
ArrayList<String> genres; // arraylist of genre names
//ArrayList<String> categories;
//ArrayList<String> statusTypes;
//ArrayList<Nation> nations;
ArrayList<String> mapNations; // arraylist of names in the geomap
ArrayList<String> places; // arraylist of nations from the other listS

float myMouseX; // variables save selected mouse position
float myMouseY; 
float padding = 10; // screen padding
//int selected;
//float maxG;
//float maxN;
float maxGenre; // variable stores largest number of games in a genre


// Processing setup
void setup() {
    // Processing basic setup
    size(1024, 768); // creates output window size
    
    textSize(16);
    textAlign(CENTER);
    Table data = loadTable("Games.csv", "header");
    ArrayList<String> gameTitles = new ArrayList<String>();

    myMouseX = 0;
    myMouseY = 0;
    
    geoMap = new GeoMap(0, 0, width, height/2, this);
    geoMap.readFile("world");   // Reads shapefile.

    games = new ArrayList<Game>();
    genres = new ArrayList<String>();
    mapNations = new ArrayList<String>();
    places = new ArrayList<String>();

    for (TableRow r : data.rows()) {

        for (String s : r.getString("Genre").split("\\|") ) {

            if (!genres.contains(s)) { // adds genre to the list
                genres.add(s);
            }
        }
        if (!places.contains(r.getString("Country"))) { // adds country name to list
            places.add(r.getString("Country"));
        }

        if (!gameTitles.contains(r.getString("Game"))) { // creates game   
            gameTitles.add(r.getString("Game"));            
            Game g = new Game(r.getString("Game"), r.getString("Series"), r.getString("Country"), r.getString("Ban Category"), r.getString("Ban Status"), r.getString("Developer"), r.getString("Publisher"), r.getString("Genre"));
            games.add(g);
        } else { // adds info to game object 
            games.get(gameTitles.indexOf(r.getString("Game"))).addInstance(r.getString("Country"), r.getString("Ban Category"), r.getString("Ban Status"));
        }
    }

    for (int id : geoMap.getFeatures().keySet()) {
        mapNations.add(geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME"));
    }
    float gameCount;
    maxGenre = 0;
    
    for (String genre : genres) {
        gameCount = 0;
        for (Game g : games) {
            if (g.isGenre(genre)) {
                gameCount++;
            }
        }
        if (maxGenre < gameCount) {
            maxGenre = gameCount;
        }
    }
}

// Processing 
void draw() {
    clear();
    //background(250);
    fill(0);
    drawMap();
    
   
}

// draws the map
void drawMap() {
    // TODO change colors so that they differ from tutorial.

    background(202, 226, 245);  // Ocean color
    stroke(0, 40);               // Boundary color
    String countryName;  
    String tempName;
    int id = geoMap.getID(myMouseX, myMouseY); // get selected countries id


    for (int i : geoMap.getFeatures().keySet()) { // draws map but leaves nations not in the data set as white
        tempName = (geoMap.getAttributeTable().findRow(str(i), 0).getString("NAME"));    
        if (places.contains(tempName) || tempName.equals("S. Korea")) {
            fill(206, 173, 146);
        } else {
            fill(255);
        }
        geoMap.draw(i);
    }

    if (id != -1) { // recolors country when clicked on
        fill(180, 120, 120);      // Highlighted land color
        geoMap.draw(id);
        countryName = geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME");
        if (countryName.equals("S. Korea")) { // South Korea is named something else in our dataset
            println("test");
            countryName = "South Korea";
        }
        drawGenre(countryName); // draw barchart
    }
}
// draws genre's below the screen
// x-axis is genre y-axis is games per category in a selected country
void drawGenre(String name) {
    float barWidth = map(1, 0, genres.size(), 0, width - (padding * 2));
    float position = padding; // current postion
    float barHeight = map(1, 0, maxGenre, 0, height/2 - (padding * 10));
    float gameCount;
    float temp; // stores gameCount scaled to barheight
    
    for (String genre : genres) {
        gameCount = 0;
        for (Game g : games) {
            if (g.isGenre(genre) && (g.isNation(name))) {
                gameCount++;
            }
        }

        fill(52, 158, 206);
        temp = gameCount * barHeight;
        rect(position, height - temp - padding, barWidth, temp); // draw upper bar 
        position += barWidth;
    }
    //drawLines(barHeight, int(maxGenre) + 1);
}


// selects new items.
void mouseClicked(){
   myMouseX = mouseX;
   myMouseY = mouseY;
}


// older code that we are not using but I saved in case we wanted a jumping off point for additional features.
/*
void drawGenre() {    
    float barWidth = map(1, 0, genres.size(), 0, width - (padding * 2));
    float position = padding; // current postion
    float barHeight = map(1, 0, maxGenre, 0, height - (padding * 10));
    float gameCount;
    for (String genre : genres) {
        gameCount = 0;
        for (Game g : games) {
            if (g.isGenre(genre)) {
                gameCount++;
            }
        }

        fill(52, 158, 206);
        float temp = gameCount * barHeight;
        rect(position, height - temp - padding, barWidth, temp); // draw upper bar 
        position += barWidth;
    }
    drawLines(barHeight, int(maxGenre) + 1);
}

void drawLines(float barHeight, int maxVal) {
    stroke(0);
    for (int i = 0; i < maxVal; i++) {
        line(padding, height - (barHeight * i) - padding, width - padding, height - (barHeight * i) - padding);
    }
}


void drawNations() {

    float barWidth = map(1, 0, nations.size(), 0, width - (padding * 2));
    float position = padding; // current postion
    float barHeight = map(1, 0, maxN, 0, height - (padding * 10));
    for (Nation n : nations) { 
        fill(222, 36, 36);
        float temp = n.getGameCount() * barHeight;
        rect(position, height - temp - padding, barWidth, temp); // draw upper bar 
        position += barWidth;
    }    
    drawLines(barHeight, int(maxN) + 1);
}



void drawGames() {
    float barWidth = map(1, 0, games.size(), 0, width - (padding * 2));
    float position = padding; // current postion
    float barHeight = map(1, 0, maxG, 0, height - (padding * 10));

    for (Game g : games) {

        fill(52, 158, 206);
        float temp = g.getBannedCount() * barHeight;
        rect(position, height - temp - padding, barWidth, temp); // draw upper bar 
        position += barWidth;
    }    
    drawLines(barHeight, int(maxG) + 1);
}
*/
/*
void setup() {
    // Processing basic setup
    size(1024, 768); // creates output window size
    
    textSize(16);
    textAlign(CENTER);
    selected = 2;
    maxG = 0;
    maxN = 0;
    Table data = loadTable("Games.csv", "header");
    places = new ArrayList<String>();
    ArrayList<String> names = new ArrayList<String>();
    myX = 0;
    myY = 0;
    geoMap = new GeoMap(0, 0, width, height/2, this);
    geoMap.readFile("world");   // Reads shapefile.

    games = new ArrayList<Game>();
    nations = new ArrayList<Nation>();
    genres = new ArrayList<String>();
    categories = new ArrayList<String>();
    statusTypes = new ArrayList<String>();  
    mapNations = new ArrayList<String>();

    for (TableRow r : data.rows()) {

        for (String s : r.getString("Genre").split("\\|") ) {

            if (!genres.contains(s)) { // adds genre to the list

                genres.add(s);
            }
        }

        if (!categories.contains(r.getString("Ban Category"))) { // adds category to list 
            categories.add(r.getString("Ban Category"));
        }
        if (!statusTypes.contains(r.getString("Ban Status"))) { // adds status type to list 
            statusTypes.add(r.getString("Ban Status"));
        }
        if (!places.contains(r.getString("Country"))) { // adds country name to list
            places.add(r.getString("Country"));
            nations.add(new Nation(r.getString("Country")));
        }

        if (!names.contains(r.getString("Game"))) { // creates game   
            names.add(r.getString("Game"));            
            Game g = new Game(r.getString("Game"), r.getString("Series"), r.getString("Country"), r.getString("Ban Category"), r.getString("Ban Status"), r.getString("Developer"), r.getString("Publisher"), r.getString("Genre"));
            int x = places.indexOf(r.getString("Country"));
            nations.get(x).addGame(g);
            games.add(g);
        } else { // adds info to game object 
            int i = names.indexOf(r.getString("Game"));
            games.get(i).addInstance(r.getString("Country"), r.getString("Ban Category"), r.getString("Ban Status"));
            int x = places.indexOf(r.getString("Country"));
            nations.get(x).addGame(games.get(i));
        }
    }

    for (int id : geoMap.getFeatures().keySet()) {
        mapNations.add(geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME"));
    }

    for (Game g : games) {
        if (maxG < g.getBannedCount()) {
            maxG = g.getBannedCount();
        }
    }

    for (Nation n : nations) {
        if (maxN < n.getGameCount()) {
            maxN = n.getGameCount();
        }
    }
    float gameCount;
    maxGenre = 0;
    ;

    for (String genre : genres) {
        gameCount = 0;
        for (Game g : games) {
            if (g.isGenre(genre)) {
                gameCount++;
            }
        }
        if (maxGenre < gameCount) {
            maxGenre = gameCount;
        }
    }
}
*/
