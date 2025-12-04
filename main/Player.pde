class Player {
  PVector pos;
  PVector wh;
  PVector baseWh;
  PVector vel;
  float speed;
  float baseSpeed;
  float jumpForce;
  float gravity;
  boolean onGround;
  color playerColor;
  int type;
  
  float health;
  float maxHealth;
  int invincibleFrame = 0;
  final int INVINCIBLE_TIME = 60;
  
  int leftKey, rightKey, jumpKey;
  char hookKeyChar;
  boolean movingLeft, movingRight, jumping;
  boolean tryingToHook;

  boolean isMicChar = false;
  float currentScale = 1.0;
  
  boolean hookActive = false;
  boolean isHooked = false;
  PVector hookPos;
  PVector hookDir;
  float hookSpeed = 20;
  float maxHookLen = 500;
  
  boolean isBomberChar = false;
  int jumpCount = 0;
  int lastJumpTime = 0;
  int doubleJumpWindow = 20;
  char bombKeyChar;
  char attackKeyChar;
  boolean tryingToBomb = false;
  boolean tryingToAttack = false;
  ArrayList<Bomb> bombs;
  int maxBombs = 3;
  boolean jumpPressed = false;
  Game gameInstance = null;
    
  boolean isFreezeChar = false;
  boolean isFrozen = false;
  int freezeTimer = 0;
  int moveTimeLimit = 300;
  int freezeDuration = 120;
  ArrayList<Bullet> bullets = new ArrayList<Bullet>();
  
  Player(float x, float y, color c, int leftKey, int rightKey, int jumpKey, char attackKey, char bombKey, int type) {
    this.pos = new PVector(x, y);
    this.baseWh = new PVector(30, 40);
    this.wh = baseWh.copy();
    this.vel = new PVector(0, 0);
    this.baseSpeed = 5;
    this.speed = baseSpeed;
    this.jumpForce = 12;
    this.gravity = 0.6;
    this.onGround = false;
    this.playerColor = c;
    this.type = type;
    this.maxHealth = 100;
    this.health = maxHealth;
    
    this.leftKey = leftKey;
    this.rightKey = rightKey;
    this.jumpKey = jumpKey;
    this.movingLeft = false;
    this.movingRight = false;
    this.jumping = false;
    this.hookKeyChar = bombKey;
    this.bombKeyChar = bombKey;
    this.attackKeyChar = attackKey;

    this.hookPos = new PVector(0,0);
    this.hookDir = new PVector(0,0);
    this.bombs = new ArrayList<Bomb>();
  }

  void setMicMode() {
    this.isMicChar = true;
  }
  
  void setBomberMode() {
    this.isBomberChar = true;
    this.speed = this.baseSpeed * 0.7;
  }

  void setFreezeMode() {
    this.isFreezeChar = true;
  }
  
  void fire8Directions() {
    float cx = pos.x + wh.x / 2;
    float cy = pos.y + wh.y / 2;
    float[][] dirs = {
      {0, -1}, {0, 1}, {-1, 0}, {1, 0},
      {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
    };
    for (float[] dir : dirs) {
      bullets.add(new Bullet(cx, cy, dir[0], dir[1]));
    }
  }
  
  void update(ArrayList<Platform> platforms, Player otherPlayer) {
    if (invincibleFrame > 0) {
      invincibleFrame--;
    }
    
    if (isBomberChar) {
      if (onGround && jumpCount > 0) {
        jumpCount = 0;
      }
      
      if (tryingToBomb && bombs.size() < maxBombs) {
        bombs.add(new Bomb(pos.x + wh.x/2, pos.y + wh.y/2));
        tryingToBomb = false;
      }
      
      for (int i = bombs.size() - 1; i >= 0; i--) {
        Bomb b = bombs.get(i);
        b.update();
        
        if (b.isExploding()) {
          float distToSelf = dist(b.pos.x, b.pos.y, pos.x + wh.x/2, pos.y + wh.y/2);
          if (distToSelf < b.explosionRadius) {
            PVector knockbackSelf = new PVector(
              pos.x + wh.x/2 - b.pos.x,
              pos.y + wh.y/2 - b.pos.y
            );
            knockbackSelf.normalize();
            
            if (knockbackSelf.y > 0) {
              knockbackSelf.y -= 0.5;
            } else {
              knockbackSelf.y -= 0.3;
            }
            
            knockbackSelf.normalize();
            knockbackSelf.mult(30);
            vel.add(knockbackSelf);
            takeDamage(15);
          }
          
          float distToOther = dist(b.pos.x, b.pos.y, otherPlayer.pos.x + otherPlayer.wh.x/2, otherPlayer.pos.y + otherPlayer.wh.y/2);
          if (distToOther < b.explosionRadius) {
            PVector knockback = new PVector(
              otherPlayer.pos.x + otherPlayer.wh.x/2 - b.pos.x,
              otherPlayer.pos.y + otherPlayer.wh.y/2 - b.pos.y
            );
            knockback.normalize();
            
            if (knockback.y > 0) {
              knockback.y -= 0.5;
            } else {
              knockback.y -= 0.3;
            }
            
            knockback.normalize();
            knockback.mult(30);
            otherPlayer.vel.add(knockback);
            otherPlayer.takeDamage(20);
          }
        }
        
        if (b.isFinished()) {
          bombs.remove(i);
        }
      }
    }
    
    if (isMicChar) {
      float vol = analyzer.analyze();

      boolean canMove = vol > 0.01; 
      if (!canMove) {
        movingLeft = false;
        movingRight = false;
      }
      
      float targetScale = map(vol, 0.01, 0.15, 1.0, 2.0); 
      
      if (targetScale < 1.0) targetScale = 1.0;
      currentScale = lerp(currentScale, targetScale, 0.1); 
      
      wh.x = baseWh.x * currentScale;
      wh.y = baseWh.y * currentScale;
      speed = baseSpeed * (1.0 + (currentScale - 1.0) * 0.5);
      
      if (currentScale > 1.5 && checkCollision(otherPlayer)) {
        otherPlayer.pos.set(DESIGN_WIDTH/2, 50);
        otherPlayer.vel.set(0, 0);
        otherPlayer.takeDamage(40);
      }
    }

    if (isMicChar) {
      if (tryingToHook && !hookActive) {
        hookActive = true;
        isHooked = false;
        hookPos = new PVector(pos.x + wh.x/2, pos.y + wh.y/2);
        
        float dx = 0;
        float dy = -1;
        if (movingLeft) { dx = -1; dy = -1; }
        else if (movingRight) { dx = 1; dy = -1; }
        else { dx = (vel.x > 0 ? 1 : -1); dy = -1.2; }
        
        hookDir = new PVector(dx, dy).normalize();
      }
      
      if (hookActive) {
        if (!isHooked) {
          hookPos.add(PVector.mult(hookDir, hookSpeed));
          
          for (Platform p : platforms) {
            if (hookPos.x >= p.pos.x && hookPos.x <= p.pos.x + p.wh.x &&
                hookPos.y >= p.pos.y && hookPos.y <= p.pos.y + p.wh.y) {
              isHooked = true;
              break;
            }
          }
          
          if (!isHooked) {
            if (hookPos.x <= 0 || hookPos.x >= DESIGN_WIDTH || hookPos.y <= 0 || hookPos.y >= DESIGN_HEIGHT) {
              isHooked = true;
              
              if (hookPos.x < 0) hookPos.x = 0;
              if (hookPos.x > DESIGN_WIDTH) hookPos.x = DESIGN_WIDTH;
              if (hookPos.y < 0) hookPos.y = 0;
              if (hookPos.y > DESIGN_HEIGHT) hookPos.y = DESIGN_HEIGHT;
            }
          }
          
          if (dist(pos.x, pos.y, hookPos.x, hookPos.y) > maxHookLen) {
            hookActive = false;
          }
          
        } else {
          PVector pullDir = PVector.sub(hookPos, new PVector(pos.x + wh.x/2, pos.y + wh.y/2));
          float distance = pullDir.mag();
          pullDir.normalize();
          
          float pullForce = 0.8; 
          vel.add(pullDir.mult(pullForce));
          
          vel.y *= 0.98; 
          vel.limit(20);
        }
      
        if (!tryingToHook) {
          hookActive = false;
          isHooked = false;
        }
      }
    }
    
    if (isFreezeChar) {
      freezeTimer++;
      
      if (!isFrozen) {
        if (freezeTimer > moveTimeLimit) { 
          isFrozen = true;
          freezeTimer = 0;
          vel.set(0, 0);
          fire8Directions();
        }
      } else {
        vel.set(0, 0); 
        if (freezeTimer > freezeDuration) { 
          isFrozen = false;
          freezeTimer = 0;
        }
      }
      
      for (int i = bullets.size() - 1; i >= 0; i--) {
        Bullet b = bullets.get(i);
        b.update();
        
        if (b.pos.x > otherPlayer.pos.x && b.pos.x < otherPlayer.pos.x + otherPlayer.wh.x &&
            b.pos.y > otherPlayer.pos.y && b.pos.y < otherPlayer.pos.y + otherPlayer.wh.y) {
            
          otherPlayer.takeDamage(34);
          b.active = false;
        }
        
        if (!b.active) bullets.remove(i);
      }
    }

    if (!isHooked && !isFrozen) { 
      if (movingLeft) vel.x = -speed;
      else if (movingRight) vel.x = speed;
      else if (onGround) vel.x *= 0.8;
      else vel.x *= 0.98;
    }

    if (!isFrozen) {
      vel.y += gravity;
    }
    if (vel.y > 15) vel.y = 15;

    if (vel.y > 15) {
      vel.y = 15;
    }
    
    if (isBomberChar) {
      if (jumping && !jumpPressed) {
        jumpPressed = true;
        
        if (onGround) {
          int currentTime = frameCount;
          if (currentTime - lastJumpTime < doubleJumpWindow && jumpCount == 1) {
            vel.y = -jumpForce * 1.1;
            jumpCount = 2;
          } else {
            vel.y = -jumpForce;
            jumpCount = 1;
            lastJumpTime = currentTime;
          }
          onGround = false;
        } else if (jumpCount == 1) {
          int currentTime = frameCount;
          if (currentTime - lastJumpTime < doubleJumpWindow) {
            vel.y = -jumpForce * 1.1;
            jumpCount = 2;
          }
        }
      } else if (!jumping) {
        jumpPressed = false;
      }
    }
    else if (jumping && onGround && !isFrozen) {
      vel.y = -jumpForce;
      onGround = false;
    }
    
    pos.add(vel);
    
    onGround = false;
    for (Platform p : platforms) {
      if (p.checkTopCollision(pos, wh, vel.y)) {
        pos.y = p.pos.y - wh.y;
        vel.y = 0;
        onGround = true;
      }
      else if (p.overlaps(pos, wh)) {
        if (vel.x > 0 && pos.x + wh.x > p.pos.x && pos.x < p.pos.x) {
          pos.x = p.pos.x - wh.x;
          vel.x = 0;
        }
        else if (vel.x < 0 && pos.x < p.pos.x + p.wh.x && pos.x + wh.x > p.pos.x + p.wh.x) {
          pos.x = p.pos.x + p.wh.x;
          vel.x = 0;
        }
        else if (vel.y < 0 && pos.y < p.pos.y + p.wh.y && pos.y + wh.y > p.pos.y + p.wh.y) {
          pos.y = p.pos.y + p.wh.y;
          vel.y = 0;
        }
      }
    }
    
    if (pos.x < 0) {
      pos.x = 0;
      vel.x = 0;
    }
    if (pos.x + wh.x > DESIGN_WIDTH) {
      pos.x = DESIGN_WIDTH - wh.x;
      vel.x = 0;
    }
    if (pos.y < 0) {
      pos.y = 0;
      vel.y = 0;
    }
    if (pos.y + wh.y > DESIGN_HEIGHT) {
      pos.y = DESIGN_HEIGHT - wh.y;
      vel.y = 0;
      onGround = true;
    }
  }

  boolean checkCollision(Player other) {
    return !(pos.x + wh.x < other.pos.x || pos.x > other.pos.x + other.wh.x || 
             pos.y + wh.y < other.pos.y || pos.y > other.pos.y + other.wh.y);
  }

  
  void display() {
    fill(playerColor);
    stroke(0);
    strokeWeight(2);
    rect(pos.x, pos.y, wh.x, wh.y);
    
    if (type == 0) {
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.3, 6, 6);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.3, 6, 6);
      
      fill(0);
      noStroke();
      ellipse(pos.x + wh.x * 0.5, pos.y + wh.y * 0.65, wh.x * 0.4, wh.x * 0.4);
      
      stroke(255, 100, 0);
      strokeWeight(2);
      line(pos.x + wh.x * 0.5, pos.y + wh.y * 0.45, 
           pos.x + wh.x * 0.5, pos.y + wh.y * 0.3);
      
      fill(255, 200, 0);
      noStroke();
      ellipse(pos.x + wh.x * 0.5, pos.y + wh.y * 0.3, 4, 4);
      
      stroke(0);
      strokeWeight(2);
    }
    
    else if (type == 1) {
      fill(255, 0, 0);
      noStroke();
      rect(pos.x, pos.y + wh.y * 0.15, wh.x, wh.y * 0.15);
      
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.35, 6, 6);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.35, 6, 6);
      
      fill(0, 0, 50);
      noStroke();
      rect(pos.x + wh.x * 0.1, pos.y + wh.y * 0.5, wh.x * 0.8, wh.y * 0.25);
      
      stroke(0);
      strokeWeight(2);
    }
    
    else if (type == 2) {
      fill(150, 150, 150);
      noStroke();
      rect(pos.x, pos.y, wh.x, wh.y * 0.5);
      
      fill(50);
      rect(pos.x + wh.x * 0.15, pos.y + wh.y * 0.25, wh.x * 0.7, wh.y * 0.1);
      
      fill(200, 200, 200);
      rect(pos.x + wh.x * 0.1, pos.y + wh.y * 0.55, wh.x * 0.8, wh.y * 0.35);
      
      fill(255, 215, 0);
      ellipse(pos.x + wh.x * 0.5, pos.y + wh.y * 0.7, wh.x * 0.3, wh.y * 0.2);
      
      stroke(0);
      strokeWeight(2);
    }
    
    else if (type == 3) {
      fill(100, 50, 200);
      noStroke();
      triangle(pos.x + wh.x * 0.5, pos.y - wh.y * 0.5, 
               pos.x, pos.y + wh.y * 0.2,
               pos.x + wh.x, pos.y + wh.y * 0.2);
      
      rect(pos.x - wh.x * 0.1, pos.y + wh.y * 0.15, wh.x * 1.2, wh.y * 0.1);
      
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.35, 6, 6);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.35, 6, 6);
      
      fill(200, 200, 200);
      triangle(pos.x + wh.x * 0.5, pos.y + wh.y * 0.5,
               pos.x + wh.x * 0.2, pos.y + wh.y * 0.9,
               pos.x + wh.x * 0.8, pos.y + wh.y * 0.9);
      
      fill(255, 215, 0);
      rect(pos.x + wh.x * 0.1, pos.y + wh.y * 0.6, wh.x * 0.8, wh.y * 0.1);
      
      fill(255, 255, 0);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.75, 3, 3);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.8, 3, 3);
      
      stroke(0);
      strokeWeight(2);
    }
    
    else {
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.3, 5, 5);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.3, 5, 5);
    }
    
    if (hookActive) {
      stroke(200, 50, 50);
      strokeWeight(3);
      line(pos.x + wh.x/2, pos.y + wh.y/2, hookPos.x, hookPos.y);
      fill(0);
      noStroke();
      ellipse(hookPos.x, hookPos.y, 8, 8);
    }
    
    if (isBomberChar) {
      for (Bomb b : bombs) {
        b.display();
      }
    }
    
    if (isFreezeChar) {
      for (Bullet b : bullets) {
        b.display();
      }
      if (isFrozen) {
        fill(0, 200, 255, 100);
        rect(pos.x - 5, pos.y - 5, wh.x + 10, wh.y + 10);
      }
    }
    
    displayHealth();
  }
  
  void handleKeyPress(int k, int kc) {
    if (k == leftKey || kc == leftKey) {
      movingLeft = true;
    }
    if (k == rightKey || kc == rightKey) {
      movingRight = true;
    }
    if (k == jumpKey || kc == jumpKey) {
      jumping = true;
    }
    
    if (isMicChar && (Character.toLowerCase((char)k) == hookKeyChar)) {
      tryingToHook = true;
    }
    
    if (isBomberChar && (Character.toLowerCase((char)k) == bombKeyChar)) {
      tryingToBomb = true;
    }
    
    if (type == 1 && (Character.toLowerCase((char)k) == bombKeyChar)) {
      if (gameInstance != null) {
        gameInstance.throwBomb(this);
      }
    }
  }
  
  void handleKeyRelease(int k, int kc) {
    if (k == leftKey || kc == leftKey) {
      movingLeft = false;
    }
    if (k == rightKey || kc == rightKey) {
      movingRight = false;
    }
    if (k == jumpKey || kc == jumpKey) {
      jumping = false;
    }
    
    if (isMicChar && (Character.toLowerCase((char)k) == hookKeyChar)) {
      tryingToHook = false;
    }
  }

  void setInvertedControls() {
    int temp = leftKey;
    leftKey = rightKey;
    rightKey = temp;
  }
  
  void takeDamage(float damage) {
    if (invincibleFrame <= 0) {
      health -= damage;
      if (health < 0) health = 0;
      invincibleFrame = INVINCIBLE_TIME;
    }
  }
  
  void displayHealth() {
    float barWidth = 60;
    float barHeight = 8;
    float barX = pos.x - barWidth / 2 + wh.x / 2;
    float barY = pos.y - 15;
    
    if (invincibleFrame > 0 && invincibleFrame % 6 < 3) {
      return;
    }
    
    fill(50);
    noStroke();
    rect(barX, barY, barWidth, barHeight, 2);
    
    float healthPercent = health / maxHealth;
    if (healthPercent > 0.5) {
      fill(50, 200, 50);
    } else if (healthPercent > 0.25) {
      fill(255, 200, 0);
    } else {
      fill(255, 50, 50);
    }
    rect(barX, barY, barWidth * healthPercent, barHeight, 2);
    
    stroke(200);
    strokeWeight(1);
    noFill();
    rect(barX, barY, barWidth, barHeight, 2);
  }
}

