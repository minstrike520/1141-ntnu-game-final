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
SoundFile bgMusic; // 背景音樂

// 設定選單相關變數
PImage settingIcon;
boolean settingMenuOpen = false;
float settingButtonX, settingButtonY, settingButtonSize;
float volumeSliderValue = 0.5; // 音量值 (0.0 - 1.0)

// 設定選單項目
String[] menuItems = {"音量大小", "角色相關", "退出遊戲"};
int selectedMenuItem = -1; // -1 表示沒有選中
boolean showCharacterInfo = false; // 是否顯示角色資訊

void setup() {
  size(960, 540);
  font = createFont("NotoSansCJKtc-Regular.ttc", 32);
  textFont(font);
  setupTitleScreen();
  setupCharacterSelection();
  setupStageSelector();
  setupStageEditor();
  
  // 初始化聲音
  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  // 載入背景音樂（支援 .mp3 或 .wav 格式）
  try {
    bgMusic = new SoundFile(this, "game.mp3"); // 改為 game.mp3
    bgMusic.loop();
    bgMusic.amp(volumeSliderValue);
  } catch (Exception e) {
    println("背景音樂載入失敗: " + e.getMessage());
    println("請確保 game.mp3 檔案在 data 資料夾中");
  }
  
  // 載入設定圖示
  settingIcon = loadImage("setting.png");
  
  // 設定按鈕位置（右上角）
  settingButtonSize = 40;
  settingButtonX = width - settingButtonSize - 10;
  settingButtonY = 10;
}

void draw() {
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
    
    // 繪製設定按鈕
    drawSettingButton();
    
    // 繪製設定選單
    if (settingMenuOpen) {
      drawSettingMenu();
    }
    
    // 顯示角色資訊（當選中「角色相關」時）
    if (showCharacterInfo) {
      drawCharacterInfo();
    }
  } else if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.update();
    stageEditor.display();
  }
}

void drawSettingButton() {
  // 繪製設定按鈕
  imageMode(CORNER);
  image(settingIcon, settingButtonX, settingButtonY, settingButtonSize, settingButtonSize);
  
  // 滑鼠懸停效果
  if (mouseX >= settingButtonX && mouseX <= settingButtonX + settingButtonSize &&
      mouseY >= settingButtonY && mouseY <= settingButtonY + settingButtonSize) {
    noFill();
    stroke(255, 200, 0);
    strokeWeight(3);
    rect(settingButtonX, settingButtonY, settingButtonSize, settingButtonSize);
  }
}

void drawSettingMenu() {
  // 半透明背景
  fill(0, 0, 0, 150);
  noStroke();
  float menuWidth = 200;
  float menuHeight = 200; // 增加高度
  float menuX = settingButtonX - menuWidth + settingButtonSize;
  float menuY = settingButtonY + settingButtonSize + 5;
  rect(menuX, menuY, menuWidth, menuHeight, 10);
  
  // 繪製選單項目
  fill(255);
  textSize(18); // 字體加大
  textAlign(CENTER, CENTER);
  float itemHeight = 50; // 增加項目高度
  float itemY = menuY + 15;
  
  for (int i = 0; i < menuItems.length; i++) {
    // 滑鼠懸停效果
    if (mouseX >= menuX && mouseX <= menuX + menuWidth &&
        mouseY >= itemY && mouseY <= itemY + itemHeight) {
      fill(255, 255, 100);
      selectedMenuItem = i;
    } else {
      fill(255);
    }
    
    // 調整文字位置，為滑桿留出空間
    if (i == 0) {
      text(menuItems[i], menuX + menuWidth/2, itemY + 15); // 音量大小文字往上
    } else {
      text(menuItems[i], menuX + menuWidth/2, itemY + itemHeight/2);
    }
    
    // 如果是「音量大小」，顯示滑桿
    if (i == 0) {
      drawVolumeSlider(menuX, itemY + 35, menuWidth); // 滑桿往下移
    }
    
    itemY += itemHeight;
  }
}

void drawVolumeSlider(float x, float y, float w) {
  float sliderWidth = w - 40;
  float sliderX = x + 20;
  float sliderY = y;
  
  // 滑桿軌道
  stroke(200);
  strokeWeight(4);
  line(sliderX, sliderY, sliderX + sliderWidth, sliderY);
  
  // 滑桿按鈕
  float knobX = sliderX + volumeSliderValue * sliderWidth;
  fill(255, 200, 0);
  noStroke();
  circle(knobX, sliderY, 15);
  
  // 音量百分比
  fill(200);
  textSize(12);
  textAlign(CENTER, CENTER);
  text((int)(volumeSliderValue * 100) + "%", sliderX + sliderWidth/2, sliderY + 15);
}

