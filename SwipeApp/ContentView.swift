import SwiftUI

struct ContentView: View {
    // MARK: - State Variables
    @State private var friendsLeft: [String] = ["Frenchie1", "Cat1", "Birking1"]
    @State private var friendImages: [String: Image] = [
        "Frenchie1": Image("Frenchie1"),
        "Cat1": Image("Cat1"),
        "Birking1": Image("Birking1")
    ]
    @State private var scores: [String: Int] = [:]
    @State private var offsets: [CGSize] = [CGSize](repeating: .zero, count: 3)
    @State private var currentQuestionIndex = 0
    @State private var isGameOver = false
    @State private var isGameStart = false
    @State private var showRules = false
    @State private var playerNames: [String] = ["Player 1", "Player 2", "Player 3", "Player 4", "Player 5", "Player 6"]
    @State private var playerPhotos: [String: Image] = [:]
    @State private var winner = ""
    @State private var winnerImage: Image? = nil
    @State private var loserName: String? = nil
    @State private var assignedChallenge: String? = nil

    // MARK: - Constants
    let questions = [
        "Who is most likely to host the best party?",
        "Who is most likely to get canceled socially?",
        "Who is most likely to get arrested for something wrong?",
        "Who here do you think objectively has least moral values?",
        "Who can't keep secrets?"
    ]
    let challenges = [
        "Rap any chorus or take a shot",
        "Do 10 push-ups with proper form or get slapped by the strongest person in the room",
        "Dance on a table for 30 seconds with no music or take 2 shots",
        "Text any ex relationship 'I miss you' or take 3 shots"
    ]

