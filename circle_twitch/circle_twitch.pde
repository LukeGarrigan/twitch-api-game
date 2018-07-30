JSONObject json;
import java.util.*;
PImage backgroundImage;
public static final float MAX_SPEED = 20;
public static final float MIN_SPEED = -20;
public static final float START_SIZE = 30;
public static final int NUMBER_OF_BOOSTS = 5;

public static final String streamName = "codeheir";
int apiCallCount = 0;

Set<String> twitchViewers;
Set<Circle> viewerCircles;

List<Boost> boosts;


void setup() {
  size(1805, 761);
  backgroundImage = loadImage("twitch_background_2.png");
  json = loadJSONObject("https://tmi.twitch.tv/group/user/" +streamName+"/chatters");
  JSONObject chatters = json.getJSONObject("chatters");
  JSONArray names = chatters.getJSONArray("viewers");
  JSONArray moderators = chatters.getJSONArray("moderators");
  
  twitchViewers = new HashSet<String>();
  for (int i = 0; i < names.size(); i++ ) {
    String viewerName = names.get(i).toString().trim();   
    twitchViewers.add(viewerName);
  }
  
  for (int i = 0; i < moderators.size(); i++ ) {
    String viewerName = moderators.get(i).toString().trim();   
    twitchViewers.add(viewerName);
  }
  
  viewerCircles = new HashSet<Circle>();
  for (String viewerName: twitchViewers) {
    viewerCircles.add(new Circle(viewerName, random(width-(START_SIZE*2)), random(height-(START_SIZE*2)), START_SIZE));
  }
   
   
  boosts = new ArrayList<Boost>(); 
  for (int i = 0; i < NUMBER_OF_BOOSTS; i++) {
    boosts.add(new Boost(random(width-15), random(height-15)));
  }
   
    
}

void draw() {
  apiCallCount++;
  if (apiCallCount % 900 == 0) {
    thread("getNewPlayers");
  }
  
  clear();
  background(backgroundImage);
    
  for (Boost boost: boosts) {
    boost.drawBoost();
  }  
  for (Circle viewer: viewerCircles) {
    viewer.processCircle();
  }
  
  displayNumberOfPlayers();
  displayTopScores();
}

void getNewPlayers() {
  json = loadJSONObject("https://tmi.twitch.tv/group/user/" +streamName+"/chatters");
  JSONObject chatters = json.getJSONObject("chatters");
  JSONArray names = chatters.getJSONArray("viewers");  
  JSONArray moderators = chatters.getJSONArray("moderators");
   
   
  Set<String> newNames = new HashSet<String>();
  for (int i = 0; i < names.size(); i++ ) {
     checkIfPlayerExistsAndAdd(names.get(i).toString().trim(), newNames); 
  }
  for (int i = 0; i < moderators.size(); i++ ) {
     checkIfPlayerExistsAndAdd(moderators.get(i).toString().trim(), newNames); 
  }
  
  // check against existing players
  List<String> namesToBeRemoved = new ArrayList<String>();
  for (String oldName: twitchViewers) {
    if (!newNames.contains(oldName)){ 
       namesToBeRemoved.add(oldName);
    }
  }
  
  removeStreamLeaversFromGame(namesToBeRemoved);
  
  
  
  twitchViewers = newNames;
}

private void checkIfPlayerExistsAndAdd(String viewerName, Set<String> newNames) {
     newNames.add(viewerName);
     Circle newPlayer = new Circle(viewerName, random(width-(START_SIZE*2)), random(height-(START_SIZE*2)), START_SIZE);
     if(!viewerCircles.contains(newPlayer)) {
       viewerCircles.add(newPlayer);
     }
 }
private void removeStreamLeaversFromGame(List<String> namesToBeRemoved) {
  
  Set<Circle> copyOfCurrentPlayers = new HashSet<Circle>();
  for (Circle circle: viewerCircles) {
    copyOfCurrentPlayers.add(circle);
  }
  
  List<Circle> circleToBeRemoved = new ArrayList<Circle>();
  for (String name: namesToBeRemoved) {
    for (Circle circle: copyOfCurrentPlayers) {
      if (circle.getName().equals(name)) {
        circleToBeRemoved.add(circle);
      }
    }
  }
  
  copyOfCurrentPlayers.removeAll(circleToBeRemoved);
  
  viewerCircles = copyOfCurrentPlayers;
}

public void displayTopScores() {  
    
  List<Circle> circlesAsList = new ArrayList<Circle>();
  
  for (Circle circle: viewerCircles) {
    circlesAsList.add(circle);
  }
  Collections.sort(circlesAsList);
 
   
  fill(204, 204, 206, 150);
  rect(width-150, 0, 200, 200);
  fill(0);
  text("Top Scorers", width-80, 30);
  
  int yPosition = 50;
  textAlign(LEFT);
  for (int i = 0; i < circlesAsList.size() && i < 10; i++) {
    text(circlesAsList.get(i).toString(), width-130, yPosition);  
    yPosition = yPosition + 15;
  }
  
  
}

public void displayNumberOfPlayers() {
  fill(0);
  text("Number of players " + viewerCircles.size(), width/2, 20);
}

public class Boost {
  private float x;
  private float y;
  private float size;
  private PImage image;
  private boolean visible;
  
  // size is irrelevant 
  public Boost(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = 75;
    this.image = loadImage("boosts.png");
    this.visible = true;
  }
  
  
  public void drawBoost() {
    if (visible) {
      image(image, x, y); 
      checkCollision();
    }
  }
  
