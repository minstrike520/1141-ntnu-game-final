class Game {
  Player player1;
  Player player2;
  ArrayList<Platform> platforms;
  ArrayList<ThrowBomb> throwBombs;  // 拋擲炸彈列表
  int explosionFrame = 0;
  ThrowBomb explodingBomb = null;
  boolean gameOver = false;
  int winner = 0; // 0=無, 1=玩家1勝, 2=玩家2勝
  
  
  Game(int stage, int type1, int type2) {
    // Player 1: WAD controls (A=left, D=right, W=jump, V=throw bomb, E=place bomb)
    player1 = new Player(100, 100, color(100, 150, 255), 'a', 'd', 'w', 'v', 'e', type1);
    // Player 2: Arrow keys (LEFT, RIGHT, UP, M=throw bomb, K=place bomb)
    player2 = new Player(600, 100, color(255, 150, 100), LEFT, RIGHT, UP, 'm', 'k', type2);
    
    // 設置玩家的遊戲參考
    player1.gameInstance = this;
    player2.gameInstance = this;
    
    // 設定角色特殊能力
    if (type1 == 0) player1.setBomberMode();
    if (type2 == 0) player2.setBomberMode();
    
    // Initialize platforms
    platforms = getStageplatforms(stage);
    throwBombs = new ArrayList<ThrowBomb>();
  }
  
  void update() {
    if (!gameOver) {
      player1.update(platforms, player2);
      player2.update(platforms, player1);
      
      // 更新拋擲炸彈
      for (int i = throwBombs.size() - 1; i >= 0; i--) {
        ThrowBomb b = throwBombs.get(i);
        b.update(platforms);
        
        // 如果炸彈爆炸了但還沒設置爆炸幀數，設置它
        if (b.exploded && explodingBomb != b && explosionFrame <= 0) {
          explodingBomb = b;
          explosionFrame = 10; // 爆炸持續10幀
        }
        
        // 檢查與玩家的碰撞 (只在拋出後足夠時間後檢查)
        if (!b.exploded && b.throwFrame <= 0) {
          if (b.checkPlayerCollision(player1) || b.checkPlayerCollision(player2)) {
            b.exploded = true;
            explodingBomb = b;
            explosionFrame = 10;
          }
        }
        
        // 移除已爆炸且超時的炸彈
        if (b.exploded && explosionFrame <= 0) {
          throwBombs.remove(i);
        }
      }
      
      // 更新爆炸幀數
      if (explosionFrame > 0) {
        explosionFrame--;
        
        // 爆炸時施加傷害
        if (explodingBomb != null) {
          explodingBomb.applyBlastToPlayer(player1);
          explodingBomb.applyBlastToPlayer(player2);
        }
      } else {
        explodingBomb = null;
      }
      
      // 檢查是否有玩家死亡
      if (player1.health <= 0) {
        gameOver = true;
        winner = 2;
      } else if (player2.health <= 0) {
        gameOver = true;
        winner = 1;
      }
    }
  }
  
  void display() {
    // Display platforms
    for (Platform p : platforms) {
      p.display();
    }
    
    // Display players
    player1.display();
    player2.display();
    
    // Display throw bombs
    for (ThrowBomb b : throwBombs) {
      b.display();
      b.displayExplosion();
    }
    
    // Display controls info
    fill(0);
    textSize(14);
    textAlign(LEFT, CENTER);
    
    // Player 1 控制說明（根據角色類型）
    String p1Controls = "Player 1 (Blue): W=Jump, A=Left, D=Right";
    if (player1.type == 0) {
      p1Controls += ", E=Bomb (Double Jump for 3x high!)";
    } else if (player1.type == 1) {
      p1Controls += ", V=Throw Bomb (Ninja)";
    } else if (player1.type == 2) {
      p1Controls += " (Knight)";
    } else if (player1.type == 3) {
      p1Controls += " (Wizard)";
    }
    text(p1Controls, 10, 20);
    
    // Player 2 控制說明（根據角色類型）
    String p2Controls = "Player 2 (Orange): UP=Jump, LEFT/RIGHT=Move";
    if (player2.type == 0) {
      p2Controls += ", K=Bomb (Double Jump for 3x high!)";
    } else if (player2.type == 1) {
      p2Controls += ", M=Throw Bomb (Ninja)";
    } else if (player2.type == 2) {
      p2Controls += " (Knight)";
    } else if (player2.type == 3) {
      p2Controls += " (Wizard)";
    }
    text(p2Controls, 10, 40);
    
    // Display health info
    textSize(16);
    textAlign(LEFT, TOP);
    fill(100, 150, 255);
    text("Player 1 HP: " + (int)player1.health + "/" + (int)player1.maxHealth, 10, 80);
    fill(255, 150, 100);
    text("Player 2 HP: " + (int)player2.health + "/" + (int)player2.maxHealth, 10, 100);
    
    // Display game over screen
    if (gameOver) {
      displayGameOver();
    }
  }
  
  void displayGameOver() {
    // 半透明黑色背景
    fill(0, 0, 0, 200);
    noStroke();
    rect(0, 0, width, height);
    
    // 遊戲結束文字
    fill(255);
    textSize(64);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width / 2, height / 2 - 60);
    
    // 勝者文字
    textSize(48);
    String winnerText = "";
    color winnerColor = color(255);
    if (winner == 1) {
      winnerText = "Player 1 Wins!";
      winnerColor = color(100, 150, 255); // 藍色
    } else if (winner == 2) {
      winnerText = "Player 2 Wins!";
      winnerColor = color(255, 150, 100); // 橙色
    }
    fill(winnerColor);
    text(winnerText, width / 2, height / 2 + 20);
    
    // 按鈕提示
    textSize(24);
    float flashAlpha = 128 + sin(frameCount * 0.1) * 127;
    fill(255, 255, 100, flashAlpha);
    text("Press R to Restart", width / 2, height / 2 + 100);
  }
  
  void handleKeyPress(char k, int kc) {
    player1.handleKeyPress(k, kc);
    player2.handleKeyPress(k, kc);
  }
  
  void handleKeyRelease(char k, int kc) {
    player1.handleKeyRelease(k, kc);
    player2.handleKeyRelease(k, kc);
  }
  
  void throwBomb(Player player) {
    // 計算拋出方向 (朝面對方向)
    float direction = player.movingRight ? 1 : -1;
    if (!player.movingLeft && !player.movingRight) {
      direction = player.vel.x > 0 ? 1 : -1; // 沒移動時用上一個慣性方向
      if (player.vel.x == 0) direction = 1; // 完全靜止時預設向右
    }
    
    // 炸彈起始位置 (玩家中心)
    float bombX = player.pos.x + player.wh.x / 2;
    float bombY = player.pos.y + player.wh.y / 2;
    
    // 炸彈速度 - 30度角拋出
    float angleRad = radians(30); // 30度轉換為弧度
    float speed = 10; // 拋出速度
    
    float bombVx = direction * speed * cos(angleRad) + player.vel.x * 0.3;
    float bombVy = -speed * sin(angleRad); // 負值表示向上
    
    ThrowBomb newBomb = new ThrowBomb(bombX, bombY, bombVx, bombVy);
    throwBombs.add(newBomb);
  }
}
