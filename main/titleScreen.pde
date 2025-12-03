import gifAnimation.*;

Gif startBackgroundGif;
float textAlpha = 255;
boolean alphaIncreasing = false;

// Button areas for title screen
float startButtonX, startButtonY, startButtonW, startButtonH;

void setupTitleScreen() {
  startBackgroundGif = new Gif(this, "titleScreen.gif");
  startBackgroundGif.loop();
  
  // Initialize button positions
  startButtonW = 200;
  startButtonH = 60;
  startButtonX = width / 2 - startButtonW / 2;
  startButtonY = height / 2 * 0.6 - startButtonH / 2;
}

void drawTitleScreen() {
  textAlign(CENTER, CENTER);
  
  if (startBackgroundGif != null) {
    image(startBackgroundGif, 0, 0, width, height);
  } else {
    background(0);
  }
  
  // Draw Start Game button
  boolean hoverStart = isMouseOverButton(startButtonX, startButtonY, startButtonW, startButtonH);
  if (hoverStart) {
    fill(0, 150, 0, 200);
  } else {
    fill(0, 100, 0, textAlpha);
  }
  textSize(48);
  text("Start Game", width / 2 - 15, startButtonY + 30);
  
  // Blinking effect
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

boolean isMouseOverButton(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}

void handleTitleScreenClick() {
  // Check if Start Game button is clicked
  if (isMouseOverButton(startButtonX, startButtonY, startButtonW, startButtonH)) {
    uiStat = UI_CHARACTER_SELECTION;
    // 當離開標題畫面時停止 GIF 播放(可選,節省資源)
    if (startBackgroundGif != null) {
      startBackgroundGif.pause();
    }
  }
}
