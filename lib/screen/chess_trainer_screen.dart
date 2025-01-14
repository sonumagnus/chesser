import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessTrainerScreen extends StatefulWidget {
  const ChessTrainerScreen({super.key});

  @override
  State<ChessTrainerScreen> createState() => _ChessTrainerScreenState();
}

class _ChessTrainerScreenState extends State<ChessTrainerScreen> {
  static const double pieceSize = 48;
  static const Color highlightBorderColor = Colors.yellow;

  final List<String> squares = [
    for (var r in '87654321'.split(''))
      for (var c in 'abcdefgh'.split('')) '$c$r'
  ];

  final List<Widget> pieces = [
    WhiteKing(size: pieceSize),
    WhiteQueen(size: pieceSize),
    WhiteRook(size: pieceSize),
    WhiteBishop(size: pieceSize),
    WhiteKnight(size: pieceSize),
    WhitePawn(size: pieceSize),
    BlackKing(size: pieceSize),
    BlackQueen(size: pieceSize),
    BlackRook(size: pieceSize),
    BlackBishop(size: pieceSize),
    BlackKnight(size: pieceSize),
    BlackPawn(size: pieceSize),
  ];

  String? highlightedSquare;
  Widget? randomPiece;
  bool showSquareNames = false;
  bool showPieces = false;
  bool isReverseTraining = false;
  String? reverseSquareName;
  Widget? previousRandomPiece;
  String? previousHighlightedSquare;
  final Random random = Random();

  final List<int> timeOptions = [30, 60, 120, 300, 600];

  int selectedTime = 30;
  int timeRemaining = 30;
  int score = 0;
  bool isTimerRunning = false;
  Timer? timer;

  void _updateHighlightedState() {
    String newSquare;
    do {
      newSquare = squares[random.nextInt(squares.length)];
    } while (newSquare == previousHighlightedSquare);

    previousHighlightedSquare = newSquare;
    highlightedSquare = newSquare;
  }

  void highlightRandomSquareWithPiece() {
    setState(() {
      _updateHighlightedState();
      previousRandomPiece = randomPiece = pieces[random.nextInt(pieces.length)];
      incrementScore();
    });
  }

  void generateRandomSquareName() {
    setState(() {
      reverseSquareName = squares[random.nextInt(squares.length)];
    });
  }

  void toggleSquareNames() {
    setState(() {
      showSquareNames = !showSquareNames;
    });
  }

  void togglePieces() {
    setState(() {
      showPieces = !showPieces;
    });
  }

  void toggleTrainingMode() {
    setState(() {
      // Switch the mode
      isReverseTraining = !isReverseTraining;

      // Reset timer and score
      resetTimer();

      // Reset mode-specific states
      if (isReverseTraining) {
        // For reverse training, remove highlighted square and piece
        highlightedSquare = null;
        randomPiece = null;
        generateRandomSquareName(); // Generate the first square name for reverse mode
      } else {
        // For normal training, clear reverse square name and reset square/piece
        reverseSquareName = null;
        highlightedSquare = null;
        randomPiece = null;
      }
    });
  }

  void handleSquareClick(String square) {
    if (isReverseTraining && square == reverseSquareName) {
      setState(() {
        incrementScore(); // Increment score and start timer if needed
      });
      generateRandomSquareName();
    }
  }

  void incrementScore() {
    if (!isTimerRunning) {
      startTimer(); // Start timer on first score
    }
    score++;
  }

