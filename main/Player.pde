class Player {
  // 遊戲實例參考
  Game gameInstance;
  
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
  
  // Controls
  int leftKey, rightKey, jumpKey,attcackKey;
  char hookKeyChar;
  char bombKeyChar;
  boolean movingLeft, movingRight, jumping;
  boolean tryingToHook;

   // --- 特殊能力變數 ---
  boolean isMicChar = false;
  float currentScale = 1.0;
  
  // 蜘蛛人鎖鏈變數
  boolean hookActive = false; // 鎖鏈是否射出中
  boolean isHooked = false;   // 鎖鏈是否已經勾到牆壁
  PVector hookPos;            // 鎖鏈頭的位置 (黏在牆上的點)
  PVector hookDir;            // 發射方向
  float hookSpeed = 20;       // 鎖鏈飛出去的速度
  float maxHookLen = 500;     // 鎖鏈最大長度
  // ------------------

  // --- 血量系統 ---
  float maxHealth = 100;
  float health = 100;
  int invincibleFrame = 0; // 無敵時間
  final int INVINCIBLE_TIME = 30; // 30幀無敵
  // ------------------

  
  Player(float x, float y, color c, int leftKey, int rightKey, int jumpKey,int attcackKey, char hk, int type) {
    this.gameInstance = null; // 稍後由 Game 類設置
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
    
    this.leftKey = leftKey;
    this.rightKey = rightKey;
    this.jumpKey = jumpKey;
    this.attcackKey = attcackKey;
    this.movingLeft = false;
    this.movingRight = false;
    this.jumping = false;
    this.hookKeyChar = hk;
    this.bombKeyChar = (char)attcackKey; // 轉換攻擊鍵為 char

    this.hookPos = new PVector(0,0);
    this.hookDir = new PVector(0,0);
  }

  void setMicMode() {
    this.isMicChar = true;
  }
  
  void update(ArrayList<Platform> platforms, Player otherPlayer) {
    // 更新無敫狂武時間
    if (invincibleFrame > 0) {
      invincibleFrame--;
    }
    // --- 1. 聲控大小調整 ---
    if (isMicChar) {
      float vol = analyzer.analyze();
      
      // 除錯用：你可以看下方的數值來調整門檻
      // println("Vol:" + vol); 

      // 判定是否能移動 (門檻建議設 0.1 或更高以防雜音)
      boolean canMove = vol > 0.01; 
      if (!canMove) {
        movingLeft = false;
        movingRight = false;
        // 注意：這裡不將 jumping 設為 false，是為了讓擺盪時能保留慣性
      }
      
      // ** 修改體型變化幅度 **
      // 原本: map(vol, 0.05, 0.5, 1.0, 2.5);
      // 修改: 讓變大更明顯，最大可達 3.0 倍，且反應更靈敏
      float targetScale = map(vol, 0.01, 0.15, 1.0, 2.0); 
      
      if (targetScale < 1.0) targetScale = 1.0;
      currentScale = lerp(currentScale, targetScale, 0.1); 
      
      wh.x = baseWh.x * currentScale;
      wh.y = baseWh.y * currentScale;
      // 變大時稍微增加重量感，速度不一定要變太快，保留操作手感
      speed = baseSpeed * (1.0 + (currentScale - 1.0) * 0.5);
      
      // 踩死對手邏輯 (保持不變)
      if (currentScale > 1.5 && checkCollision(otherPlayer)) {
         otherPlayer.pos.set(width/2, 50);
         otherPlayer.vel.set(0, 0);
      }
    }

   // --- 2. 蜘蛛人鎖鏈邏輯 ---
    if (isMicChar) {
      // A. 發射階段
      if (tryingToHook && !hookActive) {
        hookActive = true;
        isHooked = false;
        // 鎖鏈起始點：角色中心
        hookPos = new PVector(pos.x + wh.x/2, pos.y + wh.y/2);
        
        // 決定方向：根據移動鍵，往「斜上方」發射
        float dx = 0;
        float dy = -1; // 預設向上
        if (movingLeft) { dx = -1; dy = -1; }
        else if (movingRight) { dx = 1; dy = -1; }
        else { dx = (vel.x > 0 ? 1 : -1); dy = -1.2; } // 靜止時看慣性
        
        hookDir = new PVector(dx, dy).normalize();
      }
      
      // B. 鎖鏈運作中
      // [Player.pde] 的 update 函式內

      // B. 鎖鏈運作中
      if (hookActive) {
        if (!isHooked) {
          // --- 飛行階段 ---
          hookPos.add(PVector.mult(hookDir, hookSpeed));
          
          // 1. 檢查是否碰到平台 (原本的邏輯)
          for (Platform p : platforms) {
            if (hookPos.x >= p.pos.x && hookPos.x <= p.pos.x + p.wh.x &&
                hookPos.y >= p.pos.y && hookPos.y <= p.pos.y + p.wh.y) {
              isHooked = true;
              break;
            }
          }
          
          // 2. (新增) 檢查是否碰到視窗邊界 (牆壁、天花板、地板)
          if (!isHooked) { // 如果還沒抓到平台，才檢查牆壁
            if (hookPos.x <= 0 || hookPos.x >= width || hookPos.y <= 0 || hookPos.y >= height) {
              isHooked = true;
              
              // 修正位置：讓鎖鏈頭停在邊界上，不要飛出去
              if (hookPos.x < 0) hookPos.x = 0;
              if (hookPos.x > width) hookPos.x = width;
              if (hookPos.y < 0) hookPos.y = 0;
              if (hookPos.y > height) hookPos.y = height;
            }
          }
          
          // 如果太遠都沒抓到，就自動收回
          if (dist(pos.x, pos.y, hookPos.x, hookPos.y) > maxHookLen) {
            hookActive = false;
          }
          
        } else {
          // --- 擺盪/拉扯階段 (保持原本邏輯) ---
          PVector pullDir = PVector.sub(hookPos, new PVector(pos.x + wh.x/2, pos.y + wh.y/2));
          float distance = pullDir.mag(); // 算出距離
          pullDir.normalize();
          
          // 這邊可以微調拉力手感
          // 距離越遠拉力越大，這樣抓到天花板時會像盪鞦韆一樣
          float pullForce = 0.8; 
          vel.add(pullDir.mult(pullForce));
          
          vel.y *= 0.98; 
          vel.limit(20); // 稍微放寬最大速度限制，讓擺盪更爽快
        }
      
        // C. 鬆開按鍵 -> 斷開鎖鏈 (保留慣性)
        if (!tryingToHook) {
          hookActive = false;
          isHooked = false;
        }
      }
    }
    // -------------------------
    // 一般物理運動 (若被鎖鏈拉，vel 已經被改變了)
    if (!isHooked) { 
      // 沒用鎖鏈時才完全由按鍵控制左右速度 (否則會破壞擺盪慣性)
      // 我們加上一個緩衝，如果是擺盪後剛放開，不要馬上把 vel.x 歸零
      if (movingLeft) vel.x = -speed;
      else if (movingRight) vel.x = speed;
      else if (onGround) vel.x *= 0.8; // 地面摩擦力
      else vel.x *= 0.98; // 空氣阻力
    }

    vel.y += gravity;
    if (vel.y > 15) vel.y = 15;

    // Limit fall speed
    if (vel.y > 15) {
      vel.y = 15;
    }
    
    // Jump
    if (jumping && onGround) {
      vel.y = -jumpForce;
      onGround = false;
    }
    
    // Update position
    pos.add(vel);
    
    // Check platform collisions
    onGround = false;
    for (Platform p : platforms) {
      // Top collision (landing on platform)
      if (p.checkTopCollision(pos, wh, vel.y)) {
        pos.y = p.pos.y - wh.y;
        vel.y = 0;
        onGround = true;
      }
      // Side collisions
      else if (p.overlaps(pos, wh)) {
        // Coming from left
        if (vel.x > 0 && pos.x + wh.x > p.pos.x && pos.x < p.pos.x) {
          pos.x = p.pos.x - wh.x;
          vel.x = 0;
        }
        // Coming from right
        else if (vel.x < 0 && pos.x < p.pos.x + p.wh.x && pos.x + wh.x > p.pos.x + p.wh.x) {
          pos.x = p.pos.x + p.wh.x;
          vel.x = 0;
        }
        // Bottom collision (hitting head)
        else if (vel.y < 0 && pos.y < p.pos.y + p.wh.y && pos.y + wh.y > p.pos.y + p.wh.y) {
          pos.y = p.pos.y + p.wh.y;
          vel.y = 0;
        }
      }
    }
    
    // Keep player in bounds
    if (pos.x < 0) pos.x = 0;
    if (pos.x + wh.x > width) pos.x = width - wh.x;
    if (pos.y + wh.y > height) {
      pos.y = height - wh.y;
      vel.y = 0;
      onGround = true;
    }
    // 邊界
    if (pos.x < 0) {
      pos.x = 0; vel.x = 0;
    }
    if (pos.x + wh.x > width) {
      pos.x = width - wh.x;
      vel.x = 0;
    }
    if (pos.y + wh.y > height) {
      pos.y = height - wh.y;
      vel.y = 0;
      onGround = true;
    }
  }

  boolean checkCollision(Player other) {
    return !(pos.x + wh.x < other.pos.x || pos.x > other.pos.x + other.wh.x || 
             pos.y + wh.y < other.pos.y || pos.y > other.pos.y + other.wh.y);
  }

  
  void display() {
    // Draw body
    fill(playerColor);
    stroke(0);
    strokeWeight(2);
    rect(pos.x, pos.y, wh.x, wh.y);
    
    // Type 1: Default - Simple character with eyes
    if (type == 0) {
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.3, 5, 5);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.3, 5, 5);
    }
    
    // Type 2: Ninja - Headband and mask
    else if (type == 1) {
      // Headband
      fill(255, 0, 0);
      noStroke();
      rect(pos.x, pos.y + wh.y * 0.15, wh.x, wh.y * 0.15);
      
      // Eyes
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.35, 6, 6);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.35, 6, 6);
      
      // Mask covering lower face
      fill(0, 0, 50);
      noStroke();
      rect(pos.x + wh.x * 0.1, pos.y + wh.y * 0.5, wh.x * 0.8, wh.y * 0.25);
      
      stroke(0);
      strokeWeight(2);
    }
    
    // Type 3: Knight - Helmet and armor
    else if (type == 2) {
      // Helmet visor
      fill(150, 150, 150);
      noStroke();
      rect(pos.x, pos.y, wh.x, wh.y * 0.5);
      
      // Visor slit (eyes)
      fill(50);
      rect(pos.x + wh.x * 0.15, pos.y + wh.y * 0.25, wh.x * 0.7, wh.y * 0.1);
      
      // Armor chest plate
      fill(200, 200, 200);
      rect(pos.x + wh.x * 0.1, pos.y + wh.y * 0.55, wh.x * 0.8, wh.y * 0.35);
      
      // Chest decoration
      fill(255, 215, 0);
      ellipse(pos.x + wh.x * 0.5, pos.y + wh.y * 0.7, wh.x * 0.3, wh.y * 0.2);
      
      stroke(0);
      strokeWeight(2);
    }
    
    // Type 4: Wizard - Hat and robe details
    else if (type == 3) {
      // Wizard hat
      fill(100, 50, 200);
      noStroke();
      triangle(pos.x + wh.x * 0.5, pos.y - wh.y * 0.5, 
               pos.x, pos.y + wh.y * 0.2,
               pos.x + wh.x, pos.y + wh.y * 0.2);
      
      // Hat brim
      rect(pos.x - wh.x * 0.1, pos.y + wh.y * 0.15, wh.x * 1.2, wh.y * 0.1);
      
      // Eyes
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.35, 6, 6);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.35, 6, 6);
      
      // Beard
      fill(200, 200, 200);
      triangle(pos.x + wh.x * 0.5, pos.y + wh.y * 0.5,
               pos.x + wh.x * 0.2, pos.y + wh.y * 0.9,
               pos.x + wh.x * 0.8, pos.y + wh.y * 0.9);
      
      // Robe belt
      fill(255, 215, 0);
      rect(pos.x + wh.x * 0.1, pos.y + wh.y * 0.6, wh.x * 0.8, wh.y * 0.1);
      
      // Stars on robe
      fill(255, 255, 0);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.75, 3, 3);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.8, 3, 3);
      
      stroke(0);
      strokeWeight(2);
    }
    
    // Default fallback (same as type 1)
    else {
      fill(255);
      ellipse(pos.x + wh.x * 0.3, pos.y + wh.y * 0.3, 5, 5);
      ellipse(pos.x + wh.x * 0.7, pos.y + wh.y * 0.3, 5, 5);
    }
    
    // 繪製鎖鏈
    if (hookActive) {
      stroke(200, 50, 50); // 紅色蜘蛛絲
      strokeWeight(3);
      line(pos.x + wh.x/2, pos.y + wh.y/2, hookPos.x, hookPos.y);
      fill(0);
      noStroke();
      ellipse(hookPos.x, hookPos.y, 8, 8); // 鎖鏈頭
    }
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
    // 改用 key (char) 判斷，為了支援 'e' 和 'k'
    if (k == leftKey || kc == leftKey) movingLeft = true;
    if (k == rightKey || kc == rightKey) movingRight = true;
    if (k == jumpKey || kc == jumpKey) jumping = true;
    
    // 檢查是否按下鎖鏈鍵 (不分大小寫)
    if (isMicChar && (Character.toLowerCase((char)k) == hookKeyChar)) {
      tryingToHook = true;
    }
    
    // 檢查是否按下炸彈鍵 (只有顛倒人type=1才能使用)
    if (this.type == 1 && Character.toLowerCase((char)k) == bombKeyChar) {
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
    if (k == leftKey || kc == leftKey) movingLeft = false;
    if (k == rightKey || kc == rightKey) movingRight = false;
    if (k == jumpKey || kc == jumpKey) jumping = false;
    
    // 放開鎖鏈鍵
    if (isMicChar && (Character.toLowerCase((char)k) == hookKeyChar)) {
      tryingToHook = false;
     }
  }

  void setInvertedControls() {
    // 交換左右控制鍵
    int temp = leftKey;
    leftKey = rightKey;
    rightKey = temp;
  }
  
  void takeDamage(float damage) {
    // 判定是否在無敫狂武狀態
    if (invincibleFrame <= 0) {
      health -= damage;
      if (health < 0) health = 0;
      invincibleFrame = INVINCIBLE_TIME; // 設置無敫狂武時間
    }
  }
  
  void displayHealth() {
    // 纁電遪桨血量条
    float barWidth = 60;
    float barHeight = 8;
    float barX = pos.x - barWidth / 2 + wh.x / 2;
    float barY = pos.y - 15;
    
    // 血量時間跃動效果 (無敫狂武時间閉焉)
    if (invincibleFrame > 0 && invincibleFrame % 6 < 3) {
      // 字閙间閉焔 - 不顯示
      return;
    }
    
    // 背景衲 (靜黑赫)
    fill(50);
    noStroke();
    rect(barX, barY, barWidth, barHeight, 2);
    
    // 血量条 (開後贺绚到紫贺)
    float healthPercent = health / maxHealth;
    if (healthPercent > 0.5) {
      fill(50, 200, 50); // 綠色
    } else if (healthPercent > 0.25) {
      fill(255, 200, 0); // 黃贺
    } else {
      fill(255, 50, 50); // 紅贺
    }
    rect(barX, barY, barWidth * healthPercent, barHeight, 2);
    
    // 邊框
    stroke(200);
    strokeWeight(1);
    noFill();
    rect(barX, barY, barWidth, barHeight, 2);
  }
}