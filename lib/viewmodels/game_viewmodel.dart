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

  // Khởi tạo/Chơi lại từ đầu
  void resetGame() {
    currentTurn = PieceColor.white;
    selectedPosition = null;
    winner = null;
    _initializeBoard();
    notifyListeners();
  }

  void _initializeBoard() {
    board = List.generate(8, (_) => List.filled(8, null));
    
    // Khởi tạo các loại quân cờ ở hàng cuối
    const backRankTypes = [
      PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen,
      PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook
    ];

    for (int col = 0; col < 8; col++) {
      // Setup quân Đen
      board[0][col] = Piece(type: backRankTypes[col], color: PieceColor.black);
      board[1][col] = Piece(type: PieceType.pawn, color: PieceColor.black);

      // Setup quân Trắng
      board[6][col] = Piece(type: PieceType.pawn, color: PieceColor.white);
      board[7][col] = Piece(type: backRankTypes[col], color: PieceColor.white);
    }
  }

  // Xử lý logic khi người dùng chạm vào 1 ô trên bàn cờ
  void onSquareTapped(int row, int col) {
    if (winner != null) return;

    var tappedPiece = board[row][col];

    // TRƯỜNG HỢP 1: Chưa chọn quân nào
    if (selectedPosition == null) {
      // Bấm vào quân của mình -> Chọn
      if (tappedPiece != null && tappedPiece.color == currentTurn) {
        selectedPosition = Position(row, col);
        notifyListeners();
      }
      return; 
    }

    // TRƯỜNG HỢP 2: Đã chọn 1 quân trước đó
    Position from = selectedPosition!;
    Position to = Position(row, col);

    // 2.1. Bấm lại vào chính quân đó hoặc ô không hợp lệ (ví dụ: trùng luật) -> Bỏ chọn
    if (from == to) {
      selectedPosition = null;
      notifyListeners();
      return;
    }

    // 2.2. Bấm vào một quân khác CÙNG MÀU -> Đổi ý, chọn quân mới
    if (tappedPiece != null && tappedPiece.color == currentTurn) {
      selectedPosition = to; // Đổi sang vị trí mới
      notifyListeners();
      return;
    }

    // 2.3. Bấm vào ô trống hoặc quân địch -> Kiểm tra luật và di chuyển
    bool canMove = _isValidMove(from, to);
    if (canMove) {
      _executeMove(from, to);
    } else {
      // Đi sai luật -> Bỏ chọn (hoặc có thể giữ nguyên lựa chọn tùy UI)
      selectedPosition = null;
      notifyListeners();
    }
  }

  // Tạm thời cho phép đi tự do, chỉ chặn ăn quân nhà
  bool _isValidMove(Position from, Position to) {
    var targetPiece = board[to.row][to.col];
    if (targetPiece != null && targetPiece.color == currentTurn) {
      return false; 
    }
    return true;
  }

  void _executeMove(Position from, Position to) {
    var movingPiece = board[from.row][from.col]!;
    var targetPiece = board[to.row][to.col];

    // Logic thắng đơn giản: Ăn Vua
    if (targetPiece != null && targetPiece.type == PieceType.king) {
      winner = currentTurn;
    }

    // Thực hiện di chuyển
    board[to.row][to.col] = movingPiece;
    board[from.row][from.col] = null;
    
    selectedPosition = null;

    if (winner == null) {
      currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    }
    notifyListeners();
  }
}