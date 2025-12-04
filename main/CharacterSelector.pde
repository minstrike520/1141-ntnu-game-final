PImage backgroundImg;
PImage[] characters = new PImage[4];
float flashAlpha = 255;
ArrayList<Particle> leftParticles = new ArrayList<Particle>();
ArrayList<Particle> rightParticles = new ArrayList<Particle>();

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
  backgroundImg = loadImage("character_background.png");
 
  for (int i = 0; i < 4; i++) {
    characters[i] = loadImage("character0" + (i + 1) + ".png");
  }
 
  textAlign(CENTER, CENTER);
  textSize(20);
}

void drawCharacterSelection() {
  if (backgroundImg != null) {
    image(backgroundImg, 0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  } else {
    background(0);
  }
 
  float blockWidth = DESIGN_WIDTH * 0.25;
  float blockHeight = DESIGN_HEIGHT * 0.5;
  float blockXOffset = DESIGN_WIDTH * 0.1;
  float blockY = DESIGN_HEIGHT * 0.25;
  
  fill(30, 30, 50, 150);
  rect(blockXOffset, blockY, blockWidth, blockHeight, 10);
  
  if (characters[player1Index] != null) {
    image(characters[player1Index], blockXOffset, blockY, blockWidth, blockHeight);
  } else {
    fill(150);
    text("Character " + (player1Index + 1), blockXOffset + blockWidth / 2, blockY + blockHeight / 2);
  }
  
  flashAlpha = 128 + sin(frameCount * 0.1) * 127;
  fill(255, flashAlpha);
  text("W", blockXOffset + blockWidth / 2, blockY - 20);
  text("S", blockXOffset + blockWidth / 2, blockY + blockHeight + 20);
  
  fill(30, 30, 50, 150);
  rect(DESIGN_WIDTH - blockXOffset - blockWidth, blockY, blockWidth, blockHeight, 10);
  
  if (characters[player2Index] != null) {
    image(characters[player2Index], DESIGN_WIDTH - blockXOffset - blockWidth, blockY, blockWidth, blockHeight);
  } else {
    fill(150);
    text("Character " + (player2Index + 1), DESIGN_WIDTH - blockXOffset - blockWidth / 2, blockY + blockHeight / 2);
  }
  
  fill(255, flashAlpha);
  text("↑", DESIGN_WIDTH - blockXOffset - blockWidth / 2, blockY - 20);
  text("↓", DESIGN_WIDTH - blockXOffset - blockWidth / 2, blockY + blockHeight + 20);
  
  flashAlpha = 128 + sin(frameCount * 0.1) * 127;
  fill(255, flashAlpha);
  textSize(16);
  textAlign(RIGHT, BOTTOM);
  text("Press C to Confirm", DESIGN_WIDTH - 20, DESIGN_HEIGHT - 20);
  textAlign(CENTER, CENTER);
  
  for (int i = leftParticles.size() - 1; i >= 0; i--) {
    Particle p = leftParticles.get(i);
    p.update();
    p.display();
    if (p.life <= 0) {
      leftParticles.remove(i);
    }
  }
  
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
  float blockWidth = DESIGN_WIDTH * 0.25;
  float blockHeight = DESIGN_HEIGHT * 0.5;
  float blockXOffset = DESIGN_WIDTH * 0.1;
  float blockY = DESIGN_HEIGHT * 0.25;
  
  if (key == 'w' || key == 'W') {
    player1Index = (player1Index - 1 + 4) % 4;
    addParticles(leftParticles, blockXOffset, blockY, blockWidth, blockHeight);
  } else if (key == 's' || key == 'S') {
    player1Index = (player1Index + 1) % 4;
    addParticles(leftParticles, blockXOffset, blockY, blockWidth, blockHeight);
  } else if (keyCode == UP) {
    player2Index = (player2Index - 1 + 4) % 4;
    addParticles(rightParticles, DESIGN_WIDTH - blockXOffset - blockWidth, blockY, blockWidth, blockHeight);
  } else if (keyCode == DOWN) {
    player2Index = (player2Index + 1) % 4;
    addParticles(rightParticles, DESIGN_WIDTH - blockXOffset - blockWidth, blockY, blockWidth, blockHeight);
  } else if (key == 'c' || key == 'C') {
    uiStat = UI_STAGE_SELECTION;
  }
}

void addParticles(ArrayList<Particle> particles, float x, float y, float w, float h) {
  for (int i = 0; i < 30; i++) {
    float edgeX = x + (random(1) < 0.5 ? 0 : w);
    float edgeY = y + random(h);
    if (random(1) < 0.5) {
      edgeX = x + random(w);
      edgeY = y + (random(1) < 0.5 ? 0 : h);
    }
    particles.add(new Particle(edgeX, edgeY));
  }
}

void applyCharacterSettings() {
  if (player1Index == 1) {
      game.player1.setInvertedControls();
  } else if (player1Index == 2) {
      game.player1.setMicMode();
  } else if (player1Index == 3) {
      game.player1.setFreezeMode();
  }
  
  if (player2Index == 1) { 
      game.player2.setInvertedControls();
  } else if (player2Index == 2) { 
      game.player2.setMicMode();
  } else if (player2Index == 3) { 
      game.player2.setFreezeMode();
  }
}
