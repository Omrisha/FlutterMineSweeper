import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/BoardSquare.dart';

enum ImageType {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  bomb,
  facingDown,
  flagged
}

class GameActivity extends StatefulWidget {
  GameActivity({Key key}) : super(key: key);

  @override
  _GameActivityState createState() => _GameActivityState();
}

class _GameActivityState extends State<GameActivity> {
  int rowCount = 18;
  int columnCount = 18;

  // Grid of squares
  List<List<BoardSquare>> board;

  // Clicked squares
  List<bool> openedSquares;

  // Flagged - means added flag by long press
  List<bool> flaggedSquares;

  int bombProbability = 3;
  int maxProbability = 15;

  int bombCount = 0;
  int squaresLeft;

  @override
  void initState() {
    super.initState();

    _initialiseGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            color: Colors.grey,
            height: 60.0,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    _initialiseGame();
                  },
                  child: CircleAvatar(
                    child: Icon(
                      Icons.tag_faces,
                      color: Colors.black,
                      size: 40.0
                    ),
                    backgroundColor: Colors.yellowAccent,
                  ),
                )
              ],
            )
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount
            ),
            itemBuilder: (context, position) {
              int rowNumber = (position / columnCount).floor();
              int columnNumber = (position % columnCount);

              Image image;

              if (openedSquares[position] == false) {
                if (flaggedSquares[position] == true) {
                  image = getImage(ImageType.flagged);
                } else {
                  image = getImage(ImageType.facingDown);
                }
              } else {
                if (board[rowNumber][columnNumber].hasBomb) {
                  image = getImage(ImageType.bomb);
                } else {
                  image = getImage(
                    getImageTypeFromNumber(
                      board[rowNumber][columnNumber].bombsAround
                    )
                  );
                }
              }

              return InkWell(
                onTap: () {
                  if (board[rowNumber][columnNumber].hasBomb) {
                    _handleGameOver();
                  }
                  if (board[rowNumber][columnNumber].bombsAround == 0) {
                    _handleTap(rowNumber, columnNumber);
                  } else {
                    setState(() {
                      openedSquares[position] = true;
                      squaresLeft = squaresLeft - 1;
                    });
                  }

                  if (squaresLeft <= bombCount) {
                    _handleWin();
                  }
                },
                onLongPress: () {
                  if (openedSquares[position] == false) {
                    setState(() {
                      flaggedSquares[position] = true;
                    });
                  }
                },
                splashColor: Colors.grey,
                child: Container(
                  color: Colors.grey,
                  child: image,
                ),
              );
            },
            itemCount: rowCount * columnCount,
          )
        ],
      ),
    );
  }

  void _initialiseGame() {
    board = List.generate(rowCount, (i) {
      return List.generate(columnCount, (j) {
        return BoardSquare();
      });
    });

    openedSquares = List.generate(rowCount * columnCount, (index) {
      return false;
    });

    flaggedSquares = List.generate(rowCount * columnCount, (index) {
      return false;
    });

    bombCount = 0;
    squaresLeft = rowCount * columnCount;

    // generating bombs
    Random random = new Random();
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < columnCount; j++) {
        int randomNumber = random.nextInt(maxProbability);
        if (randomNumber < bombProbability) {
          board[i][j].hasBomb = true;
          bombCount++;
        }
      }
    }

    // assign number according to bombs
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < columnCount; j++) {
        if (i > 0 && j > 0) {
          if (board[i - 1][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i > 0) {
          if (board[i - 1][j].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i > 0 && j < columnCount - 1) {
          if (board[i - 1][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (j > 0) {
          if (board[i][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (j < columnCount - 1) {
          if (board[i][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < rowCount - 1) {
          if (board[i + 1][j].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < rowCount - 1 && j < columnCount - 1) {
          if (board[i + 1][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }
      }
    }
    setState(() {});
  }

  void _handleTap(int i, int j) {
    int position = (i * columnCount) + j;

    openedSquares[position] = true;
    squaresLeft = squaresLeft - 1;

    if (i > 0) {
      if (!board[i - 1][j].hasBomb && 
      openedSquares[((i - 1) * columnCount) + j] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i - 1, j);
        }
      }
    }

    if (j > 0) {
      if (!board[i][j - 1].hasBomb && 
      openedSquares[(i * columnCount) + j - 1] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i, j - 1);
        }
      }
    }

    if (j < columnCount - 1) {
      if (!board[i][j + 1].hasBomb && 
      openedSquares[(i * columnCount) + j + 1] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i, j + 1);
        }
      }
    }

    if (i < rowCount - 1) {
      if (!board[i + 1][j].hasBomb && 
      openedSquares[((i + 1) * columnCount) + j] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i + 1, j);
        }
      }
    }

    setState(() {
      
    });
  }

  void _handleGameOver() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over!"),
          content: Text("You stepped on a mine!"),
          actions: [
            FlatButton(
              onPressed: (){
                _initialiseGame();
                Navigator.pop(context);
              },
              child: Text("Play Again"),
            )
          ],
        );
      }
    );
  }

  void _handleWin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Congrates!"),
          content: Text("You Win!"),
          actions: [
            FlatButton(
              onPressed: (){
                _initialiseGame();
                Navigator.pop(context);
              },
              child: Text("Play Again"),
            )
          ],
        );
      }
    );
  }

  Image getImage(ImageType type) {
    switch(type) {
      case ImageType.zero:
        return Image.asset('images/0.png');
      case ImageType.one:
        return Image.asset('images/1.png');
      case ImageType.two:
        return Image.asset('images/2.png');
      case ImageType.three:
        return Image.asset('images/3.png');
      case ImageType.four:
        return Image.asset('images/4.png');
      case ImageType.five:
        return Image.asset('images/5.png');
      case ImageType.six:
        return Image.asset('images/6.png');
      case ImageType.seven:
        return Image.asset('images/7.png');
      case ImageType.eight:
        return Image.asset('images/8.png');
      case ImageType.bomb:
        return Image.asset('images/bomb.png');
      case ImageType.facingDown:
        return Image.asset('images/facingDown.png');
      case ImageType.flagged:
        return Image.asset('images/flagged.png');
      default:
        return null;
    }
  }

  ImageType getImageTypeFromNumber(int number) {
    switch(number) {
      case 0:
        return ImageType.zero;
      case 1:
        return ImageType.one;
      case 2:
        return ImageType.two;
      case 3:
        return ImageType.three;
      case 4:
        return ImageType.four;
      case 5:
        return ImageType.five;
      case 6:
        return ImageType.six;
      case 7:
        return ImageType.seven;
      case 8:
        return ImageType.eight;
      default:
        return null;
    }
  }
}
