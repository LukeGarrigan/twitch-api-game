JSONObject json;
import java.util.*;
PImage backgroundImage;
public static final float MAX_SPEED = 20;
public static final float MIN_SPEED = -20;
public static final float START_SIZE = 30;
public static final int NUMBER_OF_BOOSTS = 5;
public static final String streamName = "codeheir";
public static final boolean BIG = false;
int apiCallCount = 0;

Set<String> twitchViewers;
Set<Circle> viewerCircles;

List<Boost> boosts;


void setup() {

//  size(1805, 761);
//  backgroundImage = loadImage("twitch_background_2.png");
  size(904, 601);
  backgroundImage = loadImage("twitch_background.png");
  
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
    viewerCircles.add(new Circle(viewerName, START_SIZE*2+random(width-(START_SIZE*4)), START_SIZE*2+random(height-(START_SIZE*4)), START_SIZE));
  }
   
   
  boosts = new ArrayList<Boost>(); 
  for (int i = 0; i < NUMBER_OF_BOOSTS; i++) {
    boosts.add(new Boost(boosts));
  }
   
    
}

void draw() {
  apiCallCount++;
  if (apiCallCount > 900) {
    thread("getNewPlayers");
    this.apiCallCount = 0;
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
  displayPlayersThatHaveLeft(namesToBeRemoved);
  
  removeStreamLeaversFromGame(namesToBeRemoved);
  
  
  
  twitchViewers = newNames;
}

private void displayPlayersThatHaveLeft(List<String> names) { 
  for(int i = 0; i < 10000; i++) {
    if (!names.isEmpty()) {
      text(names.get(0), 10, 10);   //<>//
    }
  }
  
}

private void checkIfPlayerExistsAndAdd(String viewerName, Set<String> newNames) {
     newNames.add(viewerName);
     Circle newPlayer = new Circle(viewerName, START_SIZE*2+random(width-(START_SIZE*4)), START_SIZE*2+random(height-(START_SIZE*4)), START_SIZE);
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
