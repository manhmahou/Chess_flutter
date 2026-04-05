import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final String mode;
  final String side;

  const GameScreen({super.key, required this.mode, this.side = 'random'});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Bàn cờ 8x8, mỗi ô chứa thông tin quân cờ
  List<List<String>> board = [
    ['♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜'],
    ['♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟'],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙'],
    ['♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'],
  ];

  late String playerSide;
  late String opponentSide;
  String currentTurn = 'white';
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'puzzle') {
      board = [
        ['♜', '', '♝', '♛', '♚', '♝', '♞', '♜'],
        ['♟', '♟', '♟', '', '', '', '♟', '♟'],
        ['', '', '', '', '♟', '', '', ''],
        ['', '', '♘', '', '', '♟', '', ''],
        ['', '', '', '', '♙', '', '', ''],
        ['', '', '', '♙', '', '', '', ''],
        ['♙', '♙', '', '♙', '', '♙', '♙', '♙'],
        ['♖', '', '', '♕', '♔', '', '', '♖'],
      ];
      playerSide = 'white';
      opponentSide = 'black';
      currentTurn = 'white';
    } else if (widget.mode == 'friend') {
      playerSide = 'white';
      opponentSide = 'black';
      currentTurn = 'white';
    } else if (widget.mode == 'online') {
      playerSide = DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 'white' : 'black';
      opponentSide = playerSide == 'white' ? 'black' : 'white';
      currentTurn = 'white';
    } else {
      playerSide = widget.side == 'random' ? (DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 'white' : 'black') : widget.side;
      opponentSide = playerSide == 'white' ? 'black' : 'white';
      currentTurn = 'white';
    }
  }

  bool _isWhitePiece(String piece) => '♙♖♘♗♕♔'.contains(piece);

  Color _sideColor(String side) => side == 'white' ? Colors.white : Colors.black87;
  String _sideLabel(String side) => side == 'white' ? 'Trắng' : 'Đen';

  Color _activeColor(bool isActive) => isActive ? Colors.lightBlueAccent.withAlpha(204) : Colors.blueGrey.withAlpha(77);

  String _titleForMode() {
    switch (widget.mode) {
      case 'friend':
        return 'Chơi với bạn trên cùng máy';
      case 'puzzle':
        return 'Giải câu đố cờ';
      case 'online':
        return 'Đối thủ online (${_sideLabel(opponentSide)}) vs Bạn (${_sideLabel(playerSide)})';
      default:
        return 'Máy tính (${_sideLabel(opponentSide)}) vs Bạn (${_sideLabel(playerSide)})';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForMode()),
        backgroundColor: const Color(0xFF1E3A5F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF0F1419)],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSideInfoPanel(
              widget.mode == 'friend' ? 'Bạn 2' : widget.mode == 'puzzle' ? 'Thế cờ' : 'Máy',
              _sideLabel(opponentSide),
              opponentSide,
            ),
            _buildBoardArea(),
            _buildSideInfoPanel(
              widget.mode == 'friend' ? 'Bạn 1' : 'Bạn',
              _sideLabel(playerSide),
              playerSide,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideInfoPanel(String name, String colorLabel, String side) {
    final bool isActive = currentTurn == side;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: _activeColor(isActive),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? Colors.yellow : Colors.white70, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: _sideColor(side)),
              const SizedBox(width: 6),
              Text(
                colorLabel,
                style: TextStyle(fontSize: 15, color: _sideColor(side)),
              ),
              const SizedBox(width: 12),
              if (isActive)
                const Text('Đến lượt', style: TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoardArea() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double boardSize = constraints.maxWidth * 0.96;
          final double maxBoard = boardSize > 520 ? 520 : boardSize;
          final double squareSize = maxBoard / 8;

          return Container(
            width: maxBoard,
            height: maxBoard,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(31),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24, width: 1.4),
            ),
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    int row = index ~/ 8;
                    int col = index % 8;
                    bool isWhite = (row + col) % 2 == 0;
                    bool isSelected = selectedRow == row && selectedCol == col;
                    return GestureDetector(
                      onTap: () => _onSquareTap(row, col),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.yellow.withAlpha(128)
                              : isWhite
                                  ? const Color(0xFFF0D9B5)
                                  : const Color(0xFFB58863),
                        ),
                      ),
                    );
                  },
                ),
                ..._buildPieces(squareSize),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPieces(double squareSize) {
    final double fontSize = squareSize * 0.82;
    List<Widget> pieces = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board[row][col].isNotEmpty) {
          final piece = board[row][col];
          pieces.add(Positioned(
            left: col * squareSize,
            top: row * squareSize,
            width: squareSize,
            height: squareSize,
            child: GestureDetector(
              onTap: () => _onPieceTap(row, col),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  piece,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: _isWhitePiece(piece) ? Colors.white : Colors.black,
                    shadows: [
                      const Shadow(color: Colors.black45, offset: Offset(1, 1), blurRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
          ));
        }
      }
    }
    return pieces;
  }

  void _onSquareTap(int row, int col) {
    setState(() {
      if (selectedRow != null && selectedCol != null) {
        // Di chuyển quân cờ đến ô mới (đơn giản, không kiểm tra luật)
        board[row][col] = board[selectedRow!][selectedCol!];
        board[selectedRow!][selectedCol!] = '';
        selectedRow = null;
        selectedCol = null;

        // Đổi lượt sau khi di chuyển
        currentTurn = currentTurn == 'white' ? 'black' : 'white';
      }
    });
  }

  void _onPieceTap(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }
}