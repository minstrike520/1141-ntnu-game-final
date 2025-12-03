StageEditor stageEditor;
int customStageCount = 0;

void setupStageEditor() {
  stageEditor = new StageEditor();
}

// Stage Editor for creating and editing platforms
class StageEditor {
  ArrayList<Platform> platforms;
  Platform selectedPlatform;
  Platform draggedPlatform;
  PVector dragOffset;
  boolean isDragging;
  int gridSize = 10;
  boolean snapToGrid = true;
  
  // UI Elements
  Button addButton;
  Button removeButton;
  Button exportButton;
  Button appendButton;
  Button backButton;
  Button gridToggleButton;
  
  // Default platform size for new platforms
  float defaultWidth = 100;
  float defaultHeight = 20;
  
  StageEditor() {
    platforms = new ArrayList<Platform>();
    selectedPlatform = null;
    draggedPlatform = null;
    isDragging = false;
    dragOffset = new PVector(0, 0);
    
    // Initialize UI buttons
    addButton = new Button(20, 20, 100, 40, "Add Platform");
    removeButton = new Button(130, 20, 120, 40, "Remove");
    exportButton = new Button(260, 20, 100, 40, "export");
    appendButton = new Button(370, 20, 120, 40, "append to game");
    backButton = new Button(width - 120, 20, 100, 40, "Back");
    gridToggleButton = new Button(500, 20, 120, 40, "Grid: ON");
  }
  
  void update() {
    // Update UI buttons
    addButton.update();
    removeButton.update();
    exportButton.update();
    appendButton.update();
    backButton.update();
    gridToggleButton.update();
  }
  
  void display() {
    background(220);
    
    // Draw grid if enabled
    if (snapToGrid) {
      drawGrid();
    }
    
    // Draw all platforms
    for (Platform p : platforms) {
      if (p == selectedPlatform) {
        // Highlight selected platform
        fill(100, 200, 255);
      } else {
        fill(100);
      }
      stroke(0);
      strokeWeight(2);
      rect(p.pos.x, p.pos.y, p.wh.x, p.wh.y);
      
      // Show dimensions on selected platform
      if (p == selectedPlatform) {
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(12);
        text((int)p.wh.x + "x" + (int)p.wh.y, p.pos.x + p.wh.x/2, p.pos.y + p.wh.y/2);
      }
    }
    
    // Draw UI
    addButton.display();
    removeButton.display();
    exportButton.display();
    appendButton.display();
    backButton.display();
    gridToggleButton.display();
    
    // Draw instructions
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
    
    // Vertical lines
    for (int x = 0; x < width; x += gridSize) {
      line(x, 0, x, height);
    }
    
    // Horizontal lines
    for (int y = 0; y < height; y += gridSize) {
      line(0, y, width, y);
    }
  }
  
  void mousePressed() {
    // Check UI buttons first
    if (addButton.isMouseOver()) {
      addPlatform();
      return;
    }
    
    if (removeButton.isMouseOver() && selectedPlatform != null) {
      platforms.remove(selectedPlatform);
      selectedPlatform = null;
      return;
    }
    
    if (exportButton.isMouseOver()) {
      exportCode();
      return;
    }

    if (appendButton.isMouseOver()) {
      append();
      return;
    }
    
    if (backButton.isMouseOver()) {
      uiStat = UI_STAGE_SELECTION; // 改為回到 Stage Selection
      return;
    }
    
    if (gridToggleButton.isMouseOver()) {
      snapToGrid = !snapToGrid;
      gridToggleButton.label = snapToGrid ? "Grid: ON" : "Grid: OFF";
      return;
    }
    
    // Check if clicking on a platform
    PVector mouse = new PVector(mouseX, mouseY);
    selectedPlatform = null;
    
    for (int i = platforms.size() - 1; i >= 0; i--) {
      Platform p = platforms.get(i);
      if (p.contains(mouse)) {
        selectedPlatform = p;
        draggedPlatform = p;
        isDragging = true;
        dragOffset = new PVector(mouseX - p.pos.x, mouseY - p.pos.y);
        break;
      }
    }
  }
  
  void mouseDragged() {
    if (isDragging && draggedPlatform != null) {
      float newX = mouseX - dragOffset.x;
      float newY = mouseY - dragOffset.y;
      
      if (snapToGrid) {
        newX = round(newX / gridSize) * gridSize;
        newY = round(newY / gridSize) * gridSize;
      }
      
      draggedPlatform.pos.x = constrain(newX, 0, width - draggedPlatform.wh.x);
      draggedPlatform.pos.y = constrain(newY, 0, height - draggedPlatform.wh.y);
    }
  }
  
  void mouseReleased() {
    isDragging = false;
    draggedPlatform = null;
  }
  
  void addPlatform() {
    float x = width / 2 - defaultWidth / 2;
    float y = height / 2 - defaultHeight / 2;
    
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
    
    // Show confirmation
    println("Code exported to console! Copy and paste into Game.pde");
  }

  void append() {
    customStageCount++;
    stageList.add(new Stage("Custom" + customStageCount, new ArrayList<>(platforms)));
  }
  
  void keyPressed() {
    if (selectedPlatform != null) {
      float moveAmount = keyPressed && keyCode == SHIFT ? 1 : gridSize;
      
      // Arrow keys to move selected platform
      if (keyCode == LEFT) {
        selectedPlatform.pos.x -= moveAmount;
      } else if (keyCode == RIGHT) {
        selectedPlatform.pos.x += moveAmount;
      } else if (keyCode == UP) {
        selectedPlatform.pos.y -= moveAmount;
      } else if (keyCode == DOWN) {
        selectedPlatform.pos.y += moveAmount;
      }
      
      // WASD to resize selected platform
      if (key == 'a' || key == 'A') {
        selectedPlatform.wh.x = max(20, selectedPlatform.wh.x - moveAmount);
      } else if (key == 'd' || key == 'D') {
        selectedPlatform.wh.x += moveAmount;
      } else if (key == 'w' || key == 'W') {
        selectedPlatform.wh.y = max(10, selectedPlatform.wh.y - moveAmount);
      } else if (key == 's' || key == 'S') {
        selectedPlatform.wh.y += moveAmount;
      }
      
      // Delete key to remove selected platform
      if (keyCode == DELETE || keyCode == BACKSPACE) {
        platforms.remove(selectedPlatform);
        selectedPlatform = null;
      }
    }
  }
}

// Simple Button class for UI
class Button {
  float x, y, w, h;
  String label;
  color normalColor = color(150);
  color hoverColor = color(200);
  color textColor = color(0);
  
  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  void update() {
    // Button behavior can be expanded here
  }
  
  void display() {
    // Draw button background
    if (isMouseOver()) {
      fill(hoverColor);
    } else {
      fill(normalColor);
    }
    stroke(0);
    strokeWeight(2);
    rect(x, y, w, h, 5);
    
    // Draw label
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(label, x + w/2, y + h/2);
  }
  
  boolean isMouseOver() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}
