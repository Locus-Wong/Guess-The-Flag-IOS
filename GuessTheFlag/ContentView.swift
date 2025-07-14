//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Locus Wong on 2025-06-23.
//

import SwiftUI

struct FlagImage: View {
    var countries: [String]
    var number: Int
    
    var body: some View{
        Image(countries[number])
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

struct Title : ViewModifier{
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.green.gradient)
    }
}

extension View{
    func titleStyle() -> some View{
        modifier(Title())
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    
    @State private var currentScore = 0
    @State private var tappedFlagNumber: Int? = nil
    
    @State private var currentRound = 1
    
    @State private var animationAmount = 0.0
    
    var body: some View {
        ZStack{
            RadialGradient(
                stops: [
                    .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                    .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
                ],
                center: .top,
                startRadius: 200,
                endRadius: 700
            )
            .ignoresSafeArea()
            VStack{
                Spacer()
                
                Text("Guess the Flag")
                    .titleStyle()
                VStack(spacing: 15){
                    
                    VStack{
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            tappedFlagNumber = number
                            flagTapped()
                        } label: {
                            FlagImage(countries: countries, number: number)
                                .overlay(
                                    // Show red overlay only if this was tapped and it's wrong
                                    tappedFlagNumber == number && number != correctAnswer ?
                                    Color.red.opacity(0.85) : Color.clear // Show red or nothing
                                        
                                )
                                .clipShape(.capsule)
                                .shadow(radius: 5)
                        }
                        .rotation3DEffect(.degrees(number == tappedFlagNumber ? animationAmount : 0), axis: (x: 0, y:1 , z: 0))
                        .opacity(tappedFlagNumber == nil ? 1 : number == tappedFlagNumber ? 1 : 0.25)
                        
                    }
                    
                }.frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 30))
                
                Spacer()
                Spacer()
                
                Text("Score: \(currentScore)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .alert(scoreTitle, isPresented: $showingScore){
                if currentRound <= 8 {
                    Button("Continue", action: askQuestion)
                } else {
                    Button("Restart the Game", action: resetGame)
                }
            } message: {
                if currentRound <= 8 {
                    if scoreTitle == "Correct"{
                        Text("Your score is \(currentScore)")
                    } else {
                        Text("Wrong! That's the flag of \(countries[tappedFlagNumber ?? 0])")
                    }
                } else{
                    Text("Your total score of this round is \(currentScore)")
                }
            }
            .padding()
        }
    }
    
    func flagTapped(){
        withAnimation{
            animationAmount += 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            if tappedFlagNumber == correctAnswer{
                scoreTitle = "Correct"
                currentScore += 1
            } else {
                scoreTitle = "Wrong"
            }
            currentRound += 1
            showingScore = true
        }
    }
    
    func askQuestion(){
        countries.shuffle()
        tappedFlagNumber = nil
        correctAnswer = Int.random(in: 0...2)
    }
    
    func resetGame(){
        currentRound = 1
        currentScore = 0
        askQuestion()
    }
}

#Preview {
    ContentView()
}
