// Stage Selector - Preview and select stages
int selectedStageIndex = 0;
int totalStages = 3; // Number of available stages
ArrayList<Stage> stageList;
float stageListScrollOffset = 0; // 滾動偏移量
float maxScrollOffset = 0; // 最大滾動範圍

// 使用全域的粒子系統 (leftParticles, rightParticles)
// 不在這裡重複定義 Particle 類別

// Stage Editor 按鈕
Button stageEditorButton;

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
  // Initialize stage list
  stageList = new ArrayList<Stage>();

  stageList.add(stageClassicArena());
  stageList.add(stageSkyTowers());
  stageList.add(stageMinimalStage());

  selectedStageIndex = 0;
  stageListScrollOffset = 0; // 重置滾動
  
  // 初始化 Stage Editor 按鈕
  stageEditorButton = new Button(50, height - 50, 120, 40, "STAGE EDIT !!");
}

void drawStageSelector() {
  background(40, 40, 60); // Dark blue-gray background
  
  // 使用全域的粒子系統繪製粒子效果
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
  
  // 隨機生成新粒子
  if (leftParticles != null && random(1) < 0.3) {
    leftParticles.add(new Particle(random(0, width/3), random(height)));
  }
  if (rightParticles != null && random(1) < 0.3) {
    rightParticles.add(new Particle(random(width*2/3, width), random(height)));
  }
  
  // Draw title
  fill(255);
  textAlign(CENTER, TOP);
  textSize(36);
  text("SELECT STAGE", width / 2, 30);
  
  // Define layout dimensions
  float previewWidth = width * 0.55; // 55% for preview
  float previewHeight = height * 0.7;
  float previewX = 50;
  float previewY = 100;
  
  float listX = previewX + previewWidth + 40;
  float listWidth = width - listX - 50;
  
  // Draw preview window border
  stroke(200);
  strokeWeight(3);
  fill(60, 60, 80);
  rect(previewX, previewY, previewWidth, previewHeight);
  
  // Draw preview label
  fill(200);
  textAlign(LEFT, TOP);
  textSize(18);
  text("PREVIEW", previewX, previewY - 25);
  
  // Draw stage preview
  drawStagePreview(previewX, previewY, previewWidth, previewHeight, selectedStageIndex);
  
  // Draw selection list
  drawStageList(listX, previewY, listWidth, previewHeight);
  
  // Draw confirmation hint
  float flashAlpha = 128 + sin(frameCount * 0.1) * 127;
  fill(255, flashAlpha);
  textAlign(CENTER, BOTTOM);
  textSize(18);
  text("Press C to Confirm", width / 2, height - 30);
  
  // Draw Stage Editor button
  stageEditorButton.update();
  stageEditorButton.display();
  
  // Draw controls hint
  if (stageList.size() > 5) {
    fill(200);
    textAlign(RIGHT, BOTTOM);
    textSize(14);
    text("Use ↑↓ to scroll", width - 20, height - 30);
  }
}

