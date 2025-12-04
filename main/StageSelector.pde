// Stage Selector - Preview and select stages
int selectedStageIndex = 0;
int totalStages = 3;
ArrayList<Stage> stageList;
float stageListScrollOffset = 0;
float maxScrollOffset = 0;

StageSelectorButton stageEditorButton;

class Stage {
  String name;
  ArrayList<Platform> platforms;
  
  Stage(String name, ArrayList<Platform> platforms) {
    this.name = name;
    this.platforms = platforms;
  }
}

Stage stageClassicArena() {
  String name = "Classic Arena";
  ArrayList<Platform> platforms = new ArrayList();

  platforms.add(new Platform(0, 500, 960, 40));
  platforms.add(new Platform(150, 400, 150, 20));
  platforms.add(new Platform(660, 400, 150, 20));
  platforms.add(new Platform(50, 300, 120, 20));
  platforms.add(new Platform(300, 250, 200, 20));
  platforms.add(new Platform(790, 300, 120, 20));
  platforms.add(new Platform(150, 150, 100, 20));
  platforms.add(new Platform(710, 150, 100, 20));
  platforms.add(new Platform(430, 80, 100, 20));

  return new Stage(name, platforms);
}

Stage stageSkyTowers() {
  String name = "Sky Towers";
  ArrayList<Platform> platforms = new ArrayList();

  platforms.add(new Platform(0, 500, 200, 40));
  platforms.add(new Platform(760, 500, 200, 40));
  platforms.add(new Platform(100, 380, 100, 20));
  platforms.add(new Platform(760, 380, 100, 20));
  platforms.add(new Platform(200, 260, 100, 20));
  platforms.add(new Platform(660, 260, 100, 20));
  platforms.add(new Platform(300, 140, 100, 20));
  platforms.add(new Platform(560, 140, 100, 20));
  platforms.add(new Platform(430, 60, 100, 20));

  return new Stage(name, platforms);
}

Stage stageMinimalStage() {
  String name = "Minimal Stage";
  ArrayList<Platform> platforms = new ArrayList();

  platforms.add(new Platform(0, 500, 960, 40));
  platforms.add(new Platform(200, 350, 150, 20));
  platforms.add(new Platform(610, 350, 150, 20));
  platforms.add(new Platform(380, 200, 200, 20));
  
  return new Stage(name, platforms);
}

void setupStageSelector() {
  stageList = new ArrayList<Stage>();

  stageList.add(stageClassicArena());
  stageList.add(stageSkyTowers());
  stageList.add(stageMinimalStage());

  selectedStageIndex = 0;
  stageListScrollOffset = 0;
  
  stageEditorButton = new StageSelectorButton(50, DESIGN_HEIGHT - 50, 120, 40, "STAGE EDIT !!");
}

// 在 StageSelector.pde 中也定義 Button 類別(避免衝突)
class StageSelectorButton {
  float x, y, w, h;
  String label;
  color normalColor = color(150);
  color hoverColor = color(200);
  color textColor = color(0);
  boolean isHovered = false;
  
