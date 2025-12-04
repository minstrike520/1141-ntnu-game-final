import gifAnimation.*;
import processing.sound.*;

PFont font;

int player1Index = 0;
int player2Index = 0;

final int UI_NONE = 0;
final int UI_TITLE_SCREEN = 1;
final int UI_CHARACTER_SELECTION = 2;
final int UI_STAGE_SELECTION = 3;
final int UI_GAME = 4;
final int UI_STAGE_EDITOR = 5;
int uiStat = 1;
Game game;

// 聲音相關變數
AudioIn input;
Amplitude analyzer;
SoundFile bgMusic;

// 設定選單相關變數
PImage settingIcon;
boolean settingMenuOpen = false;
float settingButtonX, settingButtonY, settingButtonSize;
float volumeSliderValue = 0.5;

String[] menuItems = {"音量大小", "角色相關", "退出遊戲"};
int selectedMenuItem = -1;
boolean showCharacterInfo = false;

// ==================== 縮放系統 ====================
final float DESIGN_WIDTH = 960;   // 設計解析度寬度
final float DESIGN_HEIGHT = 540;  // 設計解析度高度
float scaleX = 1.0;  // X軸縮放比例
float scaleY = 1.0;  // Y軸縮放比例
float offsetX = 0;   // X軸偏移(黑邊)
float offsetY = 0;   // Y軸偏移(黑邊)

void setup() {
  size(960, 540);
  surface.setResizable(true); // 允許視窗大小調整
  
  font = createFont("NotoSansCJKtc-Regular.ttc", 32);
  textFont(font);
  setupTitleScreen();
  setupCharacterSelection();
  setupStageSelector();
  setupStageEditor();
  
  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  try {
    bgMusic = new SoundFile(this, "game.mp3");
    bgMusic.loop();
    bgMusic.amp(volumeSliderValue);
  } catch (Exception e) {
    println("背景音樂載入失敗: " + e.getMessage());
  }
  
  settingIcon = loadImage("setting.png");
  
  settingButtonSize = 40;
  settingButtonX = DESIGN_WIDTH - settingButtonSize - 10;
  settingButtonY = 10;
  
  calculateScale(); // 初始化縮放
}

// 計算縮放比例和偏移
void calculateScale() {
  float windowRatio = (float)width / height;
  float designRatio = DESIGN_WIDTH / DESIGN_HEIGHT;
  
  if (windowRatio > designRatio) {
    // 視窗較寬,以高度為基準
    scaleY = (float)height / DESIGN_HEIGHT;
    scaleX = scaleY;
    offsetX = (width - DESIGN_WIDTH * scaleX) / 2;
    offsetY = 0;
  } else {
    // 視窗較高,以寬度為基準
    scaleX = (float)width / DESIGN_WIDTH;
    scaleY = scaleX;
    offsetX = 0;
    offsetY = (height - DESIGN_HEIGHT * scaleY) / 2;
  }
}

// 將螢幕座標轉換為設計座標
float screenToDesignX(float x) {
  return (x - offsetX) / scaleX;
}

float screenToDesignY(float y) {
  return (y - offsetY) / scaleY;
}

// 開始使用設計座標系統
void pushDesignMatrix() {
  pushMatrix();
  translate(offsetX, offsetY);
  scale(scaleX, scaleY);
}

// 結束使用設計座標系統
void popDesignMatrix() {
  popMatrix();
}

void draw() {
  calculateScale(); // 每幀更新縮放(支援即時調整視窗大小)
  
  // 繪製黑邊
  background(0);
  
  // 使用設計座標系統繪製
  pushDesignMatrix();
  
  if (uiStat == UI_TITLE_SCREEN) {
    drawTitleScreen();
  } else if (uiStat == UI_CHARACTER_SELECTION) {
    drawCharacterSelection();
  } else if (uiStat == UI_STAGE_SELECTION) {
    drawStageSelector();
  } else if (uiStat == UI_GAME) {
    background(50);
    game.update();
    game.display();
    
    drawSettingButton();
    
    if (settingMenuOpen) {
      drawSettingMenu();
    }
    
    if (showCharacterInfo) {
      drawCharacterInfo();
    }
  } else if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.update();
    stageEditor.display();
  }
  
  popDesignMatrix();
}

