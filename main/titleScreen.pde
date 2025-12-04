import gifAnimation.*;

Gif startBackgroundGif;
float textAlpha = 255;
boolean alphaIncreasing = false;

float startButtonX, startButtonY, startButtonW, startButtonH;

void setupTitleScreen() {
  startBackgroundGif = new Gif(this, "titleScreen.gif");
  startBackgroundGif.loop();
  
  startButtonW = 200;
  startButtonH = 60;
  startButtonX = DESIGN_WIDTH / 2 - startButtonW / 2;
  startButtonY = DESIGN_HEIGHT / 2 * 0.6 - startButtonH / 2;
}

void drawTitleScreen() {
  textAlign(CENTER, CENTER);
  
  if (startBackgroundGif != null) {
    image(startBackgroundGif, 0, 0, DESIGN_WIDTH, DESIGN_HEIGHT);
  } else {
    background(0);
  }
  
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  boolean hoverStart = isMouseOverButton(startButtonX, startButtonY, startButtonW, startButtonH, mx, my);
  
  if (hoverStart) {
    fill(0, 150, 0, 200);
  } else {
    fill(0, 100, 0, textAlpha);
  }
  textSize(48);
  text("Start Game", DESIGN_WIDTH / 2 - 15, startButtonY + 30);
  
  if (alphaIncreasing) {
    textAlpha += 5;
    if (textAlpha >= 255) {
      textAlpha = 255;
      alphaIncreasing = false;
    }
  } else {
    textAlpha -= 5;
    if (textAlpha <= 100) {
      textAlpha = 100;
      alphaIncreasing = true;
    }
  }
}

boolean isMouseOverButton(float x, float y, float w, float h, float mx, float my) {
  return mx >= x && mx <= x + w && my >= y && my <= y + h;
}

void handleTitleScreenClick() {
  float mx = screenToDesignX(mouseX);
  float my = screenToDesignY(mouseY);
  
  if (isMouseOverButton(startButtonX, startButtonY, startButtonW, startButtonH, mx, my)) {
    uiStat = UI_CHARACTER_SELECTION;
    if (startBackgroundGif != null) {
      startBackgroundGif.pause();
    }
  }
}