class Bomb {
  PVector pos;
  float timer;
  float fuseTime = 90;
  float explosionTime = 20;
  float explosionRadius = 100;
  boolean exploded = false;
  
  Bomb(float x, float y) {
    this.pos = new PVector(x, y);
    this.timer = 0;
  }
  
  void update() {
    timer++;
    if (timer > fuseTime && !exploded) {
      exploded = true;
      timer = 0;
    }
  }
  
  boolean isExploding() {
    return exploded && timer < explosionTime;
  }
  
  boolean isFinished() {
    return exploded && timer >= explosionTime;
  }
  
  void display() {
    if (!exploded) {
      fill(0);
      stroke(0);
      strokeWeight(2);
      ellipse(pos.x, pos.y, 20, 20);
      
      float blinkAlpha = 128 + sin(timer * 0.3) * 127;
      fill(255, 100, 0, blinkAlpha);
      noStroke();
      ellipse(pos.x, pos.y - 12, 5, 5);
      
      float timeRatio = timer / fuseTime;
      fill(255 * timeRatio, 255 * (1 - timeRatio), 0);
      textSize(10);
      textAlign(CENTER);
      text(int(fuseTime - timer) / 60 + 1, pos.x, pos.y + 30);
    } else if (isExploding()) {
      float explosionScale = timer / explosionTime;
      float currentRadius = explosionRadius * explosionScale;
      
      noStroke();
      fill(255, 255, 0, 200 * (1 - explosionScale));
      ellipse(pos.x, pos.y, currentRadius * 2, currentRadius * 2);
      
      fill(255, 150, 0, 150 * (1 - explosionScale));
      ellipse(pos.x, pos.y, currentRadius * 1.5, currentRadius * 1.5);
      
      fill(255, 50, 0, 100 * (1 - explosionScale));
      ellipse(pos.x, pos.y, currentRadius, currentRadius);
    }
  }
}

