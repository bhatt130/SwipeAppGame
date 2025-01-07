import SwiftUI

struct ContentView: View {
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
    @State private var winner = ""
    @State private var winnerImage: Image? = nil
    @State private var loserName: String? = nil
    @State private var assignedChallenge: String? = nil

    let questions = ["Who is most likely to host the best party?", "Who is most likely to bring snacks?"]
    let challenges = ["Sing a song", "Do 10 push-ups", "Dance for 30 seconds"]

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
            } else {
                Text(questions[currentQuestionIndex])
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)

                ZStack {
                    ForEach(friendsLeft.indices.reversed(), id: \ .self) { index in
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
        if let index = friendsLeft.firstIndex(of: friend) {
            friendsLeft.remove(at: index)
            offsets.remove(at: index)

            if isYes {
                scores[friend, default: 0] += 1
            //for left swipe loser
            } else {
                scores[friend, default: 0] -= 1
            }

            // Reinitialize the offsets to match the new count of friendsLeft
            offsets = [CGSize](repeating: .zero, count: friendsLeft.count)

            if friendsLeft.isEmpty {
                // loop through for the next question in array
                //check if last questions reached first
                if currentQuestionIndex < questions.count - 1 {
                    currentQuestionIndex += 1
                    // new function to reset
                    resetforNextQuestion()
                } else {
                    determineWinner()
                    challengeLoser()
                }
            }
        }
    }

    func resetforNextQuestion() {
        // all the key (friends) are restored for the next question
        //.keys returns the collection of all the keys in the dictionary
        friendsLeft = Array(friendImages.keys)
        //new array of CGSize objects of 2d size to store the dragging offsets
        //all elements in array initialized to zero first
        //.count helps count from the 'toy' mess. Counts num of toys or friends
        //to put in each box. The boxes are like offsets.
        offsets = [CGSize](repeating: .zero, count: friendsLeft.count)
    }
    func determineWinner() {
        //scores is a dictionary and the key-value matching pair
        //with the highest score is found
        //$0 (1st arg) vs $1 (2nd arg) and finds max between them
        //replaced long form of:
        //scores.ax(by: { pair1, pair 2 in pair1.value < pair2.value })
        //if max exists, assign key value to topScorer
        //if let codn will return safely if scores is empty
        if let topScorer = scores.max(by: { $0.value < $1.value }) {
            winner = topScorer.key
            //corresponding image from dictionary found
            winnerImage = friendImages[winner]
            isGameOver = true
        }
    }

    func challengeLoser() {
        //handling new case where there are multiple losers
        //1 loser will be chosen at random for the challenge
        if let minScore = scores.values.min() {
            let lowestScore = scores.filter { $0.value == minScore}.keys
            loserName = lowestScore.randomElement()
            print("Loser: \(loserName)")
            assignedChallenge = challenges.randomElement()
        }
        /*if let lowestScorer = scores.min(by: { $0.value < $1.value }) {
            loserName = lowestScorer.key
            assignedChallenge = challenges.randomElement()
        }*/
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
                        //offset = .zero
                    }
            )
            .animation(.spring(), value: offset)
    }
}

struct SwipeAppView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
