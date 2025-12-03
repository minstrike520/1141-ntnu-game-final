class Platform {
  PVector pos;
  PVector wh;
  
  Platform(float x, float y, float w, float h) {
    this.pos = new PVector(x, y);
    this.wh = new PVector(w, h);
  }
  
  void display() {
    fill(255);
    stroke(0);
    strokeWeight(2);
    rect(pos.x, pos.y, wh.x, wh.y);
  }
  
  // Check if a point is inside the platform
  boolean contains(PVector point) {
    return point.x >= pos.x && point.x <= pos.x + wh.x && 
           point.y >= pos.y && point.y <= pos.y + wh.y;
  }
  
  // Check if a rectangle overlaps with this platform
  boolean overlaps(PVector rectPos, PVector rectWh) {
    return !(rectPos.x + rectWh.x < pos.x || rectPos.x > pos.x + wh.x || 
             rectPos.y + rectWh.y < pos.y || rectPos.y > pos.y + wh.y);
  }
  
  // Check collision from top (for landing on platform)
  boolean checkTopCollision(PVector playerPos, PVector playerWh, float vy) {
    // Player is falling down and feet are within platform bounds
    if (vy > 0) {
      float playerBottom = playerPos.y + playerWh.y;
      float playerLeft = playerPos.x;
      float playerRight = playerPos.x + playerWh.x;
      
      // Check if player's bottom edge crossed the platform's top edge
      if (playerBottom >= pos.y && playerBottom <= pos.y + 10) {
        // Check horizontal overlap
        if (playerRight > pos.x && playerLeft < pos.x + wh.x) {
          return true;
        }
      }
    }
    return false;
  }
}