class ThrowBomb {
  PVector pos;
  PVector vel;
  float radius = 8;
  float gravity = 0.5;
  boolean exploded = false;
  int throwFrame = 10;
  float explosionRadius = 80;
  
  ThrowBomb(float x, float y, float vx, float vy) {
    this.pos = new PVector(x, y);
    this.vel = new PVector(vx, vy);
  }
  
  void update(ArrayList<Platform> platforms) {
    if (!exploded) {
      if (throwFrame > 0) throwFrame--;
      
      vel.y += gravity;
      pos.add(vel);
      
      for (Platform p : platforms) {
        if (pos.x > p.pos.x && pos.x < p.pos.x + p.wh.x &&
            pos.y + radius > p.pos.y && pos.y - radius < p.pos.y + p.wh.y) {
          exploded = true;
          return;
        }
      }
      
      if (pos.x < radius || pos.x > DESIGN_WIDTH - radius ||
          pos.y < radius || pos.y > DESIGN_HEIGHT - radius) {
        exploded = true;
      }
    }
  }
  
  boolean checkPlayerCollision(Player p) {
    return dist(pos.x, pos.y, p.pos.x + p.wh.x/2, p.pos.y + p.wh.y/2) < radius + max(p.wh.x, p.wh.y)/2;
  }
  
