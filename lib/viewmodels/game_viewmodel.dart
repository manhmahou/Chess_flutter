import 'package:flutter/material.dart';
import '../model/game_pieces_color.dart';
import '../model/game_position.dart';

class GameViewModel extends ChangeNotifier {
  late List<List<Piece?>> board;
  PieceColor currentTurn = PieceColor.white;
  Position? selectedPosition;
  PieceColor? winner;

  GameViewModel() {
    resetGame();
  }

  void resetGame() {
    currentTurn = PieceColor.white;
    selectedPosition = null;
    winner = null;
    _initializeBoard();
    notifyListeners();
  }

  void _initializeBoard() {
    board = List.generate(8, (_) => List.filled(8, null));
    const backRankTypes = [
      PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen,
      PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook
    ];

    for (int col = 0; col < 8; col++) {
      board[0][col] = Piece(type: backRankTypes[col], color: PieceColor.black);
      board[1][col] = Piece(type: PieceType.pawn, color: PieceColor.black);
      board[6][col] = Piece(type: PieceType.pawn, color: PieceColor.white);
      board[7][col] = Piece(type: backRankTypes[col], color: PieceColor.white);
    }
  }

  void onSquareTapped(int row, int col) {
    if (winner != null) return;

    var tappedPiece = board[row][col];

    if (selectedPosition == null) {
      if (tappedPiece != null && tappedPiece.color == currentTurn) {
        selectedPosition = Position(row, col);
        notifyListeners();
      }
      return;
    }

    Position from = selectedPosition!;
    Position to = Position(row, col);

    if (from == to) {
      selectedPosition = null;
      notifyListeners();
      return;
    }

    if (tappedPiece != null && tappedPiece.color == currentTurn) {
      selectedPosition = to;
      notifyListeners();
      return;
    }

    if (_isValidMove(from, to)) {
      _executeMove(from, to);
    } else {
      selectedPosition = null;
      notifyListeners();
    }
  }

  // --- KIỂM TRA LUẬT CỜ CHÍNH ---
  bool _isValidMove(Position from, Position to) {
    var movingPiece = board[from.row][from.col]!;
    var targetPiece = board[to.row][to.col];

    if (targetPiece != null && targetPiece.color == currentTurn) {
      return false;
    }

    int dr = to.row - from.row;
    int dc = to.col - from.col;
    bool isCapture = targetPiece != null;

    // Switch trên Enum đã bao quát đủ trường hợp nên không cần return false; ở cuối hàm
    switch (movingPiece.type) {
      case PieceType.pawn:
        return _isValidPawnMove(from, to, movingPiece.color, isCapture);
      case PieceType.knight:
        return _isValidKnightMove(dr, dc);
      case PieceType.bishop:
        return _isValidBishopMove(dr, dc) && _isPathClear(from, to);
      case PieceType.rook:
        return _isValidRookMove(dr, dc) && _isPathClear(from, to);
      case PieceType.queen:
        return (_isValidRookMove(dr, dc) || _isValidBishopMove(dr, dc)) && _isPathClear(from, to);
      case PieceType.king:
        return _isValidKingMove(dr, dc);
    }
  }

  // --- CÁC HÀM PHỤ TRỢ (LUẬT TỪNG QUÂN) ---

  bool _isValidPawnMove(Position from, Position to, PieceColor color, bool isCapture) {
    int dr = to.row - from.row;
    int dc = to.col - from.col;
    
    int forward = color == PieceColor.white ? -1 : 1;
    int startRow = color == PieceColor.white ? 6 : 1;

    // Đi thẳng
    if (!isCapture && dc == 0) {
      if (dr == forward) return true;
      if (from.row == startRow && dr == 2 * forward && board[from.row + forward][from.col] == null) {
        return true;
      }
    }
    // Ăn chéo
    else if (isCapture && dr == forward && dc.abs() == 1) {
      return true;
    }
    return false;
  }

  bool _isValidKnightMove(int dr, int dc) {
    return (dr.abs() == 2 && dc.abs() == 1) || (dr.abs() == 1 && dc.abs() == 2);
  }

  bool _isValidBishopMove(int dr, int dc) {
    return dr.abs() == dc.abs();
  }

  bool _isValidRookMove(int dr, int dc) {
    return dr == 0 || dc == 0;
  }

  bool _isValidKingMove(int dr, int dc) {
    return dr.abs() <= 1 && dc.abs() <= 1;
  }

  bool _isPathClear(Position from, Position to) {
    int rowStep = (to.row - from.row).sign;
    int colStep = (to.col - from.col).sign;

    int currentRow = from.row + rowStep;
    int currentCol = from.col + colStep;

    while (currentRow != to.row || currentCol != to.col) {
      if (board[currentRow][currentCol] != null) return false;
      currentRow += rowStep;
      currentCol += colStep;
    }
    return true;
  }

  // --- THỰC THI DI CHUYỂN ---
  void _executeMove(Position from, Position to) {
    var movingPiece = board[from.row][from.col]!;
    var targetPiece = board[to.row][to.col];

    if (targetPiece != null && targetPiece.type == PieceType.king) {
      winner = currentTurn;
    }

    board[to.row][to.col] = movingPiece;
    board[from.row][from.col] = null;
    
    selectedPosition = null;

    if (winner == null) {
      currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    }
    notifyListeners();
  }
}