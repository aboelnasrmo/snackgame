import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Snake Game')),
        body: const SnakeBoard(),
      ),
    );
  }
}

class SnakeBoard extends StatefulWidget {
  const SnakeBoard({super.key});

  @override
  _SnakeBoardState createState() => _SnakeBoardState();
}

class _SnakeBoardState extends State<SnakeBoard> {
  final int rows = 20;
  final int columns = 20;
  final int pixelSize = 20;

  List<List<int>> grid = [];
  List<Point> snake = [];
  Point? food;
  String direction = 'right';
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initGame();
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      updateGame();
    });
  }

  void initGame() {
    grid = List.generate(rows, (_) => List.generate(columns, (_) => 0));
    snake = [Point(rows ~/ 2, columns ~/ 2)];
    generateFood();
  }

  void generateFood() {
    Random random = Random();
    int x = random.nextInt(rows);
    int y = random.nextInt(columns);

    while (snake.contains(Point(x, y))) {
      x = random.nextInt(rows);
      y = random.nextInt(columns);
    }

    food = Point(x, y);
  }

  void updateGame() {
    setState(() {
      Point newHead = getNextHead();
      if (outOfBounds(newHead) || snake.contains(newHead)) {
        timer!.cancel();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Game Over'),
              content: Text('Score: ${snake.length - 1}'),
              actions: [
                TextButton(
                  onPressed: () {
                    initGame();
                    Navigator.of(context).pop();
                    timer = Timer.periodic(const Duration(milliseconds: 200),
                        (timer) {
                      updateGame();
                    });
                  },
                  child: const Text('Restart'),
                ),
              ],
            );
          },
        );
      } else {
        snake.insert(0, newHead);

        if (newHead == food) {
          generateFood();
        } else {
          snake.removeLast();
        }
      }
    });
  }

  Point getNextHead() {
    Point head = snake.first;
    switch (direction) {
      case 'up':
        return Point(head.x - 1, head.y);
      case 'down':
        return Point(head.x + 1, head.y);
      case 'left':
        return Point(head.x, head.y - 1);
      case 'right':
        return Point(head.x, head.y + 1);
      default:
        return head;
    }
  }

  bool outOfBounds(Point point) {
    return point.x < 0 || point.x >= rows || point.y < 0 || point.y >= columns;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (direction != 'up' && details.delta.dy > 0) {
          direction = 'down';
        } else if (direction != 'down' && details.delta.dy < 0) {
          direction = 'up';
        }
      },
      onHorizontalDragUpdate: (details) {
        if (direction != 'left' && details.delta.dx > 0) {
          direction = 'right';
        } else if (direction != 'right' && details.delta.dx < 0) {
          direction = 'left';
        }
      },
      child: Container(
        color: Colors.black,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1,
          ),
          itemCount: rows * columns,
          itemBuilder: (context, index) {
            int x = index ~/ columns;
            int y = index % columns;

            if (snake.contains(Point(x, y))) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              );
            } else if (food == Point(x, y)) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