  void applyBlastToPlayer(Player p) {
    float d = dist(pos.x, pos.y, p.pos.x + p.wh.x/2, p.pos.y + p.wh.y/2);
    if (d < explosionRadius) {
      PVector knockback = new PVector(
        p.pos.x + p.wh.x/2 - pos.x,
        p.pos.y + p.wh.y/2 - pos.y
      );
      knockback.normalize();
      knockback.mult(15);
      p.vel.add(knockback);
      
      p.takeDamage(25);
    }
  }
  
  void display() {
    if (!exploded) {
      fill(50);
      stroke(0);
      strokeWeight(2);
      ellipse(pos.x, pos.y, radius * 2, radius * 2);
      
      stroke(255, 100, 0);
      line(pos.x, pos.y, pos.x, pos.y - 10);
    }
  }
  
  void displayExplosion() {
    if (exploded) {
      noStroke();
      fill(255, 200, 0, 150);
      ellipse(pos.x, pos.y, explosionRadius * 2, explosionRadius * 2);
      fill(255, 100, 0, 100);
      ellipse(pos.x, pos.y, explosionRadius * 1.5, explosionRadius * 1.5);
    }
  }
}

class Bullet {
  PVector pos;
  PVector vel;
  float size = 15;
  boolean active = true;

  Bullet(float x, float y, float vx, float vy) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    vel.normalize();
    vel.mult(3);
  }

  void update() {
    pos.add(vel);
    if (pos.x < 0 || pos.x > DESIGN_WIDTH || pos.y < 0 || pos.y > DESIGN_HEIGHT) {
      active = false;
    }
  }

  void display() {
    fill(255, 255, 0);
    noStroke();
    ellipse(pos.x, pos.y, size, size);
  }
}
