import SwiftUI

// Main content view
struct ContentView: View {
    @State private var friendsLeft = ["Birking1", "Cat1", "Frenchie1"]
    private var friendImages: [String: Image] {
        Dictionary(uniqueKeysWithValues: friendsLeft.map { ($0, Image($0)) })
    }
    @State private var offsets: [CGSize]
    @State private var currentQuestionIndex = 0
    @State private var scores: [String: Int] = [:]
    @State private var isGameOver = false
    @State private var winner: String = ""
    @State private var winnerImage: Image? = nil
    
    //variables for the mini challenges
    @State private var loserName: String?
    @State private var miniChallenge: [String] = [
        "Do pushups with good form until timer expires",
        "Sit on someone's lap and sing a chorus of any song until timer expires",
        "Make eye-contact with someone with water in your mouth until timer expires",
        "Say the entire alphabet in reverse order until timer expires",
        "Let a friend post a story/ status on social media for you",
        "Text 'I miss you' to an ex friend or partner"
    ]

    let questions = [
        "Who is most likely to get famous for something wrong?",
        "Who is most likely to get cancelled?",
        "Who is most likely to succeed?"
    ]

    init() {
        self._offsets = State(initialValue: Array(repeating: .zero, count: 3))
    }

    var body: some View {
        VStack {
            if isGameOver {
                Text("Game Over!")
                    .font(.largeTitle)
                    .padding()

                if let winnerImage = winnerImage {
                    winnerImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding()
                }

                Text("Winner: \(winner)")
                    .font(.title)
                    .foregroundColor(.blue)
            } else {
                Text(questions[currentQuestionIndex])
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)

                ZStack {
                    ForEach(friendsLeft.indices.reversed(), id: \.self) { index in
                        FriendCardView(
                            image: friendImages[friendsLeft[index]] ?? Image("placeholder"),
                            offset: $offsets[index],
                            onRemove: { isYes in
                                handleSwipe(for: friendsLeft[index], isYes: isYes)
                            }
                        )
                    }
                }
            }
            Spacer()
        }
        .padding()
    }

    func handleSwipe(for friend: String, isYes: Bool) {
        if isYes {
            scores[friend, default: 0] += 1
            print("Updated Scores: \(scores)")
        }

        if let index = friendsLeft.firstIndex(of: friend) {
            friendsLeft.remove(at: index)
            offsets.remove(at: index)
        }

        if friendsLeft.isEmpty {
            currentQuestionIndex += 1
            if currentQuestionIndex < questions.count {
                resetFriends()
            } else {
                endGame()
            }
        }
    }

    func resetFriends() {
        friendsLeft = ["Birking1", "Cat1", "Frenchie1"]
        offsets = Array(repeating: .zero, count: friendsLeft.count)
    }

    func findWinner() -> (name: String, image: Image?)? {
        guard !scores.isEmpty else { return nil }

        // Determine the friend(s) with the highest score
        let maxScore = scores.values.max() ?? 0
        let topScorers = scores.filter { $0.value == maxScore }.keys

        if let winnerName = topScorers.first {
            print("Winner Found: \(winnerName)")
            return (name: winnerName, image: friendImages[winnerName])
        }

        return nil
    }
    
    func challengeLoser() {
        //guard condition else - if statement is false, execute the else statement
        guard let winner = findWinner()?.name else { return } //return early if no winner found
        for friend in friendsLeft {
            loserName = friend
            break //first remaining friend will be the loser by default
        }
        
        guard let loser = loserName else { return }
        print("Loser: \(loser)")
        //generate a random integer within the range of the array declared indices
        let randomChallengeIndex = Int.random(in: 0..<miniChallenge.count)
        let assignedChallenge = miniChallenge[randomChallengeIndex]
        //alert displayed
        print("Assigned Challenge to \(loser): \(assignedChallenge)")
    }

    func endGame() {
        isGameOver = true

        if let winnerData = findWinner() {
            winner = winnerData.name
            winnerImage = winnerData.image
            print("Game Over - Winner: \(winner)")
        } else {
            winner = "No Winner"
            winnerImage = nil
            print("Game Over - No Winner")
        }
        challengeLoser() //function called for loser challenges
    }
}

struct FriendCardView: View {
    var image: Image
    @Binding var offset: CGSize
    var onRemove: (Bool) -> Void // Passes swipe direction (true for yes, false for no)

    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 300, height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.offset = gesture.translation
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            if self.offset.width > 100 {
                                print("Swiped yes")
                                self.offset = CGSize(width: 1000, height: 0)
                                onRemove(true) // Right swipe
                            } else if self.offset.width < -100 {
                                print("Swiped no")
                                self.offset = CGSize(width: -1000, height: 0)
                                onRemove(false) // Left swipe
                            } else {
                                self.offset = .zero
                            }
                        }
                    }
            )
    }
}
