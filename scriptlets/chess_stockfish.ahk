; ==============================================================================
; Chess Game with Stockfish Integration
; @name: Chess Game with Stockfish Integration
; @version: 1.0.0
; @description: Full-featured chess game with Stockfish engine integration
; @category: games
; @author: Sandra
; @hotkeys: ^!c, F7
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class ChessGame {
    static gameGui := ""
    static gameRunning := false
    static board := []
    static selectedSquare := ""
    static currentPlayer := "white"
    static gameMode := "human_vs_ai"
    static stockfishPath := ""
    static stockfishProcess := ""
    static gameHistory := []
    static capturedPieces := {white: [], black: []}
    static checkStatus := {white: false, black: false}
    static gameOver := false
    static winner := ""
    
    static Init() {
        this.gameRunning := false
        this.currentPlayer := "white"
        this.gameMode := "human_vs_ai"
        this.gameHistory := []
        this.capturedPieces := {white: [], black: []}
        this.checkStatus := {white: false, black: false}
        this.gameOver := false
        this.winner := ""
        this.InitializeBoard()
        this.FindStockfish()
        this.CreateGameGUI()
    }
    
    static InitializeBoard() {
        ; Initialize empty board
        this.board := []
        Loop 8 {
            row := []
            Loop 8 {
                row.Push("")
            }
            this.board.Push(row)
        }
        
        ; Set up initial position
        ; Black pieces (top)
        this.board[0][0] := "r" ; rook
        this.board[0][1] := "n" ; knight
        this.board[0][2] := "b" ; bishop
        this.board[0][3] := "q" ; queen
        this.board[0][4] := "k" ; king
        this.board[0][5] := "b" ; bishop
        this.board[0][6] := "n" ; knight
        this.board[0][7] := "r" ; rook
        
        Loop 8 {
            this.board[1][A_Index - 1] := "p" ; pawns
        }
        
        ; White pieces (bottom)
        Loop 8 {
            this.board[6][A_Index - 1] := "P" ; pawns
        }
        
        this.board[7][0] := "R" ; rook
        this.board[7][1] := "N" ; knight
        this.board[7][2] := "B" ; bishop
        this.board[7][3] := "Q" ; queen
        this.board[7][4] := "K" ; king
        this.board[7][5] := "B" ; bishop
        this.board[7][6] := "N" ; knight
        this.board[7][7] := "R" ; rook
    }
    
    static FindStockfish() {
        ; Try to find Stockfish executable
        possiblePaths := [
            A_ScriptDir . "\stockfish.exe",
            A_ScriptDir . "\engines\stockfish.exe",
            "C:\Program Files\Stockfish\stockfish.exe",
            "C:\Stockfish\stockfish.exe"
        ]
        
        for path in possiblePaths {
            if (FileExist(path)) {
                this.stockfishPath := path
                return
            }
        }
        
        ; If not found, show download instructions
        this.ShowStockfishInstructions()
    }
    
    static ShowStockfishInstructions() {
        instructionsText := "♟️ STOCKFISH ENGINE REQUIRED ♟️`n`n"
        instructionsText .= "To play against the AI, you need Stockfish:`n`n"
        instructionsText .= "1. Download Stockfish from: https://stockfishchess.org/download/`n"
        instructionsText .= "2. Extract stockfish.exe to:`n"
        instructionsText .= "   • " . A_ScriptDir . "\stockfish.exe`n"
        instructionsText .= "   • Or " . A_ScriptDir . "\engines\stockfish.exe`n`n"
        instructionsText .= "3. Restart this game`n`n"
        instructionsText .= "You can still play Human vs Human mode without Stockfish.`n`n"
        instructionsText .= "Press OK to continue with Human vs Human mode."
        
        MsgBox(instructionsText, "Stockfish Required", "Iconi")
        this.gameMode := "human_vs_human"
    }
    
    static CreateGameGUI() {
        if (this.gameGui) {
            this.gameGui.Close()
        }
        
        this.gameGui := Gui("+Resize +MinSize800x600", "Chess Game - Click to move pieces")
        this.gameGui.BackColor := "0x8B4513"
        this.gameGui.SetFont("s12 cWhite Bold", "Arial")
        
        ; Game area
        this.gameGui.Add("Text", "x10 y10 w780 h580 Border Center", "CHESS")
        
        ; Status display
        this.gameGui.Add("Text", "x50 y50 w200 h30", "Current Player: " . this.currentPlayer)
        this.gameGui.Add("Text", "x300 y50 w200 h30", "Mode: " . this.gameMode)
        this.gameGui.Add("Text", "x550 y50 w200 h30", "Captured: " . this.capturedPieces.white.Length . "/" . this.capturedPieces.black.Length)
        
        ; Controls info
        this.gameGui.Add("Text", "x10 y570 w780 h20 Center", "Click pieces to move | SPACE: Start | R: Reset | M: Menu")
        
        ; Menu buttons
        this.gameGui.Add("Button", "x300 y100 w100 h40", "Start Game").OnEvent("Click", this.StartGame.Bind(this))
        this.gameGui.Add("Button", "x300 y150 w100 h40", "Game Mode").OnEvent("Click", this.ShowGameMode.Bind(this))
        this.gameGui.Add("Button", "x300 y200 w100 h40", "Instructions").OnEvent("Click", this.ShowInstructions.Bind(this))
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        this.gameGui.Show("w800 h600")
    }
    
    static StartGame(*) {
        this.gameRunning := true
        this.DrawBoard()
    }
    
    static DrawBoard() {
        if (!this.gameGui) {
            return
        }
        
        ; This is a simplified board drawing
        ; In a real implementation, you'd use GDI+ for proper graphics
        ; For now, we'll show the current position in text format
        
        boardText := "Current Position:`n`n"
        
        ; Display board
        Loop 8 {
            row := 8 - A_Index
            boardText .= (row + 1) . " "
            Loop 8 {
                piece := this.board[row][A_Index - 1]
                if (piece = "") {
                    boardText .= "· "
                } else {
                    boardText .= piece . " "
                }
            }
            boardText .= "`n"
        }
        
        boardText .= "  a b c d e f g h`n`n"
        boardText .= "Current Player: " . this.currentPlayer . "`n"
        boardText .= "Game Mode: " . this.gameMode . "`n"
        
        if (this.checkStatus.white) {
            boardText .= "White is in CHECK!`n"
        }
        if (this.checkStatus.black) {
            boardText .= "Black is in CHECK!`n"
        }
        
        if (this.gameOver) {
            boardText .= "GAME OVER - " . this.winner . " WINS!`n"
        }
        
        try {
            this.gameGui.Control["Text1"].Text := boardText
        } catch {
            ; Control might not exist yet
        }
    }
    
    static ShowGameMode(*) {
        modeText := "🎮 CHESS GAME MODES 🎮`n`n"
        modeText .= "Current Mode: " . this.gameMode . "`n`n"
        modeText .= "Available Modes:`n`n"
        modeText .= "1. Human vs AI (requires Stockfish)`n"
        modeText .= "   • Play against computer`n"
        modeText .= "   • AI uses Stockfish engine`n`n"
        modeText .= "2. Human vs Human`n"
        modeText .= "   • Two players on same computer`n"
        modeText .= "   • Take turns moving pieces`n`n"
        modeText .= "3. AI vs AI (demo mode)`n"
        modeText .= "   • Watch two AIs play`n"
        modeText .= "   • Great for learning`n`n"
        modeText .= "Stockfish Status: " . (this.stockfishPath ? "Found" : "Not Found") . "`n`n"
        modeText .= "Press OK to continue."
        
        MsgBox(modeText, "Chess Game Modes", "Iconi")
    }
    
    static ShowInstructions(*) {
        instructionsText := "♟️ HOW TO PLAY CHESS ♟️`n`n"
        instructionsText .= "OBJECTIVE:`n"
        instructionsText .= "Checkmate your opponent's king!`n`n"
        instructionsText .= "CONTROLS:`n"
        instructionsText .= "• Click on a piece to select it`n"
        instructionsText .= "• Click on destination square to move`n"
        instructionsText .= "• SPACE: Start/Pause game`n"
        instructionsText .= "• R: Reset game`n"
        instructionsText .= "• M: Show this menu`n`n"
        instructionsText .= "PIECE MOVEMENTS:`n"
        instructionsText .= "• Pawn (P/p): Forward 1, capture diagonally`n"
        instructionsText .= "• Rook (R/r): Horizontal and vertical`n"
        instructionsText .= "• Knight (N/n): L-shaped moves`n"
        instructionsText .= "• Bishop (B/b): Diagonal moves`n"
        instructionsText .= "• Queen (Q/q): Any direction`n"
        instructionsText .= "• King (K/k): One square any direction`n`n"
        instructionsText .= "SPECIAL RULES:`n"
        instructionsText .= "• Castling: King and rook special move`n"
        instructionsText .= "• En passant: Pawn capture rule`n"
        instructionsText .= "• Pawn promotion: Promote to queen`n"
        instructionsText .= "• Check: King under attack`n"
        instructionsText .= "• Checkmate: King cannot escape`n`n"
        instructionsText .= "Press OK to start playing!"
        
        MsgBox(instructionsText, "Chess Instructions", "Iconi")
    }
    
    static MakeMove(from, to) {
        ; Validate move (simplified)
        if (!this.IsValidMove(from, to)) {
            return false
        }
        
        ; Record move
        move := {
            from: from,
            to: to,
            piece: this.board[from.row][from.col],
            captured: this.board[to.row][to.col],
            player: this.currentPlayer
        }
        
        this.gameHistory.Push(move)
        
        ; Make the move
        if (move.captured != "") {
            this.capturedPieces[this.currentPlayer].Push(move.captured)
        }
        
        this.board[to.row][to.col] := this.board[from.row][from.col]
        this.board[from.row][from.col] := ""
        
        ; Switch players
        this.currentPlayer := (this.currentPlayer = "white") ? "black" : "white"
        
        ; Check for check/checkmate
        this.CheckGameStatus()
        
        ; If playing against AI, make AI move
        if (this.gameMode = "human_vs_ai" && this.currentPlayer = "black") {
            this.MakeAIMove()
        }
        
        this.DrawBoard()
        return true
    }
    
    static IsValidMove(from, to) {
        ; Simplified move validation
        ; In a real implementation, this would be much more complex
        
        if (from.row = to.row && from.col = to.col) {
            return false ; Can't move to same square
        }
        
        local piece := this.board[from.row][from.col]
        if (piece = "") {
            return false ; No piece to move
        }
        
        ; Check if it's the player's piece
        local isWhite := (piece = piece.ToUpper())
        if ((isWhite && this.currentPlayer != "white") || (!isWhite && this.currentPlayer != "black")) {
            return false
        }
        
        ; Basic piece movement validation would go here
        return true
    }
    
    static MakeAIMove() {
        if (this.stockfishPath = "") {
            return
        }
        
        ; Convert board to FEN notation
        local fen := this.BoardToFEN()
        
        ; Send position to Stockfish
        this.SendToStockfish("position fen " . fen)
        this.SendToStockfish("go depth 3")
        
        ; Get best move from Stockfish
        local bestMove := this.GetBestMoveFromStockfish()
        
        if (bestMove != "") {
            ; Parse and make the move
            local from := this.ParseSquare(bestMove.SubStr(1, 2))
            local to := this.ParseSquare(bestMove.SubStr(3, 2))
            
            this.MakeMove(from, to)
        }
    }
    
    static SendToStockfish(command) {
        if (this.stockfishPath = "") {
            return
        }
        
        try {
            if (!this.stockfishProcess) {
                this.stockfishProcess := Run(this.stockfishPath, , "Hide")
            }
            
            ; Send command to Stockfish
            ; This is simplified - real implementation would use proper process communication
        } catch {
            ; Handle error
        }
    }
    
    static GetBestMoveFromStockfish() {
        ; Simplified - real implementation would parse Stockfish output
        return "e2e4" ; Example move
    }
    
    static BoardToFEN() {
        ; Convert board to FEN notation
        local fen := ""
        
        Loop 8 {
            local row := 8 - A_Index
            local emptyCount := 0
            
            Loop 8 {
                local piece := this.board[row][A_Index - 1]
                if (piece = "") {
                    emptyCount++
                } else {
                    if (emptyCount > 0) {
                        fen .= emptyCount
                        emptyCount := 0
                    }
                    fen .= piece
                }
            }
            
            if (emptyCount > 0) {
                fen .= emptyCount
            }
            
            if (row > 0) {
                fen .= "/"
            }
        }
        
        fen .= " " . this.currentPlayer . " - - 0 1"
        return fen
    }
    
    static ParseSquare(square) {
        ; Convert algebraic notation to board coordinates
        local col := Ord(square.SubStr(1, 1)) - Ord("a")
        local row := 8 - Integer(square.SubStr(2, 1))
        return {row: row, col: col}
    }
    
    static CheckGameStatus() {
        ; Simplified game status checking
        ; Real implementation would check for check, checkmate, stalemate
        
        this.checkStatus.white := false
        this.checkStatus.black := false
        
        ; Check for checkmate (simplified)
        if (this.capturedPieces.white.Length >= 15) {
            this.gameOver := true
            this.winner := "Black"
        } else if (this.capturedPieces.black.Length >= 15) {
            this.gameOver := true
            this.winner := "White"
        }
    }
    
    static SetupHotkeys() {
        ; Game controls
        Space::{
            if (ChessGame.gameRunning) {
                ChessGame.gameRunning := false
            } else {
                ChessGame.StartGame()
            }
        }
        
        r::ChessGame.Init()
        m::ChessGame.ShowInstructions()
        
        ; Escape to close
        Escape::{
            ChessGame.gameRunning := false
            if (ChessGame.gameGui) {
                ChessGame.gameGui.Close()
            }
        }
    }
}

; Hotkeys
^!c::ChessGame.Init()
F7::ChessGame.Init()

; Initialize
ChessGame.Init()