void drawSettingButton() {
  imageMode(CORNER);
  image(settingIcon, settingButtonX, settingButtonY, settingButtonSize, settingButtonSize);
  
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  
  if (mx >= settingButtonX && mx <= settingButtonX + settingButtonSize &&
      my >= settingButtonY && my <= settingButtonY + settingButtonSize) {
    noFill();
    stroke(255, 200, 0);
    strokeWeight(3);
    rect(settingButtonX, settingButtonY, settingButtonSize, settingButtonSize);
  }
}

void drawSettingMenu() {
  fill(0, 0, 0, 150);
  noStroke();
  float menuWidth = 200;
  float menuHeight = 200;
  float menuX = settingButtonX - menuWidth + settingButtonSize;
  float menuY = settingButtonY + settingButtonSize + 5;
  rect(menuX, menuY, menuWidth, menuHeight, 10);
  
  fill(255);
  textSize(18);
  textAlign(CENTER, CENTER);
  float itemHeight = 50;
  float itemY = menuY + 15;
  
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  
  for (int i = 0; i < menuItems.length; i++) {
    if (mx >= menuX && mx <= menuX + menuWidth &&
        my >= itemY && my <= itemY + itemHeight) {
      fill(255, 255, 100);
      selectedMenuItem = i;
    } else {
      fill(255);
    }
    
    if (i == 0) {
      text(menuItems[i], menuX + menuWidth/2, itemY + 15);
    } else {
      text(menuItems[i], menuX + menuWidth/2, itemY + itemHeight/2);
    }
    
    if (i == 0) {
      drawVolumeSlider(menuX, itemY + 35, menuWidth);
    }
    
    itemY += itemHeight;
  }
}

void drawVolumeSlider(float x, float y, float w) {
  float sliderWidth = w - 40;
  float sliderX = x + 20;
  float sliderY = y;
  
  stroke(200);
  strokeWeight(4);
  line(sliderX, sliderY, sliderX + sliderWidth, sliderY);
  
  float knobX = sliderX + volumeSliderValue * sliderWidth;
  fill(255, 200, 0);
  noStroke();
  circle(knobX, sliderY, 15);
  
  fill(200);
  textSize(12);
  textAlign(CENTER, CENTER);
  text((int)(volumeSliderValue * 100) + "%", sliderX + sliderWidth/2, sliderY + 15);
}