void drawCharacterInfo() {
  // 半透明黑色背景
  fill(0, 0, 0, 200);
  noStroke();
  rect(0, 0, width, height);
  
  // 標題
  fill(255, 200, 100);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("角色相關資訊", width/2, 80);
  
  // Player 1 控制說明
  fill(100, 150, 255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Player 1 (藍色)", 100, 150);
  
  fill(255);
  textSize(16);
  String p1Controls = "控制：W=跳躍, A=左移, D=右移\n";
  if (game.player1.type == 0) {
    p1Controls += "角色：炸彈客\n技能：E=放置炸彈 (雙跳可跳3倍高!)";
  } else if (game.player1.type == 1) {
    p1Controls += "角色：忍者\n技能：E=拋擲炸彈";
  } else if (game.player1.type == 2) {
    p1Controls += "角色：騎士\n技能：E=鉤爪繩索";
  } else if (game.player1.type == 3) {
    p1Controls += "角色：巫師";
  }
  text(p1Controls, 100, 180);
  
  // Player 2 控制說明
  fill(255, 150, 100);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Player 2 (橙色)", width/2 + 50, 150);
  
  fill(255);
  textSize(16);
  String p2Controls = "控制：UP=跳躍, LEFT/RIGHT=移動\n";
  if (game.player2.type == 0) {
    p2Controls += "角色：炸彈客\n技能：K=放置炸彈 (雙跳可跳3倍高!)";
  } else if (game.player2.type == 1) {
    p2Controls += "角色：忍者\n技能：K=拋擲炸彈";
  } else if (game.player2.type == 2) {
    p2Controls += "角色：騎士\n技能：K=鉤爪繩索";
  } else if (game.player2.type == 3) {
    p2Controls += "角色：巫師";
  }
  text(p2Controls, width/2 + 50, 180);
  
  // 提示按鍵
  fill(255, 255, 100);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("按任意鍵關閉", width/2, height - 50);
}

void mousePressed() {
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
    // 處理設定按鈕點擊
    if (mouseX >= settingButtonX && mouseX <= settingButtonX + settingButtonSize &&
        mouseY >= settingButtonY && mouseY <= settingButtonY + settingButtonSize) {
      settingMenuOpen = !settingMenuOpen;
      return;
    }
    
    // 處理設定選單點擊
    if (settingMenuOpen) {
      float menuWidth = 200;
      float menuHeight = 200; // 更新高度
      float menuX = settingButtonX - menuWidth + settingButtonSize;
      float menuY = settingButtonY + settingButtonSize + 5;
      
      // 檢查是否點擊在選單內
      if (mouseX >= menuX && mouseX <= menuX + menuWidth &&
          mouseY >= menuY && mouseY <= menuY + menuHeight) {
        
        float itemHeight = 50; // 更新項目高度
        float itemY = menuY + 15;
        
        for (int i = 0; i < menuItems.length; i++) {
          if (mouseY >= itemY && mouseY <= itemY + itemHeight) {
            if (i == 0) {
              // 音量大小 - 在 mouseDragged 中處理
            } else if (i == 1) {
              // 角色相關
              showCharacterInfo = true;
              settingMenuOpen = false;
            } else if (i == 2) {
              // 退出遊戲
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
        // 點擊選單外部，關閉選單
        settingMenuOpen = false;
      }
    }
  }
}

void mouseDragged() {
  if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.mouseDragged();
  } else if (uiStat == UI_GAME && settingMenuOpen) {
    // 處理音量滑桿拖曳
    float menuWidth = 200;
    float menuX = settingButtonX - menuWidth + settingButtonSize;
    float menuY = settingButtonY + settingButtonSize + 5;
    float sliderWidth = menuWidth - 40;
    float sliderX = menuX + 20;
    float sliderY = menuY + 15 + 35; // 更新滑桿位置
    
    if (abs(mouseY - sliderY) < 20) {
      volumeSliderValue = constrain((mouseX - sliderX) / sliderWidth, 0, 1);
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
  // 關閉角色資訊視窗
  if (showCharacterInfo) {
    showCharacterInfo = false;
    return;
  }
  
  // 全域 ESC 行為
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
