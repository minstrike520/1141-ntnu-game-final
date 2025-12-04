StageEditor stageEditor;
int customStageCount = 0;

void setupStageEditor() {
  stageEditor = new StageEditor();
}

class StageEditor {
  ArrayList<Platform> platforms;
  Platform selectedPlatform;
  Platform draggedPlatform;
  PVector dragOffset;
  boolean isDragging;
  int gridSize = 10;
  boolean snapToGrid = true;
  
  Button addButton;
  Button removeButton;
  Button exportButton;
  Button appendButton;
  Button backButton;
  Button gridToggleButton;
  
  float defaultWidth = 100;
  float defaultHeight = 20;
  
  StageEditor() {
    platforms = new ArrayList<Platform>();
    selectedPlatform = null;
    draggedPlatform = null;
    isDragging = false;
    dragOffset = new PVector(0, 0);
    
    addButton = new Button(20, 20, 100, 40, "Add Platform");
    removeButton = new Button(130, 20, 120, 40, "Remove");
    exportButton = new Button(260, 20, 100, 40, "export");
    appendButton = new Button(370, 20, 120, 40, "append to game");
    backButton = new Button(DESIGN_WIDTH - 120, 20, 100, 40, "Back");
    gridToggleButton = new Button(500, 20, 120, 40, "Grid: ON");
  }
  
  void update() {
    float mx = screenToDesignX(mouseX);
    float my = screenToDesignY(mouseY);
    
    addButton.update(mx, my);
    removeButton.update(mx, my);
    exportButton.update(mx, my);
    appendButton.update(mx, my);
    backButton.update(mx, my);
    gridToggleButton.update(mx, my);
  }
  
  void display() {
    background(220);
    
    if (snapToGrid) {
      drawGrid();
    }
    
    for (Platform p : platforms) {
      if (p == selectedPlatform) {
        fill(100, 200, 255);
      } else {
        fill(100);
      }
      stroke(0);
      strokeWeight(2);
      rect(p.pos.x, p.pos.y, p.wh.x, p.wh.y);
      
      if (p == selectedPlatform) {
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(12);
        text((int)p.wh.x + "x" + (int)p.wh.y, p.pos.x + p.wh.x/2, p.pos.y + p.wh.y/2);
      }
    }
    
    addButton.display();
    removeButton.display();
    exportButton.display();
    appendButton.display();
    backButton.display();
    gridToggleButton.display();
    
    fill(0);
    textAlign(LEFT, TOP);
    textSize(14);
    text("Click platform to select | Drag to move | WASD to resize", 20, 70);
    text("Platforms: " + platforms.size(), 20, 90);
    
    if (selectedPlatform != null) {
      text("Selected: (" + (int)selectedPlatform.pos.x + ", " + (int)selectedPlatform.pos.y + 
           ") Size: " + (int)selectedPlatform.wh.x + "x" + (int)selectedPlatform.wh.y, 20, 110);
    }
  }
  
  void drawGrid() {
    stroke(200);
    strokeWeight(1);
    
    for (int x = 0; x < DESIGN_WIDTH; x += gridSize) {
      line(x, 0, x, DESIGN_HEIGHT);
    }
    
    for (int y = 0; y < DESIGN_HEIGHT; y += gridSize) {
      line(0, y, DESIGN_WIDTH, y);
    }
  }
  
  void mousePressed() {
    float mx = screenToDesignX(mouseX);
    float my = screenToDesignY(mouseY);
    
    if (addButton.isMouseOver(mx, my)) {
      addPlatform();
      return;
    }
    
    if (removeButton.isMouseOver(mx, my) && selectedPlatform != null) {
      platforms.remove(selectedPlatform);
      selectedPlatform = null;
      return;
    }
    
    if (exportButton.isMouseOver(mx, my)) {
      exportCode();
      return;
    }

    if (appendButton.isMouseOver(mx, my)) {
      append();
      return;
    }
    
    if (backButton.isMouseOver(mx, my)) {
      uiStat = UI_STAGE_SELECTION;
      return;
    }
    
    if (gridToggleButton.isMouseOver(mx, my)) {
      snapToGrid = !snapToGrid;
      gridToggleButton.label = snapToGrid ? "Grid: ON" : "Grid: OFF";
      return;
    }
    
    PVector mouse = new PVector(mx, my);
    selectedPlatform = null;
    
    for (int i = platforms.size() - 1; i >= 0; i--) {
      Platform p = platforms.get(i);
      if (p.contains(mouse)) {
        selectedPlatform = p;
        draggedPlatform = p;
        isDragging = true;
        dragOffset = new PVector(mx - p.pos.x, my - p.pos.y);
        break;
      }
    }
  }
  