void drawCharacterInfo() {
  fill(0, 0, 0, 200);
  noStroke();
  rect(0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  
  fill(255, 200, 100);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("角色相關資訊", DESIGN_WIDTH/2, 80);
  
  fill(100, 150, 255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Player 1 (藍色)", 100, 150);
  
  fill(255);
  textSize(16);
  String p1Controls = "控制:W=跳躍, A=左移, D=右移\n";
  if (game.player1.type == 0) {
    p1Controls += "角色:炸彈客\n技能:E=放置炸彈 (雙跳可跳3倍高!)";
  } else if (game.player1.type == 1) {
    p1Controls += "角色:忍者\n技能:E=拋擲炸彈";
  } else if (game.player1.type == 2) {
    p1Controls += "角色:騎士\n技能:E=鉤爪繩索";
  } else if (game.player1.type == 3) {
    p1Controls += "角色:巫師";
  }
  text(p1Controls, 100, 180);
  
  fill(255, 150, 100);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Player 2 (橙色)", DESIGN_WIDTH/2 + 50, 150);
  
  fill(255);
  textSize(16);
  String p2Controls = "控制:UP=跳躍, LEFT/RIGHT=移動\n";
  if (game.player2.type == 0) {
    p2Controls += "角色:炸彈客\n技能:K=放置炸彈 (雙跳可跳3倍高!)";
  } else if (game.player2.type == 1) {
    p2Controls += "角色:忍者\n技能:K=拋擲炸彈";
  } else if (game.player2.type == 2) {
    p2Controls += "角色:騎士\n技能:K=鉤爪繩索";
  } else if (game.player2.type == 3) {
    p2Controls += "角色:巫師";
  }
  text(p2Controls, DESIGN_WIDTH/2 + 50, 180);
  
  fill(255, 255, 100);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("按任意鍵關閉", DESIGN_WIDTH/2, DESIGN_HEIGHT - 50);
}

void mousePressed() {
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  
  if (uiStat == UI_TITLE_SCREEN) {
    uiStat = UI_CHARACTER_SELECTION;
    if (startBackgroundGif != null) {
      startBackgroundGif.pause();
    }
    handleTitleScreenClick();
  } else if (uiStat == UI_STAGE_SELECTION) {
    stageSelectorMousePressed();
  } else if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.mousePressed();
  } else if (uiStat == UI_GAME) {
    if (mx >= settingButtonX && mx <= settingButtonX + settingButtonSize &&
        my >= settingButtonY && my <= settingButtonY + settingButtonSize) {
      settingMenuOpen = !settingMenuOpen;
      return;
    }
    
    if (settingMenuOpen) {
      float menuWidth = 200;
      float menuHeight = 200;
      float menuX = settingButtonX - menuWidth + settingButtonSize;
      float menuY = settingButtonY + settingButtonSize + 5;
      
      if (mx >= menuX && mx <= menuX + menuWidth &&
          my >= menuY && my <= menuY + menuHeight) {
        
        float itemHeight = 50;
        float itemY = menuY + 15;
        
        for (int i = 0; i < menuItems.length; i++) {
          if (my >= itemY && my <= itemY + itemHeight) {
            if (i == 0) {
              // 音量大小
            } else if (i == 1) {
              showCharacterInfo = true;
              settingMenuOpen = false;
            } else if (i == 2) {
              uiStat = UI_TITLE_SCREEN;
              if (startBackgroundGif != null) startBackgroundGif.loop();
              game = null;
              settingMenuOpen = false;
            }
            return;
          }
          itemY += itemHeight;
        }
      } else {
        settingMenuOpen = false;
      }
    }
  }
}

void mouseDragged() {
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  
  if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.mouseDragged();
  } else if (uiStat == UI_GAME && settingMenuOpen) {
    float menuWidth = 200;
    float menuX = settingButtonX - menuWidth + settingButtonSize;
    float menuY = settingButtonY + settingButtonSize + 5;
    float sliderWidth = menuWidth - 40;
    float sliderX = menuX + 20;
    float sliderY = menuY + 15 + 35;
    
    if (abs(my - sliderY) < 20) {
      volumeSliderValue = constrain((mx - sliderX) / sliderWidth, 0, 1);
      if (bgMusic != null) {
        bgMusic.amp(volumeSliderValue);
      }
    }
  }
}

void mouseReleased() {
  if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.mouseReleased();
  }
}

void keyPressed() {
  if (showCharacterInfo) {
    showCharacterInfo = false;
    return;
  }
  
  if (key == ESC) {
    key = 0;
    if (uiStat == UI_GAME) {
      uiStat = UI_TITLE_SCREEN;
      if (startBackgroundGif != null) startBackgroundGif.loop();
      game = null;
      settingMenuOpen = false;
      return;
    } else if (uiStat == UI_STAGE_SELECTION) {
      uiStat = UI_CHARACTER_SELECTION;
      return;
    } else if (uiStat == UI_CHARACTER_SELECTION) {
      uiStat = UI_TITLE_SCREEN;
      if (startBackgroundGif != null) startBackgroundGif.loop();
      return;
    } else if (uiStat == UI_STAGE_EDITOR) {
      uiStat = UI_TITLE_SCREEN;
      if (startBackgroundGif != null) startBackgroundGif.loop();
      return;
    }
  }
  
  if (uiStat == UI_CHARACTER_SELECTION) {
    characterSelectorKeyPressed();
  } else if (uiStat == UI_STAGE_SELECTION) {
    stageSelectorKeyPressed();
  } else if (uiStat == UI_GAME) {
    if (key == ESC) {
      key = 0;
      uiStat = UI_TITLE_SCREEN;
      if (startBackgroundGif != null) {
        startBackgroundGif.loop();
      }
      game = null;
      settingMenuOpen = false;
      return;
    }

    game.handleKeyPress(key, keyCode);
    if (game.gameOver && (key == 'r' || key == 'R')) {
      uiStat = UI_CHARACTER_SELECTION;
      game = null;
      settingMenuOpen = false;
    }
  } else if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.keyPressed();
  }
}

void keyReleased() {
  if (uiStat == UI_GAME) {
    game.handleKeyRelease(key, keyCode);
  }
}
