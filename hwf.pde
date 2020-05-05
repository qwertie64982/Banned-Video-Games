// Maxwell Sherman & Vincent Lombardi
// Final Project: Censored Games
// CPSC 313-01 Data Visualization
// 2020-05-04

import org.gicentre.geomap.*;

// Data
GeoMap geoMap;                   // GeoMap object
ArrayList<Game> games;           // ArrayList of game objects
ArrayList<String> genres;        // ArrayList of genre names
ArrayList<String> mapNations;    // ArrayList of names in the geomap
ArrayList<String> places;        // ArrayList of nations from the other lists
HashMap<String, Integer> totals; // HashMap (dict) of how many total games banned from each nation

// Utility
float myMouseX;       // selected mouse position X
float myMouseY;       // selected mouse position Y
float padding = 10;   // screen padding
float maxGenre;       // stores the maximum number of games censored by a single country in any given genre
float maxGlobalGenre; // stores the maximum number of games censored globally in any given genre

// Colors (very good for all forms of colorblindness except grayscale)
color oceanColor = color(182, 219, 255);  // 0xB6DBFF
color boundaryColor = color(0, 40);       // 0x00000028 gray 0, opacity 40%
color noDataColor = color(180);           // 0xB4B4B4
color lowDataColor = color(219, 150, 81); // 0xDB9651
color medDataColor = color(219, 109, 0);  // 0xDB6D00
color hiDataColor = color(153, 77, 0);    // 0x994D00
color selectedColor = color(0, 111, 255); // 0x006FFF
color selectedNoneColor = color(123);     // 0x7B7B7B

// Color cutoffs
int medDataCutoff = 10;
int hiDataCutoff = 25;

// Processing setup
void setup() {
    // Processing basic setup
    size(1024, 1000); // creates output window size 768
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
    totals = new HashMap<String, Integer>();

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
        int countryTotal = 0; // total games banned in this country
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
            countryTotal += gameCount;
            if (maxGenre < gameCount) { // only keep the biggest number we find
                maxGenre = gameCount;
                //println(place); // who banned the most games? (the bottom line, this prints many)
                //println(genre);
            }
            
            if(maxGlobalGenre < totalCount){ // Same thing as above but on a golbal scale.
                maxGlobalGenre = totalCount;    
            }            
        }
        totals.put(place, countryTotal);
    }
}

// Processing draw
void draw() {
    clear();
    drawMap();
}

// Draw map
void drawMap() {
    background(oceanColor);
    
    // Background for barchart
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
            if (totals.get(tempName) <= medDataCutoff) {
                fill(lowDataColor);
            } else if (totals.get(tempName) <= hiDataCutoff) {
                fill(medDataColor);
            } else {
                fill(hiDataColor);
            }
        } else {
            fill(noDataColor);
        }
        geoMap.draw(i);
    }

    // If country is clicked, change its color
    if (id != -1) {
        countryName = geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME");
        if (countryName.equals("S. Korea")) { // Dataset: "South Korea", geoMap: "S. Korea"
            countryName = "South Korea";
        }
        // Show how many games total banned in that country
        // println(countryName + ": " + totals.get(countryName));
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

// Draws barchart of games/genre on the bottom (specific country)
// x-axis is genres, y-axis is games, all within the selected country
void drawGenre(String name) {
    float barWidth = map(1, 0, genres.size(), 0, width - (padding * 4));
    float position = padding * 3; // current x location, starts padding distance from end
    float barHeightUnit = map(1, 0, maxGenre, 0, height/2 - padding * 20); // height of 1 game in any bar, 17 because 10 padding on bottom, three on top 
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
        fill(selectedColor);
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
    drawLabels(name, barHeightUnit, 1, maxGenre);
}

// Draws barchart of games/genre on the bottom (global)
void drawGlobalGenre(){
    float barWidth = map(1, 0, genres.size(), 0, width - (padding * 4));
    float position = padding * 3; // current x location, starts padding distance from end
    float barHeightUnit = map(1, 0, maxGlobalGenre, 0, height/2 - padding*20); // height of 1 game in any bar, 15 because 10 padding on bottom, one on top
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
        fill(medDataColor);
        barHeight = gameCount * barHeightUnit;
        rect(position, height - barHeight - padding*14, barWidth, barHeight); // draw upper bar
        position += barWidth/2;
        labelGenre(genre, position);
        position += barWidth/2;
    }
    drawLabels("Global", barHeightUnit, 5, maxGlobalGenre);
}

// Labels the x-axis
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
        fill(selectedColor);
}

// Labels the y-axis and title
// increment is the height of one unit of bar
// maxVal is is largest value possible for any bar
void drawLabels(String title, float barHeight, int increment, float maxVal) {
    // Legend
    rectMode(CENTER);
    textSize(16);
    fill(lowDataColor); 
    rect(width/4, height/2 + padding,15,15);
    fill(0);
    text("less than 10", width/4 + padding, height/2+padding);
    fill(medDataColor);
    rect(width/2, height/2 + padding,15,15);
    fill(0);
    text("less than 25", width/2 + padding, height/2+padding);
    fill(hiDataColor);
    rect(width - width/4, height/2 + padding,15,15);
    fill(0);
    text("greater than 25", width/2 + width/4 + padding, height/2+padding);
    rectMode(CORNER);
    
    textAlign(CENTER, CENTER);
    text(title, width/2, (height/2) + padding * 4); // name of the country (or "Global")
    
    stroke(0);
    textSize(12);
    textAlign(RIGHT, CENTER);
    line(padding * 3, (height - padding*14), padding * 3, (height/2) + (padding * 6));
    for (int i = 0; i <= maxVal; i += increment) {
        text(i, padding * 2, (height - padding*14) - (barHeight * i) - 2); // y-axis label; -2 because they were a couple px too low
        line(padding * 2.5, (height - padding*14) - (barHeight * i), width - padding, (height - padding*14) - (barHeight * i));
    }
}




// Processing mouseClicked
void mouseClicked(){
   myMouseX = mouseX;
   myMouseY = mouseY;
}
