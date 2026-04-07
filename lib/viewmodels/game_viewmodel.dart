import 'package:flutter/material.dart';
import 'dart:math';
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

  // Thêm biến quản lý chế độ chơi và trạng thái máy đang nghĩ
  final String mode; 
  final PieceColor playerColor;
  bool isComputerThinking = false;

  GameViewModel({this.mode = 'friend',this.playerColor = PieceColor.white}) {
    resetGame();
  }

  void resetGame() {
    currentTurn = PieceColor.white;
    selectedPosition = null;
    winner = null;
    capturedWhitePieces = [];
    capturedBlackPieces = [];
    isComputerThinking = false;
    
    // Tùy theo chế độ mà xếp bàn cờ khác nhau
    if (mode == 'puzzle') {
      _initializePuzzleBoard();
    } else {
      _initializeBoard();
    }
    if (mode == 'computer' && playerColor == PieceColor.black) {
      Future.delayed(const Duration(milliseconds: 500), () => _makeComputerMove());
    } else {
      notifyListeners();
    }
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

  
  void _initializePuzzleBoard() {
    board = List.generate(8, (_) => List.filled(8, null));
    // Quân Đen
    board[0][7] = Piece(type: PieceType.king, color: PieceColor.black); // Vua h8
    board[1][7] = Piece(type: PieceType.pawn, color: PieceColor.black); // Tốt h7
    board[1][6] = Piece(type: PieceType.pawn, color: PieceColor.black); // Tốt g7
    board[0][5] = Piece(type: PieceType.rook, color: PieceColor.black); // Xe f8

    // Quân Trắng
    board[7][4] = Piece(type: PieceType.king, color: PieceColor.white); // Vua e1
    board[7][7] = Piece(type: PieceType.rook, color: PieceColor.white); // Xe h1
    board[2][5] = Piece(type: PieceType.queen, color: PieceColor.white); // Hậu f6
  }

  void onSquareTapped(int row, int col) {
    // Khóa bàn cờ nếu đã có người thắng HOẶC máy đang suy nghĩ
    if (winner != null || isComputerThinking) return;
    //Chặn các thao tác của người chơi nếu không phải lượt của họ (Đúng với chế độ chơi)
    if (mode == 'computer' && currentTurn != playerColor) return;
    if (mode == 'puzzle' && currentTurn == PieceColor.black) return;
    

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

    if (targetPiece != null && targetPiece.color == movingPiece.color) return false;

    int dr = to.row - from.row;
    int dc = to.col - from.col;
    bool isCapture = targetPiece != null;

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

  bool _isValidPawnMove(Position from, Position to, PieceColor color, bool isCapture) {
    int dr = to.row - from.row;
    int dc = to.col - from.col;
    int forward = color == PieceColor.white ? -1 : 1;
    int startRow = color == PieceColor.white ? 6 : 1;

    if (!isCapture && dc == 0) {
      if (dr == forward) return true;
      if (from.row == startRow && dr == 2 * forward && board[from.row + forward][from.col] == null) return true;
    } else if (isCapture && dr == forward && dc.abs() == 1) {
      return true;
    }
    return false;
  }

  bool _isValidKnightMove(int dr, int dc) => (dr.abs() == 2 && dc.abs() == 1) || (dr.abs() == 1 && dc.abs() == 2);
  bool _isValidBishopMove(int dr, int dc) => dr.abs() == dc.abs();
  bool _isValidRookMove(int dr, int dc) => dr == 0 || dc == 0;
  bool _isValidKingMove(int dr, int dc) => dr.abs() <= 1 && dc.abs() <= 1;

  bool _isPathClear(Position from, Position to) {
    int rowStep = to.row > from.row ? 1 : (to.row < from.row ? -1 : 0);
    int colStep = to.col > from.col ? 1 : (to.col < from.col ? -1 : 0);

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
    Piece movingPiece = board[from.row][from.col]!;
    Piece? targetPiece = board[to.row][to.col];

    // Xử lý ăn quân địch
    if (targetPiece != null) {
      if (targetPiece.type == PieceType.king) winner = currentTurn;
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
      
      // KÍCH HOẠT AI SAU KHI NGƯỜI ĐI XONG
      if ((mode == 'computer' || mode == 'puzzle') && currentTurn == PieceColor.black) 
      {
        _makeComputerMove();
      }   else if (mode == 'puzzle' && currentTurn == PieceColor.black) 
      {
        _makeComputerMove();
      }
    }
    notifyListeners();
  }

  // --- LOGIC AI (MÁY CHƠI) ---
  Future<void> _makeComputerMove() async {
    isComputerThinking = true;
    notifyListeners(); // Báo UI hiện chữ "Đang nghĩ..."

    // Giả lập thời gian máy suy nghĩ cho giống thật (0.8 giây)
    await Future.delayed(const Duration(milliseconds: 800));
    PieceColor aiColor = playerColor == PieceColor.white ? PieceColor.black : PieceColor.white;
    List<Map<String, dynamic>> possibleMoves = [];

    // Quét toàn bộ bàn cờ tìm quân của AI
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] != null && board[r][c]!.color == aiColor) {
          Position from = Position(r, c);
          
          // Thử đi tới tất cả các ô trên bàn cờ
          for (int tr = 0; tr < 8; tr++) {
            for (int tc = 0; tc < 8; tc++) {
              Position to = Position(tr, tc);
              if (_isValidMove(from, to)) {
                // Đánh giá điểm nước đi: Ưu tiên ăn quân có giá trị cao
                int moveScore = 0;
                if (board[tr][tc] != null) {
                  moveScore = board[tr][tc]!.value * 10; // Đánh trọng số cao cho việc ăn quân
                }
                // Thêm một chút ngẫu nhiên để máy đi đa dạng hơn
                moveScore += Random().nextInt(5); 

                possibleMoves.add({'from': from, 'to': to, 'score': moveScore});
              }
            }
          }
        }
      }
    }

    if (possibleMoves.isNotEmpty) {
      // Sắp xếp các nước đi theo điểm số từ cao xuống thấp
      possibleMoves.sort((a, b) => b['score'].compareTo(a['score']));
      
      // Chọn nước đi tốt nhất (đứng đầu danh sách)
      var bestMove = possibleMoves.first;
      _executeMove(bestMove['from'], bestMove['to']);
    } else {
      // Máy hết nước đi -> Người chơi thắng
      winner = PieceColor.white;
      notifyListeners();
    }

    isComputerThinking = false;
  }
}