void drawStagePreview(float x, float y, float w, float h, int stageIndex) {
  pushMatrix();
  
  // Create a scaled down preview
  translate(x, y);
  
  // Clip to preview window
  fill(50, 50, 70);
  noStroke();
  rect(0, 0, w, h);
  
  // Calculate scale to fit stage in preview
  float scaleX = w / width;
  float scaleY = h / height;
  float previewScale = min(scaleX, scaleY) * 0.9; // 90% to add padding
  
  // Center the preview
  float offsetX = (w - width * previewScale) / 2;
  float offsetY = (h - height * previewScale) / 2;
  
  translate(offsetX, offsetY);
  scale(previewScale);
  
  // Draw platforms for the selected stage
  ArrayList<Platform> previewPlatforms = stageList.get(stageIndex).platforms;
  
  for (Platform p : previewPlatforms) {
    fill(120, 180, 120);
    stroke(80, 140, 80);
    strokeWeight(2 / previewScale); // Adjust stroke weight for scale
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
  
  // 計算最大滾動範圍
  maxScrollOffset = max(0, totalHeight - h);
  stageListScrollOffset = constrain(stageListScrollOffset, 0, maxScrollOffset);
  
  // 使用 pushMatrix 來實現裁切效果
  pushMatrix();
  
  // 繪製背景和邊框
  fill(50, 50, 70, 100);
  stroke(100, 100, 130);
  strokeWeight(2);
  rect(x, y, w, h);
  
  // 設置裁切區域
  clip(x, y, w, h);
  
  float startY = y - stageListScrollOffset; // 套用滾動偏移
  
  for (int i = 0; i < stageList.size(); i++) {
    Stage stage = stageList.get(i);
    float itemY = startY + i * (itemHeight + spacing);
    
    // 只繪製可見的項目（優化性能）
    if (itemY + itemHeight < y || itemY > y + h) {
      continue;
    }
    
    boolean isSelected = (i == selectedStageIndex);
    boolean isHovered = isMouseOverStageItem(x, itemY, w, itemHeight, y, h);
    
    // 計算置中位置
    float itemX = x + (w - itemWidth) / 2; // 置中於框框
    
    // Draw item background
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
    
    // Draw stage number
    fill(255);
    textAlign(CENTER, TOP);
    textSize(32);
    text("Stage " + (i + 1), itemX + itemWidth / 2, itemY + 10);
    
    // Draw stage name
    textSize(16);
    fill(200);
    text(stage.name, itemX + itemWidth / 2, itemY + 50);
    
    // Draw selection indicator
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
  
  // 繪製滾動條（如果需要）
  if (maxScrollOffset > 0) {
    drawScrollbar(x + w - 10, y, 8, h);
  }
}

void drawScrollbar(float x, float y, float w, float h) {
  // 滾動條背景
  fill(40, 40, 60);
  noStroke();
  rect(x, y, w, h);
  
  // 滾動條滑塊
  float scrollbarHeight = h * (h / (h + maxScrollOffset));
  float scrollbarY = y + (stageListScrollOffset / maxScrollOffset) * (h - scrollbarHeight);
  
  fill(150, 150, 200);
  rect(x, scrollbarY, w, scrollbarHeight, 4);
}

boolean isMouseOverStageItem(float x, float itemY, float w, float itemH, float listY, float listH) {
  // 檢查是否在列表可見區域內
  if (itemY + itemH < listY || itemY > listY + listH) {
    return false;
  }
  
  // 置中後的項目位置
  float itemWidth = 200;
  float itemX = x + (w - itemWidth) / 2;
  
  return mouseX >= itemX && mouseX <= itemX + itemWidth &&
         mouseY >= itemY && mouseY <= itemY + itemH;
}

void stageSelectorKeyPressed() {
  if (keyCode == UP) {
    selectedStageIndex = (selectedStageIndex - 1 + stageList.size()) % stageList.size();
    ensureSelectedVisible();
  } else if (keyCode == DOWN) {
    selectedStageIndex = (selectedStageIndex + 1) % stageList.size();
    ensureSelectedVisible();
  } else if (key == 'c' || key == 'C') {
    // Confirm selection and start game with selected stage
    game = new Game(selectedStageIndex, player1Index, player2Index);
    applyCharacterSettings();
    uiStat = UI_GAME;
  }
}

void stageSelectorMousePressed() {
  // Check if Stage Editor button is clicked
  if (stageEditorButton.isMouseOver()) {
    uiStat = UI_STAGE_EDITOR;
    return;
  }
  
  // Check if clicking on any stage item
  float previewWidth = width * 0.55;
  float previewX = 50;
  float previewY = 100;
  float previewHeight = height * 0.7;
  
  float listX = previewX + previewWidth + 40;
  float listWidth = width - listX - 50;
  
  float itemHeight = 80;
  float spacing = 20;
  float itemWidth = 200;
  float startY = previewY - stageListScrollOffset;
  
  for (int i = 0; i < stageList.size(); i++) {
    float itemY = startY + i * (itemHeight + spacing);
    
    // 檢查是否在可見區域
    if (itemY + itemHeight < previewY || itemY > previewY + previewHeight) {
      continue;
    }
    
    // 置中後的項目位置
    float itemX = listX + (listWidth - itemWidth) / 2;
    
    if (mouseX >= itemX && mouseX <= itemX + itemWidth &&
        mouseY >= itemY && mouseY <= itemY + itemHeight) {
      selectedStageIndex = i;
      break;
    }
  }
}

// 確保選中的項目可見
void ensureSelectedVisible() {
  float previewHeight = height * 0.7;
  float itemHeight = 80;
  float spacing = 20;
  
  float selectedY = selectedStageIndex * (itemHeight + spacing);
  
  // 如果選中項目在視窗上方
  if (selectedY < stageListScrollOffset) {
    stageListScrollOffset = selectedY;
  }
  // 如果選中項目在視窗下方
  else if (selectedY + itemHeight > stageListScrollOffset + previewHeight) {
    stageListScrollOffset = selectedY + itemHeight - previewHeight;
  }
  
  stageListScrollOffset = constrain(stageListScrollOffset, 0, maxScrollOffset);
}
