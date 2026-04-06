
import 'package:flutter/material.dart';
import '../model/game_pieces_color.dart';
import '../model/game_position.dart';

class GameViewModel extends ChangeNotifier {
  late List<List<Piece?>> board;
  PieceColor currentTurn = PieceColor.white;
  Position? selectedPosition;
  PieceColor? winner;

  // Danh sách hiển thị quân bị ăn
  List<Piece> capturedWhitePieces = [];
  List<Piece> capturedBlackPieces = [];

  GameViewModel() {
    resetGame();
  }

  void resetGame() {
    currentTurn = PieceColor.white;
    selectedPosition = null;
    winner = null;
    capturedWhitePieces = [];
    capturedBlackPieces = [];
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
    if (winner != null) return; // Kết thúc game thì khóa bàn cờ

    var tappedPiece = board[row][col];

    // [FIX LỖI 4]: KHI CHƯA CHỌN QUÂN NÀO
    if (selectedPosition == null) {
      // Chỉ cho phép chọn quân CỦA MÌNH (Đúng với lượt hiện tại)
      if (tappedPiece != null && tappedPiece.color == currentTurn) {
        selectedPosition = Position(row, col);
        notifyListeners();
      }
      return; 
    }

    Position from = selectedPosition!;
    Position to = Position(row, col);

    // Bấm lại vào chính nó -> Bỏ chọn
    if (from == to) {
      selectedPosition = null;
      notifyListeners();
      return;
    }

    // [FIX LỖI 4]: ĐỔI Ý, CHỌN QUÂN KHÁC
    // Đang chọn quân Trắng mà bấm sang quân Trắng khác -> Chuyển vệt sáng
    if (tappedPiece != null && tappedPiece.color == currentTurn) {
      selectedPosition = to;
      notifyListeners();
      return;
    }

    // [FIX LỖI 1, 2, 3]: KIỂM TRA LUẬT & DI CHUYỂN / ĂN QUÂN
    if (_isValidMove(from, to)) {
      _executeMove(from, to);
    } else {
      // Đi sai luật thì bỏ chọn (Hoặc bạn có thể xóa dòng này để nó giữ nguyên vệt sáng)
      selectedPosition = null;
      notifyListeners();
    }
  }

  // --- BỘ KIỂM TRA LUẬT CỜ CHUẨN ---

  bool _isValidMove(Position from, Position to) {
    var movingPiece = board[from.row][from.col]!;
    var targetPiece = board[to.row][to.col];

    // Tuyệt đối không cho phép ăn quân đồng minh
    if (targetPiece != null && targetPiece.color == movingPiece.color) {
      return false;
    }

    int dr = to.row - from.row;
    int dc = to.col - from.col;
    bool isCapture = targetPiece != null; // Có quân địch ở ô đích hay không

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
      return false; // Mặc định không hợp lệ nếu không khớp loại quân nào (Không nên xảy ra)
    
  }

  bool _isValidPawnMove(Position from, Position to, PieceColor color, bool isCapture) {
    int dr = to.row - from.row;
    int dc = to.col - from.col;
    
    int forward = color == PieceColor.white ? -1 : 1;
    int startRow = color == PieceColor.white ? 6 : 1;

    // Tốt đi thẳng (Không ăn quân)
    if (!isCapture && dc == 0) {
      if (dr == forward) return true; // Tiến 1 ô
      // Tiến 2 ô ở nước đầu tiên (Kiểm tra xem ô ở giữa có bị chặn không)
      if (from.row == startRow && dr == 2 * forward && board[from.row + forward][from.col] == null) {
        return true; 
      }
    }
    // Tốt ăn chéo (BẮT BUỘC phải có quân địch ở ô đích)
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

  // Quét vật cản trên đường (Dành cho Xe, Tượng, Hậu)
  bool _isPathClear(Position from, Position to) {
    int rowStep = to.row > from.row ? 1 : (to.row < from.row ? -1 : 0);
    int colStep = to.col > from.col ? 1 : (to.col < from.col ? -1 : 0);

    int currentRow = from.row + rowStep;
    int currentCol = from.col + colStep;

    while (currentRow != to.row || currentCol != to.col) {
      if (board[currentRow][currentCol] != null) {
        return false; // Có quân cản đường
      }
      currentRow += rowStep;
      currentCol += colStep;
    }
    return true;
  }

  // --- THỰC THI DI CHUYỂN VÀ ĂN QUÂN ---

  void _executeMove(Position from, Position to) {
    Piece movingPiece = board[from.row][from.col]!;
    Piece? targetPiece = board[to.row][to.col];

    // Xử lý ăn quân địch
    if (targetPiece != null) {
      if (targetPiece.type == PieceType.king) {
        winner = currentTurn; // Bắt được Vua -> Thắng
      }
      
      // Thêm vào danh sách bị bắt
      if (targetPiece.color == PieceColor.white) {
        capturedWhitePieces.add(targetPiece);
      } else {
        capturedBlackPieces.add(targetPiece);
      }
    }

    // Di chuyển
    board[to.row][to.col] = movingPiece;
    board[from.row][from.col] = null;
    
    // Đặt lại lựa chọn & Đổi lượt
    selectedPosition = null;

    if (winner == null) {
      currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    }
    notifyListeners();
  }
}