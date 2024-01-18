import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

enum Direction { up, down, left, right }

class _SnakeGamePageState extends State<SnakeGamePage> {
  int row = 20, column = 20;
  List<int> borderList = [];
  List<int> snakePosition = [];
  int snakeHead = 0;
  int score = 0; // Initialize score to 0
  late Direction direction;
  late int foodPosition;
  Timer? snakeTimer; // Declare the timer

  @override
  void initState() {
    startGame();
    super.initState();
  }

  void startGame() {
    makeBorder();
    generateFood();
    direction = Direction.right;
    snakePosition = [45, 44, 43];
    snakeHead = snakePosition.first;
    snakeTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      updateSnake();
      if (checkCollision()) {
        timer.cancel();
        showGameOverDialog();
      }
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.withOpacity(0.2),
          title: const Text("Game Over !",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.red,fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text("Restart",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Colors.red),),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    makeBorder();
    generateFood();
    direction = Direction.right;
    snakePosition = [45, 44, 43];
    snakeHead = snakePosition.first;
    score = 0;
    snakeTimer?.cancel(); // Cancel the previous timer
    startGame();
  }

  bool checkCollision() {
    // If snake collides with border
    if (borderList.contains(snakeHead)) return true;
    // If snake collides with itself
    if (snakePosition.sublist(1).contains(snakeHead)) return true;
    return false;
  }

  void generateFood() {
    foodPosition = Random().nextInt(row * column);
    if (borderList.contains(foodPosition) || snakePosition.contains(foodPosition)) {
      generateFood();
    }
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          snakePosition.insert(0, snakeHead - column);
          break;
        case Direction.down:
          snakePosition.insert(0, snakeHead + column);
          break;
        case Direction.right:
          snakePosition.insert(0, snakeHead + 1);
          break;
        case Direction.left:
          snakePosition.insert(0, snakeHead - 1);
          break;
      }
    });

    if (snakeHead == foodPosition) {
      score++;
      generateFood();
    } else {
      snakePosition.removeLast();
    }

    snakeHead = snakePosition.first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xff212121),
        body: Column(
          children: [
            Expanded(child: _buildGameView()), _buildGameControls()],
        ),
      ),
    );
  }

  Widget _buildGameView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: column),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: fillBoxColor(index),
          ),
        );
      },
      itemCount: row * column,
    );
  }

  Widget _buildGameControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Score : $score",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.red,fontSize: 15),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (direction != Direction.up) direction = Direction.up;
                },
                icon: const Icon(Icons.arrow_circle_up),
                iconSize: 60,
                color: Colors.white,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  if (direction != Direction.left) direction = Direction.left;
                },
                icon: const Icon(Icons.arrow_circle_left_outlined),
                iconSize: 60,
                color: Colors.white,
              ),
              const SizedBox(width: 50),
              IconButton(
                onPressed: () {
                  if (direction != Direction.right) direction = Direction.right;
                },
                icon: const Icon(Icons.arrow_circle_right_outlined),
                iconSize: 60,
                color: Colors.white,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (direction != Direction.down) direction = Direction.down;
                },
                icon: const Icon(Icons.arrow_circle_down_outlined),
                iconSize: 60,
                color: Colors.white,
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              // Toggle pause and resume functionality
              if (snakeTimer?.isActive ?? false) {
                snakeTimer?.cancel();
              } else {
                startGame();
              }
              setState(() {}); // Trigger a rebuild to update the icon
            },
            icon: Icon(
              snakeTimer?.isActive ?? false
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline, // Use play icon when paused
              size: 75,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }



  Color fillBoxColor(int index) {
    if (borderList.contains(index))
      return Colors.blueGrey;
    else {
      if (snakePosition.contains(index)) {
        if (snakeHead == index) {
          return Colors.red;
        } else {
          return Colors.red.withOpacity(0.5);
        }
      } else {
        if (index == foodPosition) {
          return Colors.orangeAccent;
        }
      }
    }
    return Colors.grey.withOpacity(0.3);
  }

  makeBorder() {
    for (int i = 0; i < column; i++) {
      if (!borderList.contains(i)) borderList.add(i);
    }
    for (int i = 0; i < row * column; i = i + column) {
      if (!borderList.contains(i)) borderList.add(i);
    }
    for (int i = column - 1; i < row * column; i = i + column) {
      if (!borderList.contains(i)) borderList.add(i);
    }
    for (int i = (row * column) - column; i < row * column; i = i + 1) {
      if (!borderList.contains(i)) borderList.add(i);
    }
  }
}
