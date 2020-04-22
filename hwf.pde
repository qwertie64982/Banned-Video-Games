import org.gicentre.geomap.*;

GeoMap geoMap;                // declare the geoMap object
ArrayList<Game> games;        // arrayList of game objects
ArrayList<String> genres;     // arrayList of genre names
//ArrayList<String> categories;
//ArrayList<String> statusTypes;
//ArrayList<Nation> nations;
ArrayList<String> mapNations; // arraylist of names in the geomap
ArrayList<String> places;     // arraylist of nations from the other lists

float myMouseX;     // selected mouse position X
float myMouseY;     // selected mouse position Y
float padding = 10; // screen padding
//int selected;
//float maxG;
//float maxN;
float maxGenre;     // stores the maximum number of games in a genre, across all genres

// Colors (very good for all forms of colorblindness)
color oceanColor = color(182, 219, 255); // 0xB6DBFF
color boundaryColor = color(0, 40); // 0x00000028 gray 0, opacity 40%
color noDataColor = color(180); // 0xB4B4B4
color yesDataColor = color(219, 109, 0); // 0xDB6D00
color selectedColor = color(146, 73, 0); // 0x924900
color selectedNoneColor = color(123); // 0x7B7B7B


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

    // Initialize data
    games = new ArrayList<Game>();
    genres = new ArrayList<String>();
    mapNations = new ArrayList<String>();
    places = new ArrayList<String>();

    // Load data
    for (TableRow r : data.rows()) { // for each entry in the ban list
        // Make a list of every genre
        for (String s : r.getString("Genre").split("\\|") ) {
            if (!genres.contains(s)) {
                genres.add(s);
            }
        }
        
        // Make a list of every country
        if (!places.contains(r.getString("Country"))) {
            places.add(r.getString("Country"));
        }

        // Make a list of every game
        if (!gameTitles.contains(r.getString("Game"))) { // if we haven't seen this game yet, add it, as well as all accompanying data 
            gameTitles.add(r.getString("Game"));            
            Game g = new Game(r.getString("Game"),
                              r.getString("Series"),
                              r.getString("Country"),
                              r.getString("Ban Category"),
                              r.getString("Ban Status"),
                              r.getString("Developer"),
                              r.getString("Publisher"),
                              r.getString("Genre"));
            games.add(g);
        } else { // if we have seen this game before, add the new accompanying data (ex. multiple countries banned the same game)
            games.get(gameTitles.indexOf(r.getString("Game"))).addInstance(r.getString("Country"),
                                                                           r.getString("Ban Category"),
                                                                           r.getString("Ban Status"));
        }
    }

    // Create mapNations, a list of every nation's name
    for (int id : geoMap.getFeatures().keySet()) { // for every nation's numeric ID (from geoMap)
        mapNations.add(geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME")); // add its corresponding string name to mapNations
    }
    
    // Calculate maxGenre
    // Specifically, this is the max number of banned games in any genre by any single country
    float gameCount;
    maxGenre = 0;
    for (String place : places) { // for each country
        // we don't need to worry about the name for South Korea here, since we're just checking back into the dataset
        for (String genre : genres) { // for each genre
            gameCount = 0;
            for (Game g : games) { // for each game, sum how many games
                if (g.isGenre(genre) && g.isNation(place)) {
                    gameCount++;
                }
            }
            if (maxGenre < gameCount) { // only keep the biggest number we find
                maxGenre = gameCount;
                // println(place); // who banned the most games? (the bottom one)
            }
        }
    }
    // println(maxGenre);
}

// Processing 
void draw() {
    clear();
    drawMap();
}

// Draw map
void drawMap() {
    background(oceanColor);
    
    // Black background for barchart
    fill(noDataColor);
    rect(0, height/2, width, height/2);
    
    stroke(boundaryColor);
    String countryName;  
    String tempName;
    int id = geoMap.getID(myMouseX, myMouseY); // Selected country's id

    // Draw each country
    for (int i : geoMap.getFeatures().keySet()) {
        tempName = (geoMap.getAttributeTable().findRow(str(i), 0).getString("NAME"));
        if (tempName == "S. Korea") {
            tempName = "South Korea";
        }
        if (places.contains(tempName)) {
            fill(yesDataColor);
        } else {
            fill(noDataColor);
        }
        geoMap.draw(i);
    }

    // If country is clicked, change its color
    // TODO: Let's make gray countries turn darker gray and display "no data"
    // TODO: Perhaps if we click a country it toggles, so when no country is selected, we show world data on the bar chart
    if (id != -1) {
        countryName = geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME");
        if (countryName.equals("S. Korea")) { // Dataset: "South Korea", geoMap: "S. Korea"
            countryName = "South Korea";
        }
        if (places.contains(countryName)) {
            fill(selectedColor);
        } else {
            fill(selectedNoneColor);
        }
        geoMap.draw(id);
        drawGenre(countryName); // draw genre barchart
    }
}

// Draws barchart of games/genre on the bottom
// x-axis is genres, y-axis is games, all within the selected country
void drawGenre(String name) {
    float barWidth = map(1, 0, genres.size(), 0, width - (padding * 2));
    float position = padding; // current x location, starts padding distance from end
    float barHeightUnit = map(1, 0, maxGenre, 0, height/2 - padding*15); // height of 1 game in any bar, 15 because 10 padding on bottom, one on top
    float gameCount;
    float barHeight;
    
    fill(noDataColor);
    rect(0, height/2, width, height/2);
    
    for (String genre : genres) { // for each genre
        gameCount = 0;
        for (Game g : games) {
            if (g.isGenre(genre) && (g.isNation(name))) {
                gameCount++;
            }
        }

        fill(yesDataColor);
        barHeight = gameCount * barHeightUnit;
        rect(position, height - barHeight - padding*14, barWidth, barHeight); // draw upper bar
        
        position += barWidth/2;
        pushMatrix();
        fill(0);
        translate(position, height - padding*13);
        rotate(5 * PI/12); // halfway between 60 and 90 degrees down
        textSize(12);
        textAlign(LEFT, CENTER);
        //fill(textColor);
        text(genre, 0, 0);
        popMatrix();
        fill(yesDataColor);
        position += barWidth/2;
    }
    // test to see how high bars go
    // fill(255, 0, 0);
    // barHeight = maxGenre * barHeightUnit;
    // rect(padding, height - barHeight - padding*14, barWidth, barHeight);
    
    // drawLines(barHeight, int(maxGenre) + 1);
}


// Processing mouseClicked
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
