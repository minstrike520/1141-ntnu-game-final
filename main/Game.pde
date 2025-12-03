class Game {
  Player player1;
  Player player2;
  ArrayList<Platform> platforms;
  ArrayList<ThrowBomb> throwBombs;
  int explosionFrame = 0;
  ThrowBomb explodingBomb = null;
  boolean gameOver = false;
  int winner = 0;
  
  // 天氣特效系統
  int weatherType; // 0=無, 1=下雨, 2=飄雪, 3=颳風
  ArrayList<WeatherParticle> weatherParticles;
  float windForce = 0; // 風力
  
  Game(int stageIndex, int type1, int type2) {
    player1 = new Player(100, 100, color(100, 150, 255), 'a', 'd', 'w', 'v', 'e', type1);
    player2 = new Player(600, 100, color(255, 150, 100), LEFT, RIGHT, UP, 'm', 'k', type2);
    
    player1.gameInstance = this;
    player2.gameInstance = this;
    
    if (type1 == 0) player1.setBomberMode();
    if (type2 == 0) player2.setBomberMode();
    
    platforms = stageList.get(stageIndex).platforms;
    throwBombs = new ArrayList<ThrowBomb>();
    
    // 隨機選擇天氣 (30% 機率無天氣)
    float rand = random(1);
    if (rand < 0.3) {
      weatherType = 0; // 無天氣
    } else if (rand < 0.5) {
      weatherType = 1; // 下雨
    } else if (rand < 0.7) {
      weatherType = 2; // 飄雪
    } else {
      weatherType = 3; // 颳風
    }
    
    // 初始化天氣粒子
    weatherParticles = new ArrayList<WeatherParticle>();
    initWeatherParticles();
  }
  
  void update() {
    if (!gameOver) {
      // 更新天氣特效
      updateWeather();
      
      player1.update(platforms, player2);
      player2.update(platforms, player1);
      
      // 風力影響玩家
      if (weatherType == 3) {
        player1.vel.x += windForce;
        player2.vel.x += windForce;
      }
      
      for (int i = throwBombs.size() - 1; i >= 0; i--) {
        ThrowBomb b = throwBombs.get(i);
        b.update(platforms);
        
        if (b.exploded && explodingBomb != b && explosionFrame <= 0) {
          explodingBomb = b;
          explosionFrame = 10;
        }
        
        if (!b.exploded && b.throwFrame <= 0) {
          if (b.checkPlayerCollision(player1) || b.checkPlayerCollision(player2)) {
            b.exploded = true;
            explodingBomb = b;
            explosionFrame = 10;
          }
        }
        
        if (b.exploded && explosionFrame <= 0) {
          throwBombs.remove(i);
        }
      }
      
      if (explosionFrame > 0) {
        explosionFrame--;
        
        if (explodingBomb != null) {
          explodingBomb.applyBlastToPlayer(player1);
          explodingBomb.applyBlastToPlayer(player2);
        }
      } else {
        explodingBomb = null;
      }
      
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
    
    // Display weather effects
    displayWeather();
    
    // Display game over screen
    if (gameOver) {
      displayGameOver();
    }
  }
  
  void displayGameOver() {
    fill(0, 0, 0, 200);
    noStroke();
    rect(0, 0, width, height);
    
    fill(255);
    textSize(64);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width / 2, height / 2 - 60);
    
    textSize(48);
    String winnerText = "";
    color winnerColor = color(255);
    if (winner == 1) {
      winnerText = "Player 1 Wins!";
      winnerColor = color(100, 150, 255);
    } else if (winner == 2) {
      winnerText = "Player 2 Wins!";
      winnerColor = color(255, 150, 100);
    }
    fill(winnerColor);
    text(winnerText, width / 2, height / 2 + 20);
    
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
    float direction = player.movingRight ? 1 : -1;
    if (!player.movingLeft && !player.movingRight) {
      direction = player.vel.x > 0 ? 1 : -1;
      if (player.vel.x == 0) direction = 1;
    }
    
    float bombX = player.pos.x + player.wh.x / 2;
    float bombY = player.pos.y + player.wh.y / 2;
    
    float angleRad = radians(30);
    float speed = 10;
    
    float bombVx = direction * speed * cos(angleRad) + player.vel.x * 0.3;
    float bombVy = -speed * sin(angleRad);
    
    // 風力影響炸彈
    if (weatherType == 3) {
      bombVx += windForce * 2;
    }
    
    ThrowBomb newBomb = new ThrowBomb(bombX, bombY, bombVx, bombVy);
    throwBombs.add(newBomb);
  }
  
  // 初始化天氣粒子
  void initWeatherParticles() {
    int particleCount = 0;
    if (weatherType == 1) particleCount = 150; // 雨滴數量
    else if (weatherType == 2) particleCount = 100; // 雪花數量
    else if (weatherType == 3) particleCount = 80; // 風中的葉子/灰塵
    
    for (int i = 0; i < particleCount; i++) {
      weatherParticles.add(new WeatherParticle(weatherType));
    }
  }
  
  // 更新天氣
  void updateWeather() {
    // 更新風力（颳風時風力會波動）
    if (weatherType == 3) {
      windForce = sin(frameCount * 0.02) * 0.3 + cos(frameCount * 0.05) * 0.2;
    }
    
    // 更新天氣粒子
    for (WeatherParticle p : weatherParticles) {
      p.update(weatherType, windForce);
    }
  }
  
  // 顯示天氣特效
  void displayWeather() {
    for (WeatherParticle p : weatherParticles) {
      p.display(weatherType);
    }
    
    // 顯示天氣提示
    fill(255, 255, 255, 150);
    textSize(14);
    textAlign(RIGHT, TOP);
    String weatherText = "";
    if (weatherType == 1) weatherText = "天氣: 下雨 🌧";
    else if (weatherType == 2) weatherText = "天氣: 飄雪 ❄";
    else if (weatherType == 3) weatherText = "天氣: 颳風 💨";
    if (weatherText != "") {
      text(weatherText, width - 70, 10);
    }
  }
}

