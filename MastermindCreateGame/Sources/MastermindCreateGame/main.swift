import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Data models
struct CreateGameResponse: Codable {
    let game_id: String
}

struct GuessRequest: Codable {
    let game_id: String
    let guess: String
}

struct GuessResponse: Codable {
    let black: Int
    let white: Int
}

struct APIError: Codable {
    let error: String
}

class MastermindGame {
    private let baseURL = "https://mastermind.darkube.app"
    private var gameID: String?
    // added
    private var turn_number = 0
    private var total_turn_number = 10
    
    func start() {
        // print("""
        // Mastermind Game Commands:
        // 1. start - Create new game
        // 2. guess XXXX - Submit guess (4 digits 1-6)
        // 3. delete - End current game
        // 4. exit - Quit program
        // """)
        print("""
        🎮 Mastermind Game 🎮
            
            Rules:
            - Guess a 4-digit code (digits 1-6)
            - After each guess, you'll get feedback:
            🟢 (B): Correct digit in correct position
            ⚪️ (W): Correct digit in wrong position
            - You have 10 attempts to guess the code
                
            Commands:
            1. start - Create new game
            2. guess XXXX - Submit guess (4 digits 1-6)
            3. delete - End current game
            4. exit - Quit program
        """)
        
        while true {
            print("\n> ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
            
            switch input.lowercased() {
            case "start":
                createNewGame()
            case "delete":
                deleteGame()
            case "exit":
                exit(0)
            case let cmd where cmd.hasPrefix("guess "):
                let guess = String(cmd.dropFirst(6))
                if isValid(guess: guess) {
                    submitGuess(guess: guess)
                } else {
                    print("Invalid guess. Must be 4 digits (1-6)")
                }
            default:
                print("Invalid command")
            }
        }
    }
    
    private func isValid(guess: String) -> Bool {
        return guess.count == 4 && guess.allSatisfy { "123456".contains($0) }
    }

    private func createNewGame() {
        // added 
        if gameID != nil {
            print("You have a started game, please first finish it or delete it then create another game.")
            return
        }

        guard let url = URL(string: "\(baseURL)/game") else {
            print("Error: Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                let data = data else {
                print("Error: Invalid server response")
                return
            }
            
            // Accept both 200 (OK) and 201 (Created)
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                do {
                    let gameResponse = try JSONDecoder().decode(CreateGameResponse.self, from: data)
                    self.gameID = gameResponse.game_id
                    print("Game created successfully. ID: \(gameResponse.game_id)")
                    // added
                    self.turn_number = 0
                } catch {
                    print("Error decoding response: \(error)")
                }
            } else {
                print("Error: Server returned status \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Server response: \(responseString)")
                }
            }
        }
        task.resume()
    }
        

    private func deleteGame() {
        guard let gameID = gameID else {
            print("Error: No active game to delete")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/game/\(gameID)") else {
            print("Error: Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid server response")
                return
            }
            
            if httpResponse.statusCode == 204 {
                print("Game deleted successfully")
                self.gameID = nil
                // added 
                self.turn_number = 0
            } else {
                print("Error: Delete failed with status \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    
    private func submitGuess(guess: String) {
        guard let gameID = gameID else {
            print("Error: No active game. Use 'start' first")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/guess") else {
            print("Error: Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = GuessRequest(game_id: gameID, guess: guess)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    print("Error: Invalid server response")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    do {
                        let result = try JSONDecoder().decode(GuessResponse.self, from: data)
                        // print("Result: \(result.black) correct, \(result.white) correct but wrong position")
                        // added
                        print("Result: \(result.black) B, \(result.white) W")
                        self.turn_number = self.turn_number + 1
                        if result.black == 4 {
                            print("You won! Congratulations!")
                            // exit(0)
                            // added 
                            self.turn_number = 0
                            self.gameID = nil
                        } else {
                            if self.turn_number == self.total_turn_number {
                                print("You lose the game!")
                                self.turn_number = 0
                                self.gameID = nil
                            }
                        }
                    } catch {
                        print("Error decoding response: \(error)")
                    }
                } else {
                    print("Error: Server returned status \(httpResponse.statusCode)")
                }
            }
            task.resume()
        } catch {
            print("Error creating request: \(error)")
        }
    }
}

let game = MastermindGame()
game.start()