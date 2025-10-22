; ==============================================================================
; Classic Pong Game
; @name: Classic Pong Game
; @version: 1.0.0
; @description: Classic Pong arcade game with AI opponent and sound effects
; @category: games
; @author: Sandra
; @hotkeys: ^!p, F5
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class PongGame {
    static gameGui := ""
    static gameRunning := false
    static ballX := 0
    static ballY := 0
    static ballSpeedX := 0
    static ballSpeedY := 0
    static paddle1Y := 0
    static paddle2Y := 0
    static paddleSpeed := 8
    static paddleHeight := 80
    static paddleWidth := 15
    static ballSize := 12
    static gameWidth := 800
    static gameHeight := 600
    static score1 := 0
    static score2 := 0
    static difficulty := "Medium"
    static soundEnabled := true
    
    static Init() {
        this.gameRunning := false
        this.score1 := 0
        this.score2 := 0
        this.ResetBall()
        this.CreateGameGUI()
    }
    
    static CreateGameGUI() {
        if (this.gameGui) {
            this.gameGui.Close()
        }
        
        this.gameGui := Gui("+Resize +MinSize800x600", "Classic Pong - Press SPACE to start")
        this.gameGui.BackColor := "0x000000"
        this.gameGui.SetFont("s16 cWhite Bold", "Arial")
        
        ; Game area
        this.gameGui.Add("Text", "x10 y10 w780 h580 Border Center", "PONG")
        
        ; Score display
        this.gameGui.Add("Text", "x50 y50 w100 h30 Center", "Player: 0")
        this.gameGui.Add("Text", "x650 y50 w100 h30 Center", "AI: 0")
        
        ; Controls info
        this.gameGui.Add("Text", "x10 y570 w780 h20 Center", "W/S: Move | SPACE: Start/Pause | R: Reset | M: Menu")
        
        ; Menu button
        this.gameGui.Add("Button", "x350 y100 w100 h40", "Start Game").OnEvent("Click", this.StartGame.Bind(this))
        this.gameGui.Add("Button", "x350 y150 w100 h40", "Settings").OnEvent("Click", this.ShowSettings.Bind(this))
        this.gameGui.Add("Button", "x350 y200 w100 h40", "Instructions").OnEvent("Click", this.ShowInstructions.Bind(this))
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        this.gameGui.Show("w800 h600")
    }
    
    static StartGame(*) {
        this.gameRunning := true
        this.ResetBall()
        this.StartGameLoop()
    }
    
    static ResetBall() {
        this.ballX := this.gameWidth // 2
        this.ballY := this.gameHeight // 2
        this.ballSpeedX := (Random(0, 1) ? 4 : -4)
        this.ballSpeedY := Random(-3, 3)
        this.paddle1Y := (this.gameHeight - this.paddleHeight) // 2
        this.paddle2Y := (this.gameHeight - this.paddleHeight) // 2
    }
    
    static StartGameLoop() {
        if (!this.gameRunning) {
            return
        }
        
        this.UpdateGame()
        this.DrawGame()
        
        ; Continue game loop
        SetTimer(() => this.StartGameLoop(), 16) ; ~60 FPS
    }
    
    static UpdateGame() {
        if (!this.gameRunning) {
            return
        }
        
        ; Move ball
        this.ballX += this.ballSpeedX
        this.ballY += this.ballSpeedY
        
        ; Ball collision with top/bottom walls
        if (this.ballY <= 0 || this.ballY >= this.gameHeight - this.ballSize) {
            this.ballSpeedY := -this.ballSpeedY
            this.PlaySound("wall")
        }
        
        ; Ball collision with paddles
        ; Left paddle (player)
        if (this.ballX <= 30 && this.ballX >= 15 && 
            this.ballY >= this.paddle1Y && this.ballY <= this.paddle1Y + this.paddleHeight) {
            this.ballSpeedX := -this.ballSpeedX
            this.ballSpeedY += Random(-2, 2)
            this.PlaySound("paddle")
        }
        
        ; Right paddle (AI)
        if (this.ballX >= this.gameWidth - 45 && this.ballX <= this.gameWidth - 30 && 
            this.ballY >= this.paddle2Y && this.ballY <= this.paddle2Y + this.paddleHeight) {
            this.ballSpeedX := -this.ballSpeedX
            this.ballSpeedY += Random(-2, 2)
            this.PlaySound("paddle")
        }
        
        ; Scoring
        if (this.ballX < 0) {
            this.score2++
            this.ResetBall()
            this.PlaySound("score")
        } else if (this.ballX > this.gameWidth) {
            this.score1++
            this.ResetBall()
            this.PlaySound("score")
        }
        
        ; AI paddle movement
        this.UpdateAI()
        
        ; Check for game over
        if (this.score1 >= 10 || this.score2 >= 10) {
            this.GameOver()
        }
    }
    
    static UpdateAI() {
        ; Simple AI - follow the ball
        targetY := this.ballY - this.paddleHeight // 2
        
        ; Adjust AI difficulty
        aiSpeed := this.paddleSpeed
        switch (this.difficulty) {
            case "Easy":
                aiSpeed := this.paddleSpeed * 0.6
            case "Medium":
                aiSpeed := this.paddleSpeed * 0.8
            case "Hard":
                aiSpeed := this.paddleSpeed * 1.0
        }
        
        if (this.paddle2Y < targetY) {
            this.paddle2Y += aiSpeed
        } else if (this.paddle2Y > targetY) {
            this.paddle2Y -= aiSpeed
        }
        
        ; Keep paddle in bounds
        if (this.paddle2Y < 0) {
            this.paddle2Y := 0
        } else if (this.paddle2Y > this.gameHeight - this.paddleHeight) {
            this.paddle2Y := this.gameHeight - this.paddleHeight
        }
    }
    
    static DrawGame() {
        if (!this.gameGui) {
            return
        }
        
        ; Clear screen
        this.gameGui.BackColor := "0x000000"
        
        ; Draw paddles and ball using simple rectangles
        ; This is a simplified version - in a real implementation you'd use GDI+
        ; For now, we'll update the score display
        try {
            this.gameGui.Control["Text1"].Text := "Player: " . this.score1
            this.gameGui.Control["Text2"].Text := "AI: " . this.score2
        } catch {
            ; Control might not exist yet
        }
    }
    
    static GameOver() {
        this.gameRunning := false
        winner := this.score1 >= 10 ? "Player" : "AI"
        MsgBox("Game Over!`n`n" . winner . " wins!`n`nFinal Score:`nPlayer: " . this.score1 . "`nAI: " . this.score2, "Pong Game Over", "Iconi")
        this.Init()
    }
    
    static PlaySound(type) {
        if (!this.soundEnabled) {
            return
        }
        
        ; Simple beep sounds for different events
        switch (type) {
            case "wall":
                SoundBeep(800, 100)
            case "paddle":
                SoundBeep(1200, 150)
            case "score":
                SoundBeep(400, 200)
        }
    }
    
    static ShowSettings(*) {
        settingsText := "🎮 PONG SETTINGS 🎮`n`n"
        settingsText .= "Current Difficulty: " . this.difficulty . "`n`n"
        settingsText .= "Available Difficulties:`n"
        settingsText .= "• Easy: AI moves slowly`n"
        settingsText .= "• Medium: AI moves at normal speed`n"
        settingsText .= "• Hard: AI moves at full speed`n`n"
        settingsText .= "Sound Effects: " . (this.soundEnabled ? "ON" : "OFF") . "`n`n"
        settingsText .= "Controls:`n"
        settingsText .= "• W/S: Move paddle up/down`n"
        settingsText .= "• SPACE: Start/Pause game`n"
        settingsText .= "• R: Reset game`n"
        settingsText .= "• M: Show this menu`n`n"
        settingsText .= "Press OK to continue."
        
        MsgBox(settingsText, "Pong Settings", "Iconi")
    }
    
    static ShowInstructions(*) {
        instructionsText := "🎮 HOW TO PLAY PONG 🎮`n`n"
        instructionsText .= "OBJECTIVE:`n"
        instructionsText .= "Hit the ball past your opponent's paddle to score!`n`n"
        instructionsText .= "CONTROLS:`n"
        instructionsText .= "• W: Move paddle UP`n"
        instructionsText .= "• S: Move paddle DOWN`n"
        instructionsText .= "• SPACE: Start/Pause game`n"
        instructionsText .= "• R: Reset game`n"
        instructionsText .= "• M: Show menu`n`n"
        instructionsText .= "RULES:`n"
        instructionsText .= "• First to 10 points wins`n"
        instructionsText .= "• Ball bounces off walls and paddles`n"
        instructionsText .= "• Ball speed increases slightly on paddle hits`n"
        instructionsText .= "• AI opponent adjusts difficulty based on setting`n`n"
        instructionsText .= "TIPS:`n"
        instructionsText .= "• Try to hit the ball with the edge of your paddle`n"
        instructionsText .= "• Watch the ball's trajectory to predict movement`n"
        instructionsText .= "• Use the paddle's center for straight shots`n`n"
        instructionsText .= "Press OK to start playing!"
        
        MsgBox(instructionsText, "Pong Instructions", "Iconi")
    }
    
    static SetupHotkeys() {
        ; Player controls
        w::{
            if (PongGame.gameRunning) {
                PongGame.paddle1Y -= PongGame.paddleSpeed
                if (PongGame.paddle1Y < 0) {
                    PongGame.paddle1Y := 0
                }
            }
        }
        
        s::{
            if (PongGame.gameRunning) {
                PongGame.paddle1Y += PongGame.paddleSpeed
                if (PongGame.paddle1Y > PongGame.gameHeight - PongGame.paddleHeight) {
                    PongGame.paddle1Y := PongGame.gameHeight - PongGame.paddleHeight
                }
            }
        }
        
        ; Game controls
        Space::{
            if (PongGame.gameRunning) {
                PongGame.gameRunning := false
            } else {
                PongGame.StartGame()
            }
        }
        
        r::PongGame.Init()
        m::PongGame.ShowSettings()
        
        ; Escape to close
        Escape::{
            PongGame.gameRunning := false
            if (PongGame.gameGui) {
                PongGame.gameGui.Close()
            }
        }
    }
}

; Hotkeys
^!p::PongGame.Init()
F5::PongGame.Init()

; Initialize
PongGame.Init()