// 天氣粒子類別
class WeatherParticle {
  float x, y;
  float vx, vy;
  float size;
  float alpha;
  
  WeatherParticle(int type) {
    x = random(width);
    y = random(-height, 0);
    
    if (type == 1) { // 雨
      vx = random(-1, 1);
      vy = random(8, 15);
      size = random(1, 3);
      alpha = random(100, 200);
    } else if (type == 2) { // 雪
      vx = random(-0.5, 0.5);
      vy = random(1, 3);
      size = random(3, 8);
      alpha = random(150, 255);
    } else if (type == 3) { // 風
      vx = random(3, 8);
      vy = random(-1, 1);
      size = random(2, 5);
      alpha = random(100, 180);
    }
  }
  
  void update(int type, float wind) {
    // 更新位置
    if (type == 1) { // 雨
      x += vx + wind;
      y += vy;
    } else if (type == 2) { // 雪
      x += vx + wind * 0.5 + sin(frameCount * 0.05 + x) * 0.3;
      y += vy;
    } else if (type == 3) { // 風
      x += vx + wind * 3;
      y += vy + sin(frameCount * 0.1 + x) * 0.5;
    }
    
    // 重置位置
    if (type == 1 || type == 2) {
      if (y > height) {
        y = random(-50, 0);
        x = random(width);
      }
      if (x < 0) x = width;
      if (x > width) x = 0;
    } else if (type == 3) {
      if (x > width + 50) {
        x = -50;
        y = random(height);
      }
      if (y < 0) y = height;
      if (y > height) y = 0;
    }
  }
  
  void display(int type) {
    noStroke();
    
    if (type == 1) { // 雨 - 藍色線條
      stroke(150, 200, 255, alpha);
      strokeWeight(size);
      line(x, y, x - vx * 2, y - vy * 0.5);
    } else if (type == 2) { // 雪 - 白色圓形
      fill(255, 255, 255, alpha);
      circle(x, y, size);
    } else if (type == 3) { // 風 - 灰色橢圓
      fill(200, 200, 200, alpha);
      push();
      translate(x, y);
      rotate(radians(45));
      ellipse(0, 0, size * 2, size);
      pop();
    }
  }
}
