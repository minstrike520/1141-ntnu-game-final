// 炸彈類
class Bomb {
  PVector pos;
  PVector vel;
  PVector wh;
  float radius;
  float gravity = 0.6;
  float explosionRadius = 100;
  boolean exploded = false;
  float blastForce = 15;
  int throwFrame = 0; // 剛拋出後的幀數計數，用來避免立即碰撞
  
  Bomb(float x, float y, float vx, float vy) {
    this.pos = new PVector(x, y);
    this.vel = new PVector(vx, vy);
    this.radius = 8;
    this.wh = new PVector(radius * 2, radius * 2);
    this.throwFrame = 5; // 前5幀不檢測玩家碰撞
  }
  
  void update(ArrayList<Platform> platforms) {
    if (exploded) return;
    
    // 減少拋出幀數
    if (throwFrame > 0) {
      throwFrame--;
    }
    
    // 應用重力
    vel.y += gravity;
    if (vel.y > 15) vel.y = 15;
    
    // 更新位置
    pos.add(vel);
    
    // 邊界檢查 - 碰到邊界就爆炸 (考慮半徑)
    if (pos.x - radius < 0 || pos.x + radius > width || pos.y - radius < 0 || pos.y + radius > height) {
      exploded = true;
      return;
    }
    
    // 平台碰撞檢查 - 碰到平台就爆炸 (只在拋出幀數過後檢查)
    if (throwFrame <= 0) {
      for (Platform p : platforms) {
        if (checkPlatformCollision(p)) {
          exploded = true;
          return;
        }
      }
    }
  }
  
  boolean checkPlatformCollision(Platform p) {
    // 簡單的圓形與矩形碰撞檢測
    float closestX = constrain(pos.x, p.pos.x, p.pos.x + p.wh.x);
    float closestY = constrain(pos.y, p.pos.y, p.pos.y + p.wh.y);
    
    float distance = dist(pos.x, pos.y, closestX, closestY);
    return distance < radius;
  }
  
  boolean checkPlayerCollision(Player player) {
    // 圓形與矩形碰撞檢測
    float closestX = constrain(pos.x, player.pos.x, player.pos.x + player.wh.x);
    float closestY = constrain(pos.y, player.pos.y, player.pos.y + player.wh.y);
    
    float distance = dist(pos.x, pos.y, closestX, closestY);
    return distance < radius + 10; // 10 是玩家碰撞範圍的大致值
  }
  
  void applyBlastToPlayer(Player player) {
    // 計算爆炸時玩家與炸彈中心的距離
    float distance = dist(pos.x, pos.y, player.pos.x + player.wh.x / 2, player.pos.y + player.wh.y / 2);
    
    // 如果在爆炸範圍內
    if (distance < explosionRadius) {
      // 計算爆炸方向
      float angle = atan2(player.pos.y + player.wh.y / 2 - pos.y, 
                          player.pos.x + player.wh.x / 2 - pos.x);
      
      // 根據距離計算爆炸力度（距離越遠越弱）
      float force = blastForce * (1.0 - distance / explosionRadius);
      
      // 施加爆炸力到玩家速度
      player.vel.x += cos(angle) * force;
      player.vel.y += sin(angle) * force;
      
      // 造成傷害 (距離越近傷害越高)
      float damage = 25 * (1.0 - distance / explosionRadius);
      player.takeDamage(damage);
    }
  }
  
  void display() {
    if (exploded) return;
    
    // 繪製炸彈 (黑色圓形)
    fill(0);
    stroke(100);
    strokeWeight(2);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    // 繪製引信
    stroke(50);
    strokeWeight(1);
    line(pos.x, pos.y - radius, pos.x, pos.y - radius - 5);
  }
  
  void displayExplosion() {
    if (!exploded) return;
    
    // 爆炸效果 (橙色圓形)
    fill(255, 165, 0, 100);
    stroke(255, 100, 0, 150);
    strokeWeight(2);
    ellipse(pos.x, pos.y, explosionRadius * 2, explosionRadius * 2);
    
    // 爆炸中心
    fill(255, 200, 0, 150);
    noStroke();
    ellipse(pos.x, pos.y, explosionRadius * 0.6, explosionRadius * 0.6);
  }
  
  boolean isExplosionFinished() {
    // 爆炸持續2幀後消失
    return false; // 由 Game 類來管理生命週期
  }
}