    // MARK: - Body
    var body: some View {
        VStack {
            if isGameOver {
                GameOverView(winner: winner, winnerImage: winnerImage, loserName: loserName, assignedChallenge: assignedChallenge)
            } else if isGameStart {
                GameView(playerNames: playerNames,
                         playerPhotos: playerPhotos,
                         questions: questions,
                         friendsLeft: $friendsLeft,
                         friendImages: $friendImages,
                         scores: $scores,
                         currentQuestionIndex: $currentQuestionIndex,
                         isGameOver: $isGameOver,
                         handleSwipe: handleSwipe,
                         onGameOver: determineWinner)
            } else {
                StartScreen(
                    playerNames: $playerNames,
                    playerPhotos: $playerPhotos,
                    onStart: { isGameStart = true },
                    onShowRules: { showRules = true }
                )
            }
            Spacer()
        }
        //popup added which was previously not implemented
        .sheet(isPresented: $showRules) {
            VStack {
                Text("Game Rules")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Swipe right for yes, left for no. Points are calculated to find the most boring and adventurous people. Loser will be assigned a random challenge.")
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Close") {
                    showRules = false
                }
                .padding()
                .background(Color.red)
                .foregroundColor(Color.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    // MARK: - Helper Functions
    private func handleSwipe(for friend: String, isYes: Bool) {
        if let index = friendsLeft.firstIndex(of: friend) {
            friendsLeft.remove(at: index)
            offsets.remove(at: index)

            if isYes {
                scores[friend, default: 0] += 1
            } else {
                scores[friend, default: 0] -= 1
            }

            //offsets = [CGSize](repeating: .zero, count: friendsLeft.count)

            if friendsLeft.isEmpty {
                if currentQuestionIndex < questions.count - 1 {
                    currentQuestionIndex += 1
                    friendsLeft = Array(friendImages.keys)
                    resetForNextQuestion()
                } else {
                    determineWinner()
                    //determineWinner()
                    //challengeLoser()
                }
            }
        }
    }

    func resetForNextQuestion() {
        friendsLeft = Array(friendImages.keys)
        offsets = Array(repeating: .zero, count: friendsLeft.count)
    }
    
    func challengeLoser() {
        if let minScore = scores.values.min() {
            let lowestScore = scores.filter { $0.value == minScore }.keys
            loserName = lowestScore.randomElement()
            assignedChallenge = challenges.randomElement()
        }
    }
    func determineWinner() {
        if let topScorer = scores.max(by: { $0.value < $1.value }) {
            winner = topScorer.key
            winnerImage = friendImages[winner]
            challengeLoser()
            isGameOver = true
        }
    }

}

// MARK: - Subviews
struct StartScreen: View {
    @Binding var playerNames: [String]
    @Binding var playerPhotos: [String: Image]
    var onStart: () -> Void
    var onShowRules: () -> Void

    // predefined avatars
    let avatarOptions = ["Avatar1", "Avatar2", "Avatar3", "Avatar4"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Boring? Drink.")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Set up players and get started!")
                .font(.headline)
                .padding()
            ForEach(0..<playerNames.count, id: \.self) { index in
                HStack {
                    TextField("Player \(index + 1) Name", text: $playerNames[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                    
                    // Avatar Selection
                    Menu {
                        ForEach(avatarOptions, id: \.self) { avatar in
                            Button(action: {
                                playerPhotos[playerNames[index]] = Image(avatar)
                            }) {
                                Text(avatar)
                            }
                        }
                    } label: {
                        if let image = playerPhotos[playerNames[index]] {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1
                        }
                    }
                    Button(action: { choosePhoto(for: index) }) {
                        if let image = playerPhotos[playerNames[index]] {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Button(action: onShowRules) {
                Text("View Game Rules")
                    .font(.headline)
                    .padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: onStart) {
                Text("Start Game")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private func choosePhoto(for index: Int) {
        playerPhotos[playerNames[index]] = Image(systemName: "person.crop.circle.fill")
    }
}

struct GameOverView: View {
    var winner: String
    var winnerImage: Image?
    var loserName: String?
    var assignedChallenge: String?

    var body: some View {
        VStack {
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
                .foregroundColor(.green)
            if let loserName = loserName, let challenge = assignedChallenge {
                Text("Loser: \(loserName)")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top)
                Text("Challenge: \(challenge)")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

struct GameView: View {
    var playerNames: [String]
    var playerPhotos: [String: Image]
    var questions: [String]
    @Binding var friendsLeft: [String]
    @Binding var friendImages: [String: Image]
    @Binding var scores: [String: Int]
    @Binding var currentQuestionIndex: Int
    @Binding var isGameOver: Bool
    var handleSwipe: (String, Bool) -> Void
    var onGameOver: () -> Void
    
    //added offsets variable
    //CGSize is a struct in Swift repping a width & height value
    //here we use it to track the X & Y displacement of each swipe
    //each card gets an offset to store and update offset independently
    @State private var offsets: [CGSize] = Array(repeating: .zero, count: 3)
    var body: some View {
        VStack {
            if currentQuestionIndex < questions.count {
                Text(questions[currentQuestionIndex])
                    .font(.headline)
                    .padding()
                ZStack {
                    ForEach(friendsLeft.indices, id: \.self) { index in
                        if let image = friendImages[friendsLeft[index]] {
                            FriendCardView(
                                image: image,
                                //offset zero made no swipes
                                offset: $offsets[index],
                                onRemove: { isYes in
                                    handleSwipe(friendsLeft[index], isYes)
                                }
                            )
                            .zIndex(Double(friendsLeft.count - index))
                        }
                    }
                }
            } else {
                Text("Calculating results...")
            }
        }
    }
}


struct FriendCardView: View {
    var image: Image
    @Binding var offset: CGSize
    var onRemove: (Bool) -> Void

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 400)
            .cornerRadius(20)
            .shadow(radius: 5)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        if offset.width > 100 {
                            onRemove(true)
                        } else if offset.width < -100 {
                            onRemove(false)
                        }
                        offset = .zero
                        //reset position after removal
                    }
            )
            .animation(.spring(), value: offset)
    }
}

// MARK: - Previews
struct SwipeAppView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
