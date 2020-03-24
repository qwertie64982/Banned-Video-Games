public class Nation {
    private String countryName;
    private ArrayList<Game> games;
    public Nation(String countryName) {
        this.countryName = countryName;
        games = new ArrayList<Game>();
    }

    public String getCountry() {
        return this.countryName;
    }

    public void addGame(Game game) {
        games.add(game);
    }
    
    public float getGameCount(){
        return games.size();    
    }

    public String sortGameByGenre(String target) {
        String output = "";
        for (Game g : games) {
            if (g.getGenre().equals(target)) {
                if (output.equals("")) {
                    output += g.getTitle();
                } else {
                    output += "," + g.getTitle();
                }
            }
        }
        return output;
    }
}
