class Game {
  Player player1;
  Player player2;
  ArrayList<Platform> platforms;
  
  Game() {
    this(1); // Default to stage 1
  }
  
  Game(int stage) {
    // Player 1: WAD controls (A=left, D=right, W=jump)
    player1 = new Player(100, 100, color(100, 150, 255), 'a', 'd', 'w');
    // Player 2: Arrow keys (LEFT, RIGHT, UP)
    player2 = new Player(600, 100, color(255, 150, 100), LEFT, RIGHT, UP);
    
    // Initialize platforms
    platforms = getStageplatforms(stage);
  }
  
  void update() {
    player1.update(platforms);
    player2.update(platforms);
  }
  
  void display() {
    // Display platforms
    for (Platform p : platforms) {
      p.display();
    }
    
    // Display players
    player1.display();
    player2.display();
    
    // Display controls info
    fill(0);
    textSize(14);
    textAlign(LEFT, CENTER);
    text("Player 1 (Blue): W=Jump, A=Left, D=Right", 10, 20);
    text("Player 2 (Orange): UP=Jump, LEFT, RIGHT", 10, 40);
  }
  
  void handleKeyPress(char k, int kc) {
    player1.handleKeyPress(k, kc);
    player2.handleKeyPress(k, kc);
  }
  
  void handleKeyRelease(char k, int kc) {
    player1.handleKeyRelease(k, kc);
    player2.handleKeyRelease(k, kc);
  }
}