  // Timer Management
  void startTimer() {
    isTimerRunning = true;
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          if (timeRemaining > 0) {
            timeRemaining--;
          } else {
            endSession();
          }
        });
      },
    );
  }

  void pauseTimer() {
    isTimerRunning = false;
    timer?.cancel();
  }

  void resetTimer() {
    pauseTimer();
    setState(() {
      timeRemaining = selectedTime; // Use selected time control
      score = 0; // Reset score
    });
  }

  void endSession() {
    pauseTimer();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Time's Up!"),
        content: Text("Your Score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetTimer();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chess Trainer"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: resetTimer,
            icon: const Icon(Icons.restart_alt),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: timeOptions.map((time) {
                bool isSelected = time == selectedTime;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                      resetTimer(); // Reset timer with the new time control
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      time ~/ 60 > 0 ? "${time ~/ 60}m" : "${time}s",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Fixed Box for Reverse Training Square Name
          Container(
            height: 50, // Fixed height to avoid layout shifts
            alignment: Alignment.center,
            child: isReverseTraining && reverseSquareName != null
                ? Text(
                    reverseSquareName!,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                : const SizedBox.shrink(), // Empty space if no square name
          ),
          // Time, Score, and Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Time: ${timeRemaining.toString().padLeft(2, '0')}s",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: toggleSquareNames,
                    icon: Icon(
                      showSquareNames ? Icons.visibility : Icons.visibility_off,
                    ),
                    tooltip: showSquareNames
                        ? "Hide Square Names"
                        : "Show Square Names",
                  ),
                  IconButton(
                    onPressed: togglePieces,
                    icon: Icon(
                      showPieces ? Icons.extension : Icons.extension_off,
                    ),
                    tooltip: showPieces ? "Hide Pieces" : "Show Pieces",
                  ),
                  IconButton(
                    onPressed: toggleTrainingMode,
                    icon: Icon(
                      isReverseTraining ? Icons.shuffle : Icons.repeat,
                    ),
                    tooltip: isReverseTraining
                        ? "Switch to Normal Training"
                        : "Switch to Reverse Training",
                  ),
                ],
              ),
              // Score Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Score: ${score.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          // Chessboard
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Chessboard(
                squares: squares,
                highlightedSquare: highlightedSquare,
                randomPiece: randomPiece,
                showSquareNames: showSquareNames,
                showPieces: showPieces,
                isReverseTraining: isReverseTraining,
                onSquareClick: handleSquareClick,
                highlightBorderColor: highlightBorderColor,
              ),
            ),
          ),
          if (!isReverseTraining)
            Container(
              margin: const EdgeInsets.only(bottom: 28),
              height: 80,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: highlightRandomSquareWithPiece,
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Next"),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Chessboard extends StatelessWidget {
  final List<String> squares;
  final String? highlightedSquare;
  final Widget? randomPiece;
  final bool showSquareNames;
  final bool showPieces;
  final bool isReverseTraining;
  final void Function(String) onSquareClick;
  final Color highlightBorderColor;

  const Chessboard({
    required this.squares,
    required this.highlightedSquare,
    required this.randomPiece,
    required this.showSquareNames,
    required this.showPieces,
    required this.isReverseTraining,
    required this.onSquareClick,
    required this.highlightBorderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: squares.length,
      itemBuilder: (context, index) {
        String square = squares[index];
        bool isHighlighted = highlightedSquare == square;

        return GestureDetector(
          onTap: () => onSquareClick(square),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: _getSquareColor(square),
              border: (isHighlighted && !showPieces)
                  ? Border.all(
                      color: highlightBorderColor,
                      width: 3.0,
                    )
                  : null,
            ),
            child: Center(
              child: (showPieces && isHighlighted)
                  ? randomPiece
                  : (showSquareNames
                      ? Text(
                          square,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null),
            ),
          ),
        );
      },
    );
  }

  Color _getSquareColor(String square) {
    int file = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int rank = int.parse(square[1]);
    return (file + rank) % 2 != 0 ? Colors.grey : Colors.white;
  }
}

class ControlsAboveBoard extends StatelessWidget {
  final bool showSquareNames;
  final VoidCallback onToggleSquareNames;
  final bool showPieces;
  final VoidCallback onTogglePieces;
  final bool isReverseTraining;
  final VoidCallback onToggleTrainingMode;

  const ControlsAboveBoard({
    required this.showSquareNames,
    required this.onToggleSquareNames,
    required this.showPieces,
    required this.onTogglePieces,
    required this.isReverseTraining,
    required this.onToggleTrainingMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onToggleSquareNames,
          icon: Icon(
            showSquareNames ? Icons.visibility : Icons.visibility_off,
          ),
          tooltip: showSquareNames ? "Hide Square Names" : "Show Square Names",
        ),
        IconButton(
          onPressed: onTogglePieces,
          icon: Icon(
            showPieces ? Icons.extension : Icons.extension_off,
          ),
          tooltip: showPieces ? "Hide Pieces" : "Show Pieces",
        ),
        IconButton(
          onPressed: onToggleTrainingMode,
          icon: Icon(
            isReverseTraining ? Icons.shuffle : Icons.repeat,
          ),
          tooltip: isReverseTraining
              ? "Switch to Normal Training"
              : "Switch to Reverse Training",
        ),
      ],
    );
  }
}
