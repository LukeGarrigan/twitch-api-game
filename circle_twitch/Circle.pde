public class Circle implements Comparable<Circle> {
  private int dieCount;
  private int invulnerableCount;
  private float dampen;
  private String name;
  private float x;
  private float y;
  private float radius;
  
  private float r;
  private float g;
  private float b;
  
  private float xSpeed;
  private float ySpeed;
  
  private float diameter;
  private boolean visible = true;
  
  private boolean invulnerable = false;
  private int incrementValue;
  
  private boolean isBelowAverageVelocity;
 
  private float targetMass;
  private boolean isGettingBigger;
  
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
    
    
    if (abs(this.xSpeed) + abs(this.ySpeed) < 20) {
      isBelowAverageVelocity = true;
      incrementValue = 20;
    } else {
      isBelowAverageVelocity = false;
      incrementValue = 10;  
    }
    
   
    if (this.xSpeed < 0) {
      this.xSpeed -= incrementValue;       
    } else {
      this.xSpeed += incrementValue;
    }
    
    if (this.ySpeed < 0) {
      this.ySpeed -= incrementValue;       
    } else {
      this.ySpeed += incrementValue;
    }
  }
  
  public void decreaseSpeed() {
    
    if (isBelowAverageVelocity) {
      incrementValue = incrementValue - 1;
    }
    if (this.xSpeed < 0) {
      this.xSpeed += incrementValue;
    } else {
      this.xSpeed -= incrementValue;
    }
    
    if (this.ySpeed < 0) {
      this.ySpeed += incrementValue;
    } else {
      this.ySpeed -= incrementValue;
    }
  }
  
  
  @Override
  public int compareTo(Circle other) {
    return (other.getScore() - this.score);    
  }
  
  public void processCircle() {
    
    if (isGettingBigger) {
      diameter = lerp(diameter, targetMass, 0.1);
      
      if (diameter == targetMass) {
        isGettingBigger = false;
      }
    }
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
    
    textSize(20);
    text(floor(abs(xSpeed) + abs(ySpeed)), x, y+(diameter/10));
    
    textSize(13);
    text(score, x, y-(radius+19));
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
        circle.incrementPoint(this);
      } else if(thisSpeed > circleSpeed) {
        circle.die();
        incrementPoint(circle);
      } else if (thisSpeed == circleSpeed) {
        int number = floor(random(0, 2));
        if (number == 1) {
          die();
          circle.incrementPoint(this);
        } else {
          circle.die();
          incrementPoint(circle);
        }
      }
  }
  
  public void die() {
    this.visible = false;
    this.isGettingBigger = false;
    this.dieCount = 0;
  }
  
  public void respawn() {
    this.visible = true;
    this.diameter = START_SIZE * 2;
    this.score = 0;
    this.x =  START_SIZE*2+random(width-(START_SIZE*4));
    this.y =  START_SIZE*2+random(height-(START_SIZE*4));
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
  
  
  
  public void incrementPoint(Circle circle) {
    float otherCircleDiameter = circle.getDiameter();
    float massIncrease = sqrt(otherCircleDiameter*otherCircleDiameter+this.diameter*this.diameter)/17;  
    targetMass = diameter + massIncrease;
    isGettingBigger = true;
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
