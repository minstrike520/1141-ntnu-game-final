PImage backgroundImg; // 角色選擇背景圖片
PImage[] characters = new PImage[4]; // 角色圖片數組
float flashAlpha = 255; // 閃爍效果的透明度
ArrayList<Particle> leftParticles = new ArrayList<Particle>(); // 左側粒子效果
ArrayList<Particle> rightParticles = new ArrayList<Particle>(); // 右側粒子效果

// 粒子類別
class Particle {
  float x, y, vx, vy, life;
 
  Particle(float startX, float startY) {
    x = startX;
    y = startY;
    vx = random(-2, 2);
    vy = random(-2, 2);
    life = 255;
  }
 
  void update() {
    x += vx;
    y += vy;
    life -= 10;
  }
 
  void display() {
    noStroke();
    fill(255, life);
    ellipse(x, y, 5, 5);
  }
}

void setupCharacterSelection() {
  // 載入角色選擇背景圖片
  backgroundImg = loadImage("character_background.png");
 
  // 載入角色圖片
  for (int i = 0; i < 4; i++) {
    characters[i] = loadImage("character0" + (i + 1) + ".png");
  }
 
  textAlign(CENTER, CENTER);
  textSize(20);
}

void drawCharacterSelection() {
  if (backgroundImg != null) {
    image(backgroundImg, 0, 0, width, height);
  } else {
    background(0); // 若背景圖片未載入，使用黑色背景
  }
 
  // 計算角色區塊大小
  float blockWidth = width * 0.25; // 25% 螢幕寬度
  float blockHeight = height * 0.5; // 50% 螢幕高度
  float blockXOffset = width * 0.1; // 左右邊距 10%
  float blockY = height * 0.25; // 垂直居中
  
  // 繪製玩家1角色區塊
  fill(30, 30, 50, 150); // 半透明深色背景
  rect(blockXOffset, blockY, blockWidth, blockHeight, 10);
  
  if (characters[player1Index] != null) {
    image(characters[player1Index], blockXOffset, blockY, blockWidth, blockHeight);
  } else {
    fill(150);
    text("Character " + (player1Index + 1), blockXOffset + blockWidth / 2, blockY + blockHeight / 2);
  }
  
  // 繪製玩家1控制提示
  flashAlpha = 128 + sin(frameCount * 0.1) * 127;
  fill(255, flashAlpha);
  text("W", blockXOffset + blockWidth / 2, blockY - 20);
  text("S", blockXOffset + blockWidth / 2, blockY + blockHeight + 20);
  
  // 繪製玩家2角色區塊
  fill(30, 30, 50, 150); // 半透明深色背景
  rect(width - blockXOffset - blockWidth, blockY, blockWidth, blockHeight, 10);
  
  if (characters[player2Index] != null) {
    image(characters[player2Index], width - blockXOffset - blockWidth, blockY, blockWidth, blockHeight);
  } else {
    fill(150);
    text("Character " + (player2Index + 1), width - blockXOffset - blockWidth / 2, blockY + blockHeight / 2);
  }
  
  // 繪製玩家2控制提示
  fill(255, flashAlpha);
  text("↑", width - blockXOffset - blockWidth / 2, blockY - 20);
  text("↓", width - blockXOffset - blockWidth / 2, blockY + blockHeight + 20);
  
  // 繪製確認提示
  flashAlpha = 128 + sin(frameCount * 0.1) * 127;
  fill(255, flashAlpha);
  textSize(16);
  textAlign(RIGHT, BOTTOM);
  text("Press C to Confirm", width - 20, height - 20);
  textAlign(CENTER, CENTER);
  
  // 更新並顯示左側粒子效果
  for (int i = leftParticles.size() - 1; i >= 0; i--) {
    Particle p = leftParticles.get(i);
    p.update();
    p.display();
    if (p.life <= 0) {
      leftParticles.remove(i);
    }
  }
  
  // 更新並顯示右側粒子效果
  for (int i = rightParticles.size() - 1; i >= 0; i--) {
    Particle p = rightParticles.get(i);
    p.update();
    p.display();
    if (p.life <= 0) {
      rightParticles.remove(i);
    }
  }
}

void characterSelectorKeyPressed() {
  float blockWidth = width * 0.25;
  float blockHeight = height * 0.5;
  float blockXOffset = width * 0.1;
  float blockY = height * 0.25;
  
  if (key == 'w' || key == 'W') {
    player1Index = (player1Index - 1 + 4) % 4;
    addParticles(leftParticles, blockXOffset, blockY, blockWidth, blockHeight);
  } else if (key == 's' || key == 'S') {
    player1Index = (player1Index + 1) % 4;
    addParticles(leftParticles, blockXOffset, blockY, blockWidth, blockHeight);
  } else if (keyCode == UP) {
    player2Index = (player2Index - 1 + 4) % 4;
    addParticles(rightParticles, width - blockXOffset - blockWidth, blockY, blockWidth, blockHeight);
  } else if (keyCode == DOWN) {
    player2Index = (player2Index + 1) % 4;
    addParticles(rightParticles, width - blockXOffset - blockWidth, blockY, blockWidth, blockHeight);
  } else if (key == 'c' || key == 'C') {
    uiStat = UI_STAGE_SELECTION;
  }
}

void addParticles(ArrayList<Particle> particles, float x, float y, float w, float h) {
  for (int i = 0; i < 30; i++) {
    float edgeX = x + (random(1) < 0.5 ? 0 : w); // 隨機選擇左或右邊緣
    float edgeY = y + random(h); // 隨機選擇高度
    if (random(1) < 0.5) { // 50% 機率選擇頂部或底部
      edgeX = x + random(w);
      edgeY = y + (random(1) < 0.5 ? 0 : h);
    }
    particles.add(new Particle(edgeX, edgeY));
  }
}
void applyCharacterSettings() {
  // --- P1 設定 ---
  if (player1Index == 1) { // 顛倒人
      game.player1.setInvertedControls();
  } else if (player1Index == 2) { // 聲控巨人
      game.player1.setMicMode();
  } else if (player1Index == 3) { // 四
      game.player1.setFreezeMode();
  }
  
  // --- P2 設定 ---
  if (player2Index == 1) { 
      game.player2.setInvertedControls();
  } else if (player2Index == 2) { 
      game.player2.setMicMode();
  } else if (player2Index == 3) { 
      game.player2.setFreezeMode();
  }
}
