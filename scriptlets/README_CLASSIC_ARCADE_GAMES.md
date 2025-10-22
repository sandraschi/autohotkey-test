# 🎮 Classic Arcade Games Collection

A collection of classic arcade games recreated in AutoHotkey v2, showcasing the power and versatility of the scripting language for game development.

## 🕹️ Games Included

### 🏓 **Classic Pong** (`classic_pong.ahk`)
- **Hotkeys**: `Ctrl+Alt+P` or `F5`
- **Features**:
  - Classic Pong gameplay with ball physics
  - AI opponent with adjustable difficulty (Easy/Medium/Hard)
  - Sound effects for paddle hits, wall bounces, and scoring
  - Score tracking (first to 10 points wins)
  - Smooth 60 FPS gameplay
  - Responsive controls with W/S keys

**How to Play**:
- Use `W` and `S` to move your paddle up and down
- Press `SPACE` to start/pause the game
- Press `R` to reset the game
- Press `M` for settings and instructions

### 🐸 **Classic Frogger** (`classic_frogger.ahk`)
- **Hotkeys**: `Ctrl+Alt+F` or `F6`
- **Features**:
  - Classic Frogger gameplay with cars, logs, and turtles
  - Progressive difficulty with each level
  - Lives system (3 lives)
  - Score tracking (100 points × level for reaching home)
  - Dynamic obstacle movement
  - Turtle submerging mechanics

**How to Play**:
- Use arrow keys to move the frog
- Avoid cars on the road
- Jump on logs to cross the river
- Jump on turtles (but watch out - they submerge!)
- Reach the top to score points and advance levels
- Press `SPACE` to start/pause, `R` to reset

### ♟️ **Chess with Stockfish** (`chess_stockfish.ahk`)
- **Hotkeys**: `Ctrl+Alt+C` or `F7`
- **Features**:
  - Full chess game implementation
  - Stockfish engine integration for AI opponent
  - Multiple game modes (Human vs AI, Human vs Human, AI vs AI)
  - Move validation and game state tracking
  - FEN notation support
  - Game history and captured pieces tracking

**Requirements**:
- Download Stockfish from https://stockfishchess.org/download/
- Place `stockfish.exe` in the scriptlets directory or engines subfolder

**How to Play**:
- Click on a piece to select it
- Click on destination square to move
- Game automatically switches between players
- AI makes moves automatically when playing against computer

## 🎯 **Game Features**

### 🎨 **Visual Design**
- Clean, retro-inspired interfaces
- Color-coded game elements
- Status displays for scores, lives, and game state
- Responsive GUI layouts

### 🔊 **Audio**
- Sound effects for game events
- Different beep patterns for different actions
- Optional sound toggle in settings

### ⌨️ **Controls**
- Intuitive keyboard controls
- Hotkey support for quick game launching
- Consistent control schemes across games

### 🧠 **AI Integration**
- **Pong**: Adjustable difficulty AI opponent
- **Frogger**: Progressive difficulty scaling
- **Chess**: Full Stockfish engine integration

## 🚀 **Technical Implementation**

### **Game Loop Architecture**
```autohotkey
; Standard game loop pattern
StartGameLoop() {
    if (!this.gameRunning) {
        return
    }
    
    this.UpdateGame()
    this.DrawGame()
    
    ; Continue game loop
    SetTimer(() => this.StartGameLoop(), 16) ; ~60 FPS
}
```

### **Collision Detection**
- Rectangle-based collision detection
- Precise hitbox calculations
- Efficient collision checking algorithms

### **State Management**
- Game state tracking (running, paused, game over)
- Score and progress persistence
- Settings and configuration management

### **AI Implementation**
- **Pong AI**: Ball-following with difficulty scaling
- **Frogger AI**: Progressive obstacle spawning
- **Chess AI**: Full Stockfish engine integration with FEN notation

## 🎮 **Usage Instructions**

### **Starting Games**
1. **Via Web Interface**: Click on the game card in `launcher_enhanced.html`
2. **Via Hotkeys**: Use the assigned hotkeys (`F5`, `F6`, `F7`)
3. **Via Native GUI**: Use `scriptlet_launcher_v2.ahk`

### **Game Controls**
- **Pong**: `W`/`S` for paddle, `SPACE` for pause, `R` for reset
- **Frogger**: Arrow keys for movement, `SPACE` for pause, `R` for reset
- **Chess**: Click to select and move pieces, `SPACE` for pause, `R` for reset

### **Settings and Configuration**
- All games include settings menus accessible via `M` key
- Sound can be toggled on/off
- Difficulty levels can be adjusted
- Game modes can be changed

## 🔧 **Development Notes**

### **AutoHotkey v2 Features Used**
- **Classes**: Object-oriented game architecture
- **Timers**: Smooth game loop implementation
- **GUI**: Modern interface design
- **Hotkeys**: Responsive input handling
- **Sound**: Audio feedback system

### **Performance Considerations**
- **Pong**: 60 FPS with smooth ball physics
- **Frogger**: 20 FPS with multiple moving objects
- **Chess**: Event-driven updates for efficiency

### **Extensibility**
- Modular design allows easy addition of new games
- Common game framework can be reused
- AI integration patterns can be applied to other games

## 🎯 **Future Enhancements**

### **Planned Features**
- **Graphics**: GDI+ integration for better visuals
- **Sound**: WAV/MP3 audio support
- **Networking**: Multiplayer support
- **Save System**: High score persistence
- **More Games**: Pac-Man, Space Invaders, Tetris

### **Technical Improvements**
- **Performance**: Optimized rendering pipeline
- **AI**: More sophisticated AI opponents
- **Graphics**: Sprite-based rendering system
- **Audio**: Advanced sound mixing

## 🏆 **Showcasing AutoHotkey Power**

These games demonstrate AutoHotkey's capabilities for:

- **Game Development**: Full game engine functionality
- **AI Integration**: External engine communication
- **Real-time Processing**: Smooth game loops and physics
- **User Interface**: Modern GUI design
- **Input Handling**: Responsive keyboard controls
- **Audio**: Sound effect implementation
- **State Management**: Complex game state tracking

The games prove that AutoHotkey is not just a scripting language, but a powerful platform for creating interactive applications and games!

## 🎮 **Have Fun!**

These classic arcade games bring back the nostalgia of the golden age of arcade gaming, all implemented in AutoHotkey v2. Whether you're looking to relive childhood memories or just want to see what AutoHotkey can do, these games provide hours of entertainment!

**Press `F5`, `F6`, or `F7` to start playing!** 🚀