  public void checkCollision() {
    
    for (Circle circle: viewerCircles) {
      float tempX = this.x + this.size/2;
      float tempY = this.y + this.size/2;
      if (dist(circle.getX(), circle.getY(),tempX, tempY) <= ((this.size/2)+ circle.getDiameter()/2)) {
        circle.increaseSpeed();
        this.visible = false;
      }
    }
  }
  

}


public class Circle implements Comparable<Circle> {


  int dieCount;
  int invulnerableCount;
  float dampen;
  String name;
  float x;
  float y;
  float radius;
  
  float r;
  float g;
  float b;
  
  float xSpeed;
  float ySpeed;
  
  float diameter;
  boolean visible = true;
  
  boolean invulnerable = false;
  
  int score;
  public Circle(String name, float x, float y, float radius) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.radius = radius;
    
    this.diameter = radius * 2;
    r = random(255);
    g = random(255);
    b = random(255);
    
    xSpeed = floor(random(MIN_SPEED, MAX_SPEED));
    ySpeed = floor(random(MIN_SPEED, MAX_SPEED));
    
    this.dampen = 10;
    this.score = 0;
  }
  
  
  public void increaseSpeed() {
    
    if (this.xSpeed < 0) {
      this.xSpeed -= 10;       
    } else {
      this.xSpeed += 10;
    }
    
    if (this.ySpeed < 0) {
      this.ySpeed -= 10;       
    } else {
      this.ySpeed += 10;
    }
  }
  
  @Override
  public int compareTo(Circle other) {
    return (other.getScore() - this.score);    
  }
  
  public void processCircle() {
    
    
    this.x = this.x + (xSpeed/dampen);
    this.y = this.y + (ySpeed/dampen);
    // reset the radius as we are incrementing the diameter on eating
    this.radius = diameter/2;
    
    if (this.x < 0 + radius || this.x > width - radius) {
      this.xSpeed *= -1;
    }
    
    if (this.y < 0 + radius|| this.y > height - radius) {
      this.ySpeed *= -1;
    }
    

    
    if (this.visible) {
      checkInvulnerability();
      checkCollision();
      
      
      drawCircle();
      
    } else {
      
      if (dieCount > 180) {
        respawn();
      } else {
        this.dieCount++;
      }
    }
    

    
  }
  
  
  private void drawCircle() {
    ellipse(x, y, diameter, diameter);
    
    textAlign(CENTER);
    fill(0);   
    text(name, x+2, y-(radius+5));
    
    text(floor(abs(xSpeed) + abs(ySpeed)), x, y-(radius-16));
    
    text(score, x, y);
  }
  
  private void checkInvulnerability() {
      if(this.invulnerable) {
        this.invulnerableCount++;
        if (this.invulnerableCount > 120) {
          this.invulnerable = false;
          fill(r, g, b);
          noStroke();
        } else {
          fill(r, g, b, 100); 
        }
         
      } else {
        fill(r, g, b);
        noStroke();
      } 
  }
  public void setSize(float radius) {
    this.radius = radius;
  }
  
  public float getDiameter() {
    return this.diameter;
  }
  
  public void checkCollision() {
    
    for (Circle circle: viewerCircles) {
      if(!circle.getName().equals(this.name) && circle.isVisible() && !circle.isInvulnerable() && !this.invulnerable){
          if (dist(this.x, this.y, circle.getX(), circle.getY()) < (this.diameter/2 + circle.getDiameter()/2)) {   
             processCollision(circle);
          } 
      }
    }    
     
  }
  
  
  public boolean isInvulnerable() {
    return this.invulnerable;
  }

  
  public void processCollision(Circle circle) {
      float circleSpeed = abs(circle.getXSpeed()) + abs(circle.getYSpeed());
      float thisSpeed = abs(this.xSpeed) + abs(this.ySpeed);
      
      if (circleSpeed > thisSpeed){ 
        die();
        circle.incrementPoint();
      } else if(thisSpeed > circleSpeed) {
        circle.die();
        incrementPoint();
      } else if (thisSpeed == circleSpeed) {
        int number = floor(random(0, 2));
        if (number == 1) {
          die();
          circle.incrementPoint();
        } else {
          circle.die();
          incrementPoint();
        }
      }
  }
  
  public void die() {
    this.visible = false;
    this.dieCount = 0;
  }
  
  public void respawn() {
    this.visible = true;
    this.diameter = START_SIZE * 2;
    this.score = 0;
    this.x =  random(width-(START_SIZE*2));
    this.y =  random(height-(START_SIZE*2));
    setXSpeed();
    setYSpeed();
    this.invulnerable = true;
    this.invulnerableCount = 0;
    
  }
  
  
  @Override
  public boolean equals(Object circle) {    
    if (circle instanceof Circle) {
      Circle toBeCompared = (Circle) circle;
      return toBeCompared.getName().equals(this.getName());
    }
    return false;
  }
  
  @Override
  public int hashCode() {
    return Objects.hash(name);
  }
  
  public void setMax() {
    this.xSpeed = 20;
    this.ySpeed = 20;
  }
    
  public boolean isVisible() {
    return this.visible;
  }
  
  
  public void setXSpeed() {
    this.xSpeed =  floor(random(MIN_SPEED, MAX_SPEED));
  }
  
  public void setYSpeed() {
    this.ySpeed = floor(random(MIN_SPEED, MAX_SPEED));
  }
  
  
  public void incrementPoint() {
    this.diameter += 5;
    this.score++;
  }
  public float getXSpeed() {
    return this.xSpeed;
  }
  
  public float getYSpeed() {
    return this.ySpeed;
  }
  public String getName() {
    return this.name;
  }
  
  public float getX() {
    return this.x;
  }
  
  public float getY() {
    return this.y;
  }
  
  public int getScore() {
    return this.score;
  }
  
  @Override
  public String toString() {
    return this.name + ": " + this.score;
  }

}
