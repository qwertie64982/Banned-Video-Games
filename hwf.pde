ArrayList<Game> games;
ArrayList<String> genres;
ArrayList<String> categories;
ArrayList<String> statusTypes;
ArrayList<Nation> nations;

// Sphere things
float padding = 10;
int selected;
float maxG;
float maxN;

// Processing setup
void setup() {
    // Processing basic setup
    size(1024, 768); // creates output window size
    
    textSize(16);
    textAlign(CENTER);
    selected = 1;
    maxG = 0;
    maxN = 0;
    Table data = loadTable("Games.csv", "header");
    ArrayList<String> places = new ArrayList<String>();
    ArrayList<String> names = new ArrayList<String>();

    games = new ArrayList<Game>();
    nations = new ArrayList<Nation>();
    genres = new ArrayList<String>();
    categories = new ArrayList<String>();
    statusTypes = new ArrayList<String>();  

    for (TableRow r : data.rows()) {
        if (!genres.contains(r.getString("Genre"))) { // adds genre to the list
            genres.add(r.getString("Genre"));
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

    for(Game g : games){
        if(maxG < g.getBannedCount()){
            maxG = g.getBannedCount();    
        }
    }
    
    for (Nation n : nations){
        if(maxN < n.getGameCount()){
            maxN = n.getGameCount();
        }
    }
    
    println(width);
    println(height);
}

// Processing 
void draw() {
    clear();
    background(250);
    fill(0);
    if (selected == 0){
        text("number of countries games are banned in", width/2, padding * 4);
        drawGames();
    } else if (selected == 1){
        text("games that are banned per country", width/2, padding * 4);
        drawNations();    
    }
    
}

void drawNations(){
    
    float barWidth = map(1, 0, nations.size(), 0, width - (padding * 2));
    float position = padding; // current postion
    float barHeight = map(1, 0, maxN, 0, height - (padding * 10));
    for(Nation n : nations){ 
        fill(222, 36, 36);
        float temp = n.getGameCount() * barHeight;
        rect(position, height - temp - padding, barWidth, temp); // draw upper bar 
        position += barWidth;
    }    
    drawLines(barHeight, int(maxN) + 1); 
    
}

void drawGenre() {
    float barWidth = map(1, 0, games.size(), 0, width - (padding * 2));
    float position = padding; // current postion
    float barHeight = map(1, 0, maxG, 0, height - (padding * 10));
    
    for(Game g : games){
        
        fill(52, 158, 206);
        float temp = g.getBannedCount() * barHeight;
        rect(position, height - temp - padding, barWidth, temp); // draw upper bar 
        position += barWidth;
    }    
    drawLines(barHeight, int(maxG) + 1); 
}

void drawGames() {
    float barWidth = map(1, 0, games.size(), 0, width - (padding * 2));
    float position = padding; // current postion
    float barHeight = map(1, 0, maxG, 0, height - (padding * 10));
    
    for(Game g : games){
        
        fill(52, 158, 206);
        float temp = g.getBannedCount() * barHeight;
        rect(position, height - temp - padding, barWidth, temp); // draw upper bar 
        position += barWidth;
    }    
    drawLines(barHeight, int(maxG) + 1); 
}

void drawLines(float barHeight, int maxVal){
    stroke(0);
    for(int i = 0; i < maxVal; i++){
        line(padding, height - (barHeight * i) - padding, width - padding, height - (barHeight * i) - padding);     
    }   
}

void keyPressed() {
    
    if (key == CODED && keyCode == LEFT) {
        clear();
        if (selected == 0) {
            selected = 1;
        } else {
            selected = 0;
        }
    } else if (key == CODED && keyCode == RIGHT) {
        clear();
        if (selected == 0) {
            selected = 1;
        } else {
            selected = 0;
        }
    }
    background(255);
}
