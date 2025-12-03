import gifAnimation.*; // 新增: 引入 GIF 動畫庫
import processing.sound.*; // 新增的聲音庫

int player1Index = 0; // 玩家1選擇的角色索引
int player2Index = 0; // 玩家2選擇的角色索引

/*
角色列表:
1: 上下左右顛倒
2: 聲控巨人 (新增)
*/

final int UI_NONE = 0;
final int UI_TITLE_SCREEN = 1;
final int UI_CHARACTER_SELECTION = 2;
final int UI_STAGE_SELECTION = 3;
final int UI_GAME = 4;
final int UI_STAGE_EDITOR = 5;
int uiStat = 1;
Game game;
StageEditor stageEditor;

// 聲音相關變數
AudioIn input;
Amplitude analyzer;


void setup() {
  size(960, 540); // 螢幕大小
  setupTitleScreen(); // 初始化遊戲開始畫面(定義在 GameStart.pde)
  setupCharacterSelection(); // 初始化角色選擇(定義在 CharacterSelection.pde)
  setupStageSelector(); // 初始化關卡選擇(定義在 StageSelector.pde)
  stageEditor = new StageEditor(); // 初始化關卡編輯器
   // 初始化聲音
  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);
}

void draw() {
  if (uiStat == UI_TITLE_SCREEN) {
    drawTitleScreen();
  } else if (uiStat == UI_CHARACTER_SELECTION) {
    drawCharacterSelection(); // 繪製角色選擇畫面(定義在 CharacterSelection.pde)
  } else if (uiStat == UI_STAGE_SELECTION) {
    drawStageSelector(); // 繪製關卡選擇畫面(定義在 StageSelector.pde)
  } else if (uiStat == UI_GAME) {
    background(200);
    game.update();
    game.display();
    // 顯示除錯資訊
    text("palyer1Index: " + player1Index, 10, height - 40);
    text("palyer2Index: " + player2Index, 10, height - 20);
  } else if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.update();
    stageEditor.display();
  }
}

void mousePressed() {
  if (uiStat == UI_TITLE_SCREEN) {
    uiStat = UI_CHARACTER_SELECTION;
    // 當離開標題畫面時停止 GIF 播放(可選,節省資源)
    if (startBackgroundGif != null) {
      startBackgroundGif.pause();
    }
    handleTitleScreenClick();
  } else if (uiStat == UI_STAGE_SELECTION) {
    stageSelectorMousePressed();
  } else if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.mousePressed();
  }
}

void mouseDragged() {
  if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.mouseDragged();
  }
}

void mouseReleased() {
  if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.mouseReleased();
  }
}

void keyPressed() {
  if (uiStat == UI_CHARACTER_SELECTION) {
    characterSelectorKeyPressed();
  }
  else if (uiStat == UI_STAGE_SELECTION) {
    stageSelectorKeyPressed();
  }
  else if (uiStat == UI_GAME) {
    game.handleKeyPress(key, keyCode);
    // 按 R 重新開始遊戲
    if (game.gameOver && (key == 'r' || key == 'R')) {
      game = new Game(selectedStageIndex, player1Index, player2Index);
    }
  }
  else if (uiStat == UI_STAGE_EDITOR) {
    stageEditor.keyPressed();
  }
}

void keyReleased() {
  if (uiStat == UI_GAME) {
    game.handleKeyRelease(key, keyCode);
  }
}
