﻿; ==============================================================================
; Classic Frogger Game
; @name: Classic Frogger Game
; @version: 1.0.0
; @description: Classic Frogger arcade game with cars, logs, and turtles
; @category: games
; @author: Sandra
; @hotkeys: ^!f, F6
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class FroggerGame {
    static gameGui := ""
    static gameRunning := false
    static frogX := 0
    static frogY := 0
    static frogSize := 20
    static gameWidth := 800
    static gameHeight := 600
    static lives := 3
    static score := 0
    static level := 1
    static cars := []
    static logs := []
    static turtles := []
    static carsSpeed := 2
    static logsSpeed := 1
    static turtlesSpeed := 1
    static soundEnabled := true
    
    static Init() {
        this.gameRunning := false
        this.lives := 3
        this.score := 0
        this.level := 1
        this.ResetFrog()
        this.InitializeObstacles()
        this.CreateGameGUI()
    }
    
    static CreateGameGUI() {
        if (this.gameGui) {
            this.gameGui.Close()
        }
        
        this.gameGui := Gui("+Resize +MinSize800x600", "Classic Frogger - Use Arrow Keys")
        this.gameGui.BackColor := "0x006600"
        this.gameGui.SetFont("s14 cWhite Bold", "Arial")
        
        ; Game area
        this.gameGui.Add("Text", "x10 y10 w780 h580 Border Center", "FROGGER")
        
        ; Status display
        this.gameGui.Add("Text", "x50 y50 w150 h30", "Lives: " . this.lives)
        this.gameGui.Add("Text", "x300 y50 w150 h30", "Score: " . this.score)
        this.gameGui.Add("Text", "x550 y50 w150 h30", "Level: " . this.level)
        
        ; Controls info
        this.gameGui.Add("Text", "x10 y570 w780 h20 Center", "Arrow Keys: Move | SPACE: Start | R: Reset | M: Menu")
        
        ; Menu button
        this.gameGui.Add("Button", "x350 y100 w100 h40", "Start Game").OnEvent("Click", this.StartGame.Bind(this))
        this.gameGui.Add("Button", "x350 y150 w100 h40", "Instructions").OnEvent("Click", this.ShowInstructions.Bind(this))
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        this.gameGui.Show("w800 h600")
    }
    
    static StartGame(*) {
        this.gameRunning := true
        this.StartGameLoop()
    }
    
    static ResetFrog() {
        this.frogX := this.gameWidth // 2
        this.frogY := this.gameHeight - 50
    }
    
    static InitializeObstacles() {
        this.cars := []
        this.logs := []
        this.turtles := []
        
        ; Create cars (moving left to right)
        Loop 5 {
            this.cars.Push({
                x: Random(0, this.gameWidth),
                y: 500 + (A_Index * 20),
                speed: this.carsSpeed + Random(-1, 1),
                width: 40,
                height: 20
            })
        }
        
        ; Create logs (moving right to left)
        Loop 4 {
            this.logs.Push({
                x: Random(0, this.gameWidth),
                y: 300 + (A_Index * 30),
                speed: this.logsSpeed + Random(-1, 1),
                width: 60,
                height: 25
            })
        }
        
        ; Create turtles (moving left to right)
        Loop 3 {
            this.turtles.Push({
                x: Random(0, this.gameWidth),
                y: 200 + (A_Index * 25),
                speed: this.turtlesSpeed + Random(-1, 1),
                width: 30,
                height: 20,
                submerged: false,
                submergeTimer: 0
            })
        }
    }
    
    static StartGameLoop() {
        if (!this.gameRunning) {
            return
        }
        
        this.UpdateGame()
        this.DrawGame()
        
        ; Continue game loop
        SetTimer(() => this.StartGameLoop(), 50) ; ~20 FPS
    }
    
    static UpdateGame() {
        if (!this.gameRunning) {
            return
        }
        
        ; Move obstacles
        this.UpdateCars()
        this.UpdateLogs()
        this.UpdateTurtles()
        
        ; Check collisions
        this.CheckCollisions()
        
        ; Check if frog reached home
        if (this.frogY <= 50) {
            this.score += 100 * this.level
            this.level++
            this.IncreaseDifficulty()
            this.ResetFrog()
            this.PlaySound("home")
        }
        
        ; Check if frog fell in water
        if (this.frogY > 100 && this.frogY < 400) {
            onLog := false
            onTurtle := false
            
            ; Check if on log
            for log in this.logs {
                if (this.frogX >= log.x && this.frogX <= log.x + log.width &&
                    this.frogY >= log.y && this.frogY <= log.y + log.height) {
                    onLog := true
                    this.frogX += log.speed
                    break
                }
            }
            
            ; Check if on turtle
            for turtle in this.turtles {
                if (!turtle.submerged && 
                    this.frogX >= turtle.x && this.frogX <= turtle.x + turtle.width &&
                    this.frogY >= turtle.y && this.frogY <= turtle.y + turtle.height) {
                    onTurtle := true
                    this.frogX += turtle.speed
                    break
                }
            }
            
            ; If not on log or turtle, frog drowns
            if (!onLog && !onTurtle) {
                this.LoseLife()
            }
        }
        
        ; Keep frog in bounds
        if (this.frogX < 0) {
            this.frogX := 0
        } else if (this.frogX > this.gameWidth - this.frogSize) {
            this.frogX := this.gameWidth - this.frogSize
        }
    }
    
    static UpdateCars() {
        for car in this.cars {
            car.x += car.speed
            if (car.x > this.gameWidth) {
                car.x := -car.width
            }
        }
    }
    
    static UpdateLogs() {
        for log in this.logs {
            log.x -= log.speed
            if (log.x < -log.width) {
                log.x := this.gameWidth
            }
        }
    }
    
    static UpdateTurtles() {
        for turtle in this.turtles {
            turtle.x += turtle.speed
            if (turtle.x > this.gameWidth) {
                turtle.x := -turtle.width
            }
            
            ; Turtles submerge occasionally
            turtle.submergeTimer++
            if (turtle.submergeTimer > 100) {
                turtle.submerged := !turtle.submerged
                turtle.submergeTimer := 0
            }
        }
    }
    
    static CheckCollisions() {
        ; Check collision with cars
        for car in this.cars {
            if (this.frogX < car.x + car.width && this.frogX + this.frogSize > car.x &&
                this.frogY < car.y + car.height && this.frogY + this.frogSize > car.y) {
                this.LoseLife()
                return
            }
        }
    }
    
    static LoseLife() {
        this.lives--
        this.PlaySound("death")
        
        if (this.lives <= 0) {
            this.GameOver()
        } else {
            this.ResetFrog()
        }
    }
    
    static IncreaseDifficulty() {
        this.carsSpeed += 0.5
        this.logsSpeed += 0.3
        this.turtlesSpeed += 0.3
        
        ; Add more obstacles
        if (Mod(this.level, 3) = 0) {
            this.cars.Push({
                x: Random(0, this.gameWidth),
                y: 500 + Random(0, 100),
                speed: this.carsSpeed,
                width: 40,
                height: 20
            })
        }
    }
    
    static DrawGame() {
        if (!this.gameGui) {
            return
        }
        
        ; Update status display
        try {
            this.gameGui.Control["Text1"].Text := "Lives: " . this.lives
            this.gameGui.Control["Text2"].Text := "Score: " . this.score
            this.gameGui.Control["Text3"].Text := "Level: " . this.level
        } catch {
            ; Controls might not exist yet
        }
    }
    
    static GameOver() {
        this.gameRunning := false
        MsgBox("Game Over!`n`nFinal Score: " . this.score . "`nLevel Reached: " . this.level . "`n`nPress OK to play again.", "Frogger Game Over", "Icon!")
        this.Init()
    }
    
    static PlaySound(type) {
        if (!this.soundEnabled) {
            return
        }
        
        switch (type) {
            case "home":
                SoundBeep(1000, 200)
            case "death":
                SoundBeep(200, 500)
            case "move":
                SoundBeep(800, 50)
        }
    }
    
    static ShowInstructions(*) {
        instructionsText := "ðŸ¸ HOW TO PLAY FROGGER ðŸ¸`n`n"
        instructionsText .= "OBJECTIVE:`n"
        instructionsText .= "Help the frog cross the road and river to reach home!`n`n"
        instructionsText .= "CONTROLS:`n"
        instructionsText .= "â€¢ â†‘: Move UP`n"
        instructionsText .= "â€¢ â†“: Move DOWN`n"
        instructionsText .= "â€¢ â†: Move LEFT`n"
        instructionsText .= "â€¢ â†’: Move RIGHT`n"
        instructionsText .= "â€¢ SPACE: Start/Pause game`n"
        instructionsText .= "â€¢ R: Reset game`n`n"
        instructionsText .= "RULES:`n"
        instructionsText .= "â€¢ Avoid cars on the road`n"
        instructionsText .= "â€¢ Jump on logs to cross the river`n"
        instructionsText .= "â€¢ Jump on turtles (but they submerge!)`n"
        instructionsText .= "â€¢ Reach the top to score points`n"
        instructionsText .= "â€¢ You have 3 lives`n`n"
        instructionsText .= "SCORING:`n"
        instructionsText .= "â€¢ Reach home: 100 points Ã— level`n"
        instructionsText .= "â€¢ Each level increases difficulty`n`n"
        instructionsText .= "TIPS:`n"
        instructionsText .= "â€¢ Time your jumps carefully`n"
        instructionsText .= "â€¢ Watch turtle submerge patterns`n"
        instructionsText .= "â€¢ Use logs to cross the river safely`n`n"
        instructionsText .= "Press OK to start playing!"
        
        MsgBox(instructionsText, "Frogger Instructions", "Iconi")
    }
    
    static SetupHotkeys() {
        ; Frog movement
        Hotkey("Up", (*) => {
            if (FroggerGame.gameRu)nning) {
                FroggerGame.frogY -= 20
                FroggerGame.PlaySound("move")
            }
        }
        
        Hotkey("Down", (*) => {
            if (FroggerGame.gameRu)nning) {
                FroggerGame.frogY += 20
                FroggerGame.PlaySound("move")
            }
        }
        
        Hotkey("Left", (*) => {
            if (FroggerGame.gameRu)nning) {
                FroggerGame.frogX -= 20
                FroggerGame.PlaySound("move")
            }
        }
        
        Hotkey("Right", (*) => {
            if (FroggerGame.gameRu)nning) {
                FroggerGame.frogX += 20
                FroggerGame.PlaySound("move")
            }
        }
        
        ; Game controls
        Hotkey("Space", (*) => {
            if (FroggerGame.gameRu)nning) {
                FroggerGame.gameRunning := false
            } else {
                FroggerGame.StartGame()
            }
        }
        
        Hotkey("r", (*) => FroggerGame.I)nit()
        Hotkey("m", (*) => FroggerGame.ShowI)nstructions()
        
        ; Escape to close
        Hotkey("Escape", (*) => {
            FroggerGame.gameRu)nning := false
            if (FroggerGame.gameGui) {
                FroggerGame.gameGui.Close()
            }
        }
    }
}

; Hotkeys
^!Hotkey("f", (*) => FroggerGame.I)nit()
Hotkey("F6", (*) => FroggerGame.I)nit()

; Initialize
FroggerGame.Init()

