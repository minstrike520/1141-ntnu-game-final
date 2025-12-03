class Game {
  Player player1;
  Player player2;
  ArrayList<Platform> platforms;
  boolean gameOver = false;
  int winner = 0; // 0=無, 1=玩家1勝, 2=玩家2勝
  
  
  Game(int stage, int type1, int type2) {
    // Player 1: WAD controls (A=left, D=right, W=jump)
    player1 = new Player(100, 100, color(100, 150, 255), 'a', 'd', 'w', 'e', type1);
    // Player 2: Arrow keys (LEFT, RIGHT, UP)
    player2 = new Player(600, 100, color(255, 150, 100), LEFT, RIGHT, UP, 'k', type2);
    
    // 設定角色特殊能力
    if (type1 == 0) player1.setBomberMode();
    if (type2 == 0) player2.setBomberMode();
    
    // Initialize platforms
    platforms = getStageplatforms(stage);
  }
  
  void update() {
    if (!gameOver) {
      player1.update(platforms, player2);
      player2.update(platforms, player1);
      
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
    
    // Display controls info
    fill(0);
    textSize(14);
    textAlign(LEFT, CENTER);
    
    // Player 1 控制說明（根據角色類型）
    String p1Controls = "Player 1 (Blue): W=Jump, A=Left, D=Right";
    if (player1.type == 0) {
      p1Controls += ", E=Bomb (Double Jump for 3x high!)";
    } else if (player1.type == 1) {
      p1Controls += " (Ninja)";
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
      p2Controls += " (Ninja)";
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
}
