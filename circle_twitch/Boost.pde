public class Boost { //<>//
  private float x;
  private float y;
  private float size;
  private PImage image;
  private boolean visible;
  private int respawnCount;
  private Circle circleThatHitBoost;
  private List<Boost> boosts;

  private int boostId;
  // size is irrelevant 
  public Boost(List<Boost> boosts) {
    this.size = 75;   
    this.boosts = boosts;
    spawnAwayFromOtherBoosts();
    this.image = loadImage("boosts.png");
    this.visible = true;
  }
  
  public int getId() {
    return this.boostId;
  }

  private void spawnAwayFromOtherBoosts() {
    boolean isSpawnedAway = false;
    while (!isSpawnedAway) {
      this.x = random(width-size);
      this.y = random(height-size);

      boolean hasHitAnotherBoost = false;

      for (Boost boost : boosts) {
        if(boost == this) continue;
        float tempX = this.x + this.size/2;
        float tempY = this.y + this.size/2;

        float otherBoostX = boost.getX() + this.size/2;
        float otherBoostY = boost.getY() + this.size/2;



        if (dist(tempX, tempY, otherBoostX, otherBoostY) <= size * 2) {
          hasHitAnotherBoost = true;
        }
      }
      
      isSpawnedAway = !hasHitAnotherBoost;
      
    }
  }


  public void drawBoost() {
    if (visible) {
      image(image, x, y); 
      checkCollision();
    } else { 
      if (respawnCount > 240) {
        circleThatHitBoost.decreaseSpeed();
        spawnAwayFromOtherBoosts();
        this.visible = true;
      }
      respawnCount++;
    }
  }

  public void checkCollision() {
    for (Circle circle : viewerCircles) {
      if (circle.isVisible()) {
        float tempX = this.x + this.size/2;
        float tempY = this.y + this.size/2;
        if (dist(circle.getX(), circle.getY(), tempX, tempY) <= ((this.size/4)+ circle.getDiameter()/2)) {
          circleThatHitBoost = circle;
          circle.increaseSpeed();
          this.visible = false;
          this.respawnCount = 0;
        }
      }
    }
  }

  public float getX() {
    return this.x;
  }

  public float getY() {
    return this.y;
  }
}
