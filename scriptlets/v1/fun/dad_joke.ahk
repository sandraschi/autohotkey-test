#Include <_base>

class DadJoke extends Scriptlet {
    static name := "Dad Joke"
    static description := "Tells a random dad joke"
    static category := "Fun"
    static hotkey := "^!j"  ; Ctrl+Alt+J
    
    static Run() {
        jokes := [
            "Why don't scientists trust atoms? Because they make up everything!",
            "Did you hear about the mathematician who's afraid of negative numbers? He'll stop at nothing to avoid them.",
            "Why don't eggs tell jokes? They'd crack each other up.",
            "I only know 25 letters of the alphabet. I don't know y.",
            "What's the best thing about Switzerland? I don't know, but the flag is a big plus."
        ]
        
        Random rand, 1, jokes.Length
        MsgBox(jokes[rand], "Dad Joke")
        this.ShowStatus("Told a dad joke!")
    }
}

; Register the scriptlet
DadJoke.Init()
