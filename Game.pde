// Maxwell Sherman & Vincent Lombardi
// Final Project: Censored Games
// CPSC 313-01 Data Visualization
// 2020-05-04

public class Game {
    private String title;
    private String series;
    private ArrayList<String> country;
    private ArrayList<String> category;
    private ArrayList<String> status;
    private String dev;
    private String publisher;
    private String genreRaw;
    private String[] genre;
    
    
    // Constructor
    public Game(String title, String series, String country, String category, String status, String dev, String publisher, String genreRaw) {
        this.title = title;
        this.series = series;
        this.country = new ArrayList<String>();
        this.category = new ArrayList<String>();
        this.status = new ArrayList<String>();
        this.dev = dev;
        this.publisher = publisher;
        this.genreRaw = genreRaw;
        this.genre = genreRaw.split("\\|");    
        this.addInstance(country, category, status);
    }
    
    public void addInstance(String c, String cat, String s) {
        this.country.add(c);
        this.category.add(cat);
        this.status.add(s);
    }
        
    public String getTitle() {
        return this.title;  
    }
    
    public String getSeries() {
        return this.series;  
    }
      
    public float getBannedCount() {
        return this.country.size();
            
    }
    public String getCountry(int i) {
        return this.country.get(i);  
    }
    
    public String getCategory(int i) {
        return this.category.get(i);  
    }
    
    public String getStatus(int i) {
        return this.status.get(i);  
    }
    
    public String getDev() {
        return this.dev;  
    }
    
    public String getPublisher() {
        return this.publisher;  
    }
    
    public String getGenre() {
        return this.genreRaw;  
    }
    
    public Boolean isGenre(String target) {  
        //println(target);
        //println(genreRaw);
        for (String s : genre) {
            if (s.equals(target)) {
                return true;    
            }
        }
        return false; 
        
    }
    
    public Boolean isNation(String target) {
        if (country.contains(target)) {
            return(true);
        }
        return false;  
    }
}
