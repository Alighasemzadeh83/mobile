# Mastermind Terminal Game in Swift

This is a command-line implementation of the classic Mastermind game written in Swift.

## Overview

Mastermind is a code-breaking game where the player tries to guess a secret 4-digit code. Each digit ranges from 1 to 6. After each guess, the program provides feedback in the form of:

- **B (Black Peg):** Number of digits guessed correctly in both value and position.
- **W (White Peg):** Number of digits guessed correctly in value but in the wrong position.

### Example:

- Secret code: `1234`  
- Guess: `1235` → Output: `BBB` (3 black pegs)  
- Guess: `4321` → Output: `WWWW` (4 white pegs)

## Features

- Written entirely in Swift and runs in the terminal.
- Validates user input and handles errors gracefully.
- Allows the player to exit the game anytime by typing `exit`.
- Provides clear and simple user prompts and feedback.

## Setup and Running

To set up the Swift package and run the game, follow these steps in your terminal:

```bash
# Initialize a new Swift executable package
swift package init --type executable

# Build the project
swift build

# Run the executable
swift run
