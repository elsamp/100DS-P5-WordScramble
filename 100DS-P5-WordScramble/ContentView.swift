//
//  ContentView.swift
//  100DS-P5-WordScramble
//
//  Created by Erica Sampson on 2024-07-16.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var allWords = [String]()
    @State private var rootWord = "word"
    @State private var newGuess = ""
    @State private var score = 0
    @FocusState private var guessFieldIsFocused: Bool
    
    //Error Messages
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        NavigationStack {
            List {
                Section {

                    ZStack {
                        
                        Button() {
                            restartGame()
                        } label: {
                            Image(systemName: "arrowshape.forward.circle.fill")
                                .font(.title)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Text(rootWord)
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(20)
                        
                    }
                    
                    Text("Score: \(score)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .foregroundColor(.green)
                    
                }
                
                Section {
                    TextField("Enter your guess", text: $newGuess)
                        .textInputAutocapitalization(.never)
                        .focused($guessFieldIsFocused)
                }
                
                Section("Found Words: \(usedWords.count)") {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle("Word Scramble")
            .navigationBarTitleDisplayMode(.inline)
            .onSubmit(addNewWord)
            .onAppear() {
                startGame()
                guessFieldIsFocused = true
            }
            .alert(errorTitle, isPresented: $showingError){
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newGuess.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Already Used!", message: "Be more original")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not a Word", message: "That's not an actual word ...")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Not Possible", message: "Not possible to make that word from \(rootWord)")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            updateScore()
        }

        newGuess = ""
        guessFieldIsFocused = true
    }
    
    func updateScore(){

        var earnedPoints = 0
        
        for word in usedWords {
            earnedPoints += 1
            
            if word.count == 8 {
                earnedPoints += 8
            } else if word.count > 5 {
                earnedPoints += 5
            } else if word.count > 3 {
                earnedPoints += 3
            }
        }
        
        score = earnedPoints

    }
    
    //MARK: Word Validation
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool{
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }
    
    func wordError(title: String, message: String){
        errorMessage = message
        errorTitle = title
        showingError = true
    }
    
    //MARK: Game Setup
    func startGame() {
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            
            if let startWords = try? String(contentsOf: startWordsUrl) {
                allWords = startWords.components(separatedBy: "\n")
                rootWord = newRootWord()
                return
            }
        }
        
        fatalError("could not load start.txt from the bundle")
    }
    
    func restartGame() {
        usedWords = []
        rootWord = newRootWord()
        newGuess = ""
        score = 0
    }
    
    func newRootWord() -> String {
        
        return allWords.randomElement() ?? "silkworm"
        
    }
}

#Preview {
    ContentView()
}
