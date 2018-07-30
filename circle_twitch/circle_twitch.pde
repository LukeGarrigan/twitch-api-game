JSONObject json;
import java.util.*;
PImage backgroundImage;
public static final float MAX_SPEED = 2;
public static final float MIN_SPEED = -2;
public static final float START_SIZE = 30;

Set<String> twitchViewers;
Set<Circle> viewerCircles;

void setup() {
  size(904, 601);
  backgroundImage = loadImage("twitch_background.png");
  json = loadJSONObject("https://tmi.twitch.tv/group/user/codeheir/chatters");
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
    viewerCircles.add(new Circle(viewerName, random(width/2)+50, random(height/2)+50, START_SIZE));
  }
   
}

void draw() {
  clear();
  background(backgroundImage);
    
  for (Circle viewer: viewerCircles) {
    viewer.processCircle();
  }
  
  displayTopScores();


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
    
    this.dampen = 1;
    this.score = 0;
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
    this.x =  random(width/2)+50;
    this.y =  random(height/2)+50;
    setXSpeed();
    setYSpeed();
    this.invulnerable = true;
    this.invulnerableCount = 0;
    
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