  void mouseDragged() {
    if (isDragging && draggedPlatform != null) {
      float mx = screenToDesignX(mouseX);
      float my = screenToDesignY(mouseY);
      
      float newX = mx - dragOffset.x;
      float newY = my - dragOffset.y;
      
      if (snapToGrid) {
        newX = round(newX / gridSize) * gridSize;
        newY = round(newY / gridSize) * gridSize;
      }
      
      draggedPlatform.pos.x = constrain(newX, 0, DESIGN_WIDTH - draggedPlatform.wh.x);
      draggedPlatform.pos.y = constrain(newY, 0, DESIGN_HEIGHT - draggedPlatform.wh.y);
    }
  }
  
  void mouseReleased() {
    isDragging = false;
    draggedPlatform = null;
  }
  
  void addPlatform() {
    float x = DESIGN_WIDTH / 2 - defaultWidth / 2;
    float y = DESIGN_HEIGHT / 2 - defaultHeight / 2;
    
    if (snapToGrid) {
      x = round(x / gridSize) * gridSize;
      y = round(y / gridSize) * gridSize;
    }
    
    Platform newPlatform = new Platform(x, y, defaultWidth, defaultHeight);
    platforms.add(newPlatform);
    selectedPlatform = newPlatform;
  }
  
  void exportCode() {
    println("\n// ===== EXPORTED STAGE CODE =====");
    println("void createPlatforms" + (platforms.size() > 0 ? "Custom" : "Empty") + "() {");
    
    for (Platform p : platforms) {
      println("  platforms.add(new Platform(" + 
              (int)p.pos.x + ", " + 
              (int)p.pos.y + ", " + 
              (int)p.wh.x + ", " + 
              (int)p.wh.y + "));");
    }
    
    println("}");
    println("// ===== END EXPORTED CODE =====\n");
    
    println("Code exported to console! Copy and paste into Game.pde");
  }

  void append() {
    customStageCount++;
    stageList.add(new Stage("Custom" + customStageCount, new ArrayList<>(platforms)));
  }
  
  void keyPressed() {
    if (selectedPlatform != null) {
      float moveAmount = keyPressed && keyCode == SHIFT ? 1 : gridSize;
      
      if (keyCode == LEFT) {
        selectedPlatform.pos.x -= moveAmount;
      } else if (keyCode == RIGHT) {
        selectedPlatform.pos.x += moveAmount;
      } else if (keyCode == UP) {
        selectedPlatform.pos.y -= moveAmount;
      } else if (keyCode == DOWN) {
        selectedPlatform.pos.y += moveAmount;
      }
      
      if (key == 'a' || key == 'A') {
        selectedPlatform.wh.x = max(20, selectedPlatform.wh.x - moveAmount);
      } else if (key == 'd' || key == 'D') {
        selectedPlatform.wh.x += moveAmount;
      } else if (key == 'w' || key == 'W') {
        selectedPlatform.wh.y = max(10, selectedPlatform.wh.y - moveAmount);
      } else if (key == 's' || key == 'S') {
        selectedPlatform.wh.y += moveAmount;
      }
      
      if (keyCode == DELETE || keyCode == BACKSPACE) {
        platforms.remove(selectedPlatform);
        selectedPlatform = null;
      }
    }
  }
}

class Button {
  float x, y, w, h;
  String label;
  color normalColor = color(150);
  color hoverColor = color(200);
  color textColor = color(0);
  boolean isHovered = false;
  
  Button(float x, float y, float w, float h, String label) {
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
