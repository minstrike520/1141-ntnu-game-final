// Stage Selector - Preview and select stages
int selectedStageIndex = 0;
int totalStages = 3; // Number of available stages
ArrayList<StageInfo> stageList;

class StageInfo {
  String name;
  
  StageInfo(String name) {
    this.name = name;
  }
}

void setupStageSelector() {
  // Initialize stage list
  stageList = new ArrayList<StageInfo>();
  stageList.add(new StageInfo("Classic Arena"));
  stageList.add(new StageInfo("Sky Towers"));
  stageList.add(new StageInfo("Minimal Stage"));
  
  selectedStageIndex = 0;
}

void drawStageSelector() {
  background(40, 40, 60); // Dark blue-gray background
  
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
  
  // Draw controls hint
  fill(200);
  textAlign(RIGHT, BOTTOM);
  textSize(14);
  text("UP/DOWN or Click to select", width - 20, height - 30);
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
  ArrayList<Platform> previewPlatforms = getStageplatforms(stageIndex);
  
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
  float totalHeight = (itemHeight + spacing) * stageList.size();
  float startY = y + (h - totalHeight) / 2; // Center vertically
  
  for (int i = 0; i < stageList.size(); i++) {
    StageInfo stage = stageList.get(i);
    float itemY = startY + i * (itemHeight + spacing);
    
    boolean isSelected = (i == selectedStageIndex);
    boolean isHovered = isMouseOverStageItem(x, itemY, w, itemHeight);
    
    // Calculate extrusion for selected item
    float extrudeAmount = isSelected ? 20 : 0;
    float itemX = x + w - 200 - extrudeAmount; // Align to right, extrude left
    float itemWidth = 200;
    
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
}

boolean isMouseOverStageItem(float x, float y, float w, float h) {
  // Check if mouse is over the rightmost area where items appear
  float itemX = x + w - 200 - 20; // Account for maximum extrusion
  float itemWidth = 220;
  return mouseX >= itemX && mouseX <= itemX + itemWidth &&
         mouseY >= y && mouseY <= y + h;
}

void stageSelectorKeyPressed() {
  if (keyCode == UP) {
    selectedStageIndex = (selectedStageIndex - 1 + stageList.size()) % stageList.size();
  } else if (keyCode == DOWN) {
    selectedStageIndex = (selectedStageIndex + 1) % stageList.size();
  } else if (key == 'c' || key == 'C') {
    // Confirm selection and start game with selected stage
    game = new Game(selectedStageIndex);
    uiStat = UI_GAME;
  }
}

void stageSelectorMousePressed() {
  // Check if clicking on any stage item
  float previewWidth = width * 0.55;
  float previewX = 50;
  float previewY = 100;
  float previewHeight = height * 0.7;
  
  float listX = previewX + previewWidth + 40;
  float listWidth = width - listX - 50;
  
  float itemHeight = 80;
  float spacing = 20;
  float totalHeight = (itemHeight + spacing) * stageList.size();
  float startY = previewY + (previewHeight - totalHeight) / 2;
  
  for (int i = 0; i < stageList.size(); i++) {
    float itemY = startY + i * (itemHeight + spacing);
    float extrudeAmount = (i == selectedStageIndex) ? 20 : 0;
    float itemX = listX + listWidth - 200 - extrudeAmount;
    float itemWidth = 200;
    
    if (mouseX >= itemX && mouseX <= itemX + itemWidth &&
        mouseY >= itemY && mouseY <= itemY + itemHeight) {
      selectedStageIndex = i;
      break;
    }
  }
}

// Helper function to get platforms for a specific stage
ArrayList<Platform> getStageplatforms(int stageIndex) {
  ArrayList<Platform> platforms = new ArrayList<Platform>();
  
  if (stageIndex == 0) {
    // Stage 1: Classic Arena
    platforms.add(new Platform(0, 500, 960, 40));
    platforms.add(new Platform(150, 400, 150, 20));
    platforms.add(new Platform(660, 400, 150, 20));
    platforms.add(new Platform(50, 300, 120, 20));
    platforms.add(new Platform(300, 250, 200, 20));
    platforms.add(new Platform(790, 300, 120, 20));
    platforms.add(new Platform(150, 150, 100, 20));
    platforms.add(new Platform(710, 150, 100, 20));
    platforms.add(new Platform(430, 80, 100, 20));
  } else if (stageIndex == 1) {
    // Stage 2: Sky Towers
    platforms.add(new Platform(0, 500, 200, 40));
    platforms.add(new Platform(760, 500, 200, 40));
    platforms.add(new Platform(100, 380, 100, 20));
    platforms.add(new Platform(760, 380, 100, 20));
    platforms.add(new Platform(200, 260, 100, 20));
    platforms.add(new Platform(660, 260, 100, 20));
    platforms.add(new Platform(300, 140, 100, 20));
    platforms.add(new Platform(560, 140, 100, 20));
    platforms.add(new Platform(430, 60, 100, 20));
  } else if (stageIndex == 2) {
    // Stage 3: Minimal Stage
    platforms.add(new Platform(0, 500, 960, 40));
    platforms.add(new Platform(200, 350, 150, 20));
    platforms.add(new Platform(610, 350, 150, 20));
    platforms.add(new Platform(380, 200, 200, 20));
  }
  
  return platforms;
}
