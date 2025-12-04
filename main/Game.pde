class Game {
  Player player1;
  Player player2;
  ArrayList<Platform> platforms;
  ArrayList<ThrowBomb> throwBombs;
  int explosionFrame = 0;
  ThrowBomb explodingBomb = null;
  boolean gameOver = false;
  int winner = 0;
  
  int weatherType;
  ArrayList<WeatherParticle> weatherParticles;
  float windForce = 0;
  
  Game(int stageIndex, int type1, int type2) {
    player1 = new Player(100, 100, color(100, 150, 255), 'a', 'd', 'w', 'v', 'e', type1);
    player2 = new Player(600, 100, color(255, 150, 100), LEFT, RIGHT, UP, 'm', 'k', type2);
    
    player1.gameInstance = this;
    player2.gameInstance = this;
    
    if (type1 == 0) player1.setBomberMode();
    if (type2 == 0) player2.setBomberMode();
    
    platforms = stageList.get(stageIndex).platforms;
    throwBombs = new ArrayList<ThrowBomb>();
    
    float rand = random(1);
    if (rand < 0.3) {
      weatherType = 0;
    } else if (rand < 0.5) {
      weatherType = 1;
    } else if (rand < 0.7) {
      weatherType = 2;
    } else {
      weatherType = 3;
    }
    
    weatherParticles = new ArrayList<WeatherParticle>();
    initWeatherParticles();
  }
  
  void update() {
    if (!gameOver) {
      updateWeather();
      
      player1.update(platforms, player2);
      player2.update(platforms, player1);
      
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
    for (Platform p : platforms) {
      p.display();
    }
    
    player1.display();
    player2.display();
    
    for (ThrowBomb b : throwBombs) {
      b.display();
      b.displayExplosion();
    }
    
    displayWeather();
    
    if (gameOver) {
      displayGameOver();
    }
  }
  
  void displayGameOver() {
    fill(0, 0, 0, 200);
    noStroke();
    rect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
    
    fill(255);
    textSize(64);
    textAlign(CENTER, CENTER);
    text("GAME OVER", DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2 - 60);
    
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
    text(winnerText, DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2 + 20);
    
    textSize(24);
    float flashAlpha = 128 + sin(frameCount * 0.1) * 127;
    fill(255, 255, 100, flashAlpha);
    text("Press R to Restart", DESIGN_WIDTH / 2, DESIGN_HEIGHT / 2 + 100);
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
    
    if (weatherType == 3) {
      bombVx += windForce * 2;
    }
    
    ThrowBomb newBomb = new ThrowBomb(bombX, bombY, bombVx, bombVy);
    throwBombs.add(newBomb);
  }
  
  void initWeatherParticles() {
    int particleCount = 0;
    if (weatherType == 1) particleCount = 150;
    else if (weatherType == 2) particleCount = 100;
    else if (weatherType == 3) particleCount = 80;
    
    for (int i = 0; i < particleCount; i++) {
      weatherParticles.add(new WeatherParticle(weatherType));
    }
  }
  
  void updateWeather() {
    if (weatherType == 3) {
      windForce = sin(frameCount * 0.02) * 0.3 + cos(frameCount * 0.05) * 0.2;
    }
    
    for (WeatherParticle p : weatherParticles) {
      p.update(weatherType, windForce);
    }
  }
  
  void displayWeather() {
    for (WeatherParticle p : weatherParticles) {
      p.display(weatherType);
    }
    
    fill(255, 255, 255, 150);
    textSize(14);
    textAlign(RIGHT, TOP);
    String weatherText = "";
    if (weatherType == 1) weatherText = "天氣: 下雨 🌧";
    else if (weatherType == 2) weatherText = "天氣: 飄雪 ❄";
    else if (weatherType == 3) weatherText = "天氣: 颳風 💨";
    if (weatherText != "") {
      text(weatherText, DESIGN_WIDTH - 70, 10);
    }
  }
}

class WeatherParticle {
  float x, y;
  float vx, vy;
  float size;
  float alpha;
  
  WeatherParticle(int type) {
    x = random(DESIGN_WIDTH);
    y = random(-DESIGN_HEIGHT, 0);
    
    if (type == 1) {
      vx = random(-1, 1);
      vy = random(8, 15);
      size = random(1, 3);
      alpha = random(100, 200);
    } else if (type == 2) {
      vx = random(-0.5, 0.5);
      vy = random(1, 3);
      size = random(3, 8);
      alpha = random(150, 255);
    } else if (type == 3) {
      vx = random(3, 8);
      vy = random(-1, 1);
      size = random(2, 5);
      alpha = random(100, 180);
    }
  }
  
  void update(int type, float wind) {
    if (type == 1) {
      x += vx + wind;
      y += vy;
    } else if (type == 2) {
      x += vx + wind * 0.5 + sin(frameCount * 0.05 + x) * 0.3;
      y += vy;
    } else if (type == 3) {
      x += vx + wind * 3;
      y += vy + sin(frameCount * 0.1 + x) * 0.5;
    }
    
    if (type == 1 || type == 2) {
      if (y > DESIGN_HEIGHT) {
        y = random(-50, 0);
        x = random(DESIGN_WIDTH);
      }
      if (x < 0) x = DESIGN_WIDTH;
      if (x > DESIGN_WIDTH) x = 0;
    } else if (type == 3) {
      if (x > DESIGN_WIDTH + 50) {
        x = -50;
        y = random(DESIGN_HEIGHT);
      }
      if (y < 0) y = DESIGN_HEIGHT;
      if (y > DESIGN_HEIGHT) y = 0;
    }
  }
  
  void display(int type) {
    noStroke();
    
    if (type == 1) {
      stroke(150, 200, 255, alpha);
      strokeWeight(size);
      line(x, y, x - vx * 2, y - vy * 0.5);
    } else if (type == 2) {
      fill(255, 255, 255, alpha);
      circle(x, y, size);
    } else if (type == 3) {
      fill(200, 200, 200, alpha);
      push();
      translate(x, y);
      rotate(radians(45));
      ellipse(0, 0, size * 2, size);
      pop();
    }
  }
}