  StageSelectorButton(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  void update(float mx, float my) {
    isHovered = isMouseOver(mx, my);
  }
  
  void display() {
    if (isHovered) {
      fill(hoverColor);
    } else {
      fill(normalColor);
    }
    stroke(0);
    strokeWeight(2);
    rect(x, y, w, h, 5);
    
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(label, x + w/2, y + h/2);
  }
  
  boolean isMouseOver(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}

void drawStageSelector() {
  background(40, 40, 60);
  
  if (leftParticles != null) {
    for (int i = leftParticles.size() - 1; i >= 0; i--) {
      Particle p = leftParticles.get(i);
      p.update();
      p.display();
      if (p.life <= 0) {
        leftParticles.remove(i);
      }
    }
  }
  
  if (rightParticles != null) {
    for (int i = rightParticles.size() - 1; i >= 0; i--) {
      Particle p = rightParticles.get(i);
      p.update();
      p.display();
      if (p.life <= 0) {
        rightParticles.remove(i);
      }
    }
  }
  
  if (leftParticles != null && random(1) < 0.3) {
    leftParticles.add(new Particle(random(0, DESIGN_WIDTH/3), random(DESIGN_HEIGHT)));
  }
  if (rightParticles != null && random(1) < 0.3) {
    rightParticles.add(new Particle(random(DESIGN_WIDTH*2/3, DESIGN_WIDTH), random(DESIGN_HEIGHT)));
  }
  
  fill(255);
  textAlign(CENTER, TOP);
  textSize(36);
  text("SELECT STAGE", DESIGN_WIDTH / 2, 30);
  
  float previewWidth = DESIGN_WIDTH * 0.55;
  float previewHeight = DESIGN_HEIGHT * 0.7;
  float previewX = 50;
  float previewY = 100;
  
  float listX = previewX + previewWidth + 40;
  float listWidth = DESIGN_WIDTH - listX - 50;
  
  stroke(200);
  strokeWeight(3);
  fill(60, 60, 80);
  rect(previewX, previewY, previewWidth, previewHeight);
  
  fill(200);
  textAlign(LEFT, TOP);
  textSize(18);
  text("PREVIEW", previewX, previewY - 25);
  
  drawStagePreview(previewX, previewY, previewWidth, previewHeight, selectedStageIndex);
  
  drawStageList(listX, previewY, listWidth, previewHeight);
  
  float flashAlpha = 128 + sin(frameCount * 0.1) * 127;
  fill(255, flashAlpha);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Press C to Confirm", DESIGN_WIDTH / 2, DESIGN_HEIGHT - 30);
  
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  stageEditorButton.update(mx, my);
  stageEditorButton.display();
  
  if (stageList.size() > 5) {
    fill(200);
    textAlign(RIGHT, BOTTOM);
    textSize(14);
    text("Use ↑↓ to scroll", DESIGN_WIDTH - 20, DESIGN_HEIGHT - 30);
  }
}

void drawStagePreview(float x, float y, float w, float h, int stageIndex) {
  pushMatrix();
  
  translate(x, y);
  
  fill(50, 50, 70);
  noStroke();
  rect(0, 0, w, h);
  
  float scaleX = w / DESIGN_WIDTH;
  float scaleY = h / DESIGN_HEIGHT;
  float previewScale = min(scaleX, scaleY) * 0.9;
  
  float offsetX = (w - DESIGN_WIDTH * previewScale) / 2;
  float offsetY = (h - DESIGN_HEIGHT * previewScale) / 2;
  
  translate(offsetX, offsetY);
  scale(previewScale);
  
  ArrayList<Platform> previewPlatforms = stageList.get(stageIndex).platforms;
  
  for (Platform p : previewPlatforms) {
    fill(120, 180, 120);
    stroke(80, 140, 80);
    strokeWeight(2 / previewScale);
    rect(p.pos.x, p.pos.y, p.wh.x, p.wh.y);
  }
  
  popMatrix();
}

void drawStageList(float x, float y, float w, float h) {
  fill(200);
  textAlign(LEFT, TOP);
  textSize(18);
  text("STAGES", x, y - 25);
  
  float itemHeight = 80;
  float spacing = 20;
  float itemWidth = 200;
  float totalHeight = (itemHeight + spacing) * stageList.size();
  
  maxScrollOffset = max(0, totalHeight - h);
  stageListScrollOffset = constrain(stageListScrollOffset, 0, maxScrollOffset);
  
  pushMatrix();
  
  fill(50, 50, 70, 100);
  stroke(100, 100, 130);
  strokeWeight(2);
  rect(x, y, w, h);
  
  clip(x, y, w, h);
  
  float startY = y - stageListScrollOffset;
  
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  
  for (int i = 0; i < stageList.size(); i++) {
    Stage stage = stageList.get(i);
    float itemY = startY + i * (itemHeight + spacing);
    
    if (itemY + itemHeight < y || itemY > y + h) {
      continue;
    }
    
    boolean isSelected = (i == selectedStageIndex);
    boolean isHovered = isMouseOverStageItem(x, itemY, w, itemHeight, y, h, mx, my);
    
    float itemX = x + (w - itemWidth) / 2;
    
    if (isSelected) {
      fill(100, 150, 255, 200);
      stroke(150, 200, 255);
    } else if (isHovered) {
      fill(80, 80, 120, 150);
      stroke(120, 120, 160);
    } else {
      fill(60, 60, 90, 150);
      stroke(100, 100, 130);
    }
    strokeWeight(2);
    rect(itemX, itemY, itemWidth, itemHeight, 5);
    
    fill(255);
    textAlign(CENTER, TOP);
    textSize(32);
    text("Stage " + (i + 1), itemX + itemWidth / 2, itemY + 10);
    
    textSize(16);
    fill(200);
    text(stage.name, itemX + itemWidth / 2, itemY + 50);
    
    if (isSelected) {
      fill(255, 255, 100);
      noStroke();
      triangle(itemX - 10, itemY + itemHeight / 2 - 5,
               itemX - 10, itemY + itemHeight / 2 + 5,
               itemX - 5, itemY + itemHeight / 2);
    }
  }
  
  noClip();
  popMatrix();
  
  if (maxScrollOffset > 0) {
    drawScrollbar(x + w - 10, y, 8, h);
  }
}

void drawScrollbar(float x, float y, float w, float h) {
  fill(40, 40, 60);
  noStroke();
  rect(x, y, w, h);
  
  float scrollbarHeight = h * (h / (h + maxScrollOffset));
  float scrollbarY = y + (stageListScrollOffset / maxScrollOffset) * (h - scrollbarHeight);
  
  fill(150, 150, 200);
  rect(x, scrollbarY, w, scrollbarHeight, 4);
}

boolean isMouseOverStageItem(float x, float itemY, float w, float itemH, float listY, float listH, float mx, float my) {
  if (itemY + itemH < listY || itemY > listY + listH) {
    return false;
  }
  
  float itemWidth = 200;
  float itemX = x + (w - itemWidth) / 2;
  
  return mx >= itemX && mx <= itemX + itemWidth &&
         my >= itemY && my <= itemY + itemH;
}

void stageSelectorKeyPressed() {
  if (keyCode == UP) {
    selectedStageIndex = (selectedStageIndex - 1 + stageList.size()) % stageList.size();
    ensureSelectedVisible();
  } else if (keyCode == DOWN) {
    selectedStageIndex = (selectedStageIndex + 1) % stageList.size();
    ensureSelectedVisible();
  } else if (key == 'c' || key == 'C') {
    game = new Game(selectedStageIndex, player1Index, player2Index);
    applyCharacterSettings();
    uiStat = UI_GAME;
  }
}

void stageSelectorMousePressed() {
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  
  if (stageEditorButton.isMouseOver(mx, my)) {
    uiStat = UI_STAGE_EDITOR;
    return;
  }
  
  float previewWidth = DESIGN_WIDTH * 0.55;
  float previewX = 50;
  float previewY = 100;
  float previewHeight = DESIGN_HEIGHT * 0.7;
  
  float listX = previewX + previewWidth + 40;
  float listWidth = DESIGN_WIDTH - listX - 50;
  
  float itemHeight = 80;
  float spacing = 20;
  float itemWidth = 200;
  float startY = previewY - stageListScrollOffset;
  
  for (int i = 0; i < stageList.size(); i++) {
    float itemY = startY + i * (itemHeight + spacing);
    
    if (itemY + itemHeight < previewY || itemY > previewY + previewHeight) {
      continue;
    }
    
    float itemX = listX + (listWidth - itemWidth) / 2;
    
    if (mx >= itemX && mx <= itemX + itemWidth &&
        my >= itemY && my <= itemY + itemHeight) {
      selectedStageIndex = i;
      break;
    }
  }
}

void ensureSelectedVisible() {
  float previewHeight = DESIGN_HEIGHT * 0.7;
  float itemHeight = 80;
  float spacing = 20;
  
  float selectedY = selectedStageIndex * (itemHeight + spacing);
  
  if (selectedY < stageListScrollOffset) {
    stageListScrollOffset = selectedY;
  }
  else if (selectedY + itemHeight > stageListScrollOffset + previewHeight) {
    stageListScrollOffset = selectedY + itemHeight - previewHeight;
  }
  
  stageListScrollOffset = constrain(stageListScrollOffset, 0, maxScrollOffset);
}
