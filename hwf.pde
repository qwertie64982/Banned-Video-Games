import org.gicentre.geomap.*;

GeoMap geoMap;                // declare the geoMap object
ArrayList<Game> games;        // arrayList of game objects
ArrayList<String> genres;     // arrayList of genre names
ArrayList<String> mapNations; // arraylist of names in the geomap
ArrayList<String> places;     // arraylist of nations from the other lists

float myMouseX;     // selected mouse position X
float myMouseY;     // selected mouse position Y
float padding = 10; // screen padding
float maxGenre;     // stores the maximum number of games in a genre, across all genres
float maxGlobalGenre;

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
    float totalCount; // total number of games per genre
    maxGenre = 0;
    maxGlobalGenre = 0;
    for (String place : places) { // for each country
        // we don't need to worry about the name for South Korea here, since we're just checking back into the dataset        
        for (String genre : genres) { // for each genre
            gameCount = 0;
            totalCount = 0;
            
            for (Game g : games) { // for each game, sum how many games
                if (g.isGenre(genre)){ 
                    totalCount++; // total per genre
                    if (g.isNation(place)) { // total per genere and nation
                        gameCount++;
                    }        
                }
            }
            if (maxGenre < gameCount) { // only keep the biggest number we find
                maxGenre = gameCount;
                //println(place); // who banned the most games? (the bottom one)
                //println(genre);
            }
            
            if(maxGlobalGenre < totalCount){ // Same thing as above but on a golbal scale.
                maxGlobalGenre = totalCount;    
            }            
        }
    }
    println(maxGlobalGenre);
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
        if (tempName.equals("S. Korea")) { // Dataset: "South Korea", geoMap: "S. Korea"
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
        } else { // case if country is not in dataset
            fill(selectedNoneColor);
        }
        geoMap.draw(id);
        drawGenre(countryName); // draw genre barchart
        
    } else {
        drawGlobalGenre();  // draw genre barchart for world
    }
        
}

// draws genres for the entire planet
void drawGlobalGenre(){
    
    float barWidth = map(1, 0, genres.size(), 0, width - (padding * 4));
    float position = padding * 3; // current x location, starts padding distance from end
    float barHeightUnit = map(1, 0, maxGlobalGenre, 0, height/2 - padding*17); // height of 1 game in any bar, 15 because 10 padding on bottom, one on top
    float gameCount;
    float barHeight;    
    fill(noDataColor);
    rect(0, height/2, width, height/2);
    for (String genre : genres) { // for each genre
        gameCount = 0;
        for (Game g : games) {
            if (g.isGenre(genre)) { 
                gameCount++;
            }
        }
        fill(yesDataColor);
        barHeight = gameCount * barHeightUnit;
        rect(position, height - barHeight - padding*14, barWidth, barHeight); // draw upper bar
        position += barWidth/2;
        labelGenre(genre, position);
        position += barWidth/2;
    } 
    drawLines("Global", barHeightUnit, 5, maxGlobalGenre);
}


// Draws barchart of games/genre on the bottom
// x-axis is genres, y-axis is games, all within the selected country
void drawGenre(String name) {
    float barWidth = map(1, 0, genres.size(), 0, width - (padding * 4));
    float position = padding * 3; // current x location, starts padding distance from end
    float barHeightUnit = map(1, 0, maxGenre, 0, height/2 - padding * 17); // height of 1 game in any bar, 17 because 10 padding on bottom, three on top 
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
        labelGenre(genre, position);
        position += barWidth/2;
    }
    // test to see how high bars go
    // fill(255, 0, 0);
    // barHeight = maxGenre * barHeightUnit;
    // rect(padding, height - barHeight - padding*14, barWidth, barHeight);
    drawLines(name, barHeightUnit, 1, maxGenre);
}

// labels the x-axis
void labelGenre(String genre, float position){
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
}

// labels the y-axis and title. Barhieght is the height of the bar. Increment indicates what the difference between each label will be. MaxVal is the height of the graph.
void drawLines(String title, float barHeight, int increment, float maxVal) { // draws lines.
    fill(0);    
    textAlign(CENTER, CENTER);
    textSize(16);
    text(title, width/2, (height/2) + padding); // name of the country or global   
    
    stroke(0);
    textSize(12);   
    textAlign(RIGHT, CENTER);
    line(padding * 3, (height - padding*14), padding * 3, (height/2) + (padding * 2));
    for (int i = 0; i <= maxVal; i += increment) {
        text(i, padding * 2, (height - padding*14) - (barHeight * i)); // y-axis label     
        line(padding * 2.5, (height - padding*14) - (barHeight * i), width - padding, (height - padding*14) - (barHeight * i));
    }
}


// Processing mouseClicked
void mouseClicked(){
   myMouseX = mouseX;
   myMouseY = mouseY;   
}
