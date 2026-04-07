
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../model/game_position.dart';
import '../model/game_pieces_color.dart';

class GameScreen extends StatelessWidget {
  final String mode;
  final PieceColor playerColor;
  const GameScreen({super.key, required this.mode, this.playerColor = PieceColor.white,});

  String _getScreenTitle() {
    switch (mode) {
      case 'computer':
        return 'Chơi với Máy tính';
      case 'puzzle':
        return 'Giải câu đố (Bí 2 nước)'; 
      case 'online':
        return 'Đấu trực tuyến';
      case 'friend':
      default:
        return 'Chơi với bạn (2 Người)';
    }
  }

  // --- HÀM MỚI: Ánh xạ loại quân cờ thành Icon (Unicode) ---
  String _getPieceIcon(Piece piece) {
    // Sử dụng bộ icon đặc (solid) để dễ dàng thay đổi màu sắc Trắng/Đen
    switch (piece.type) {
      case PieceType.king: return '♚';
      case PieceType.queen: return '♛';
      case PieceType.rook: return '♜';
      case PieceType.bishop: return '♝';
      case PieceType.knight: return '♞';
      case PieceType.pawn: return '♟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameViewModel(mode: mode, playerColor: playerColor),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A), 
        appBar: AppBar(
          title: Text(_getScreenTitle()),
          backgroundColor: const Color(0xFF2C3E50),
          actions: [
            Consumer<GameViewModel>(
              builder: (context, viewModel, child) => IconButton(
                icon: const Icon(Icons.refresh), 
                onPressed: () => viewModel.resetGame(),
                tooltip: 'Chơi lại',
              ),
            ),
          ],
        ),
        body: Consumer<GameViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildPlayerHeader(PieceColor.black, viewModel),
                
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildBoard(context, viewModel),
                        if (viewModel.winner != null) _buildGameOverOverlay(viewModel),
                      ],
                    ),
                  ),
                ),
                
                _buildPlayerHeader(PieceColor.white, viewModel),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerHeader(PieceColor color, GameViewModel viewModel) {
    bool isCurrentTurn = viewModel.currentTurn == color && viewModel.winner == null;
    
    String playerName;
    if (viewModel.mode == 'friend') {
      playerName = color == PieceColor.white ? 'Người chơi 1 (Trắng)' : 'Người chơi 2 (Đen)';
    } else {
      playerName = color == PieceColor.white ? 'Bạn (Trắng)' : 'Máy tính (Đen)';
    }
    
    List<Piece> capturedPieces = (color == PieceColor.white) 
        ? viewModel.capturedWhitePieces 
        : viewModel.capturedBlackPieces;

    bool showThinking = isCurrentTurn && viewModel.isComputerThinking && color == PieceColor.black;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isCurrentTurn ? const Color(0xFF3498DB).withAlpha(50) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentTurn ? const Color(0xFF3498DB) : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: color == PieceColor.white ? Colors.white : Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                playerName,
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentTurn ? Colors.white : Colors.grey[400],
                ),
              ),
              const Spacer(),
              if (showThinking)
                const Text('Máy đang nghĩ...', style: TextStyle(color: Color(0xFFE74C3C), fontSize: 13, fontStyle: FontStyle.italic))
              else if (isCurrentTurn)
                const Text('Đến lượt', style: TextStyle(color: Color(0xFF3498DB), fontSize: 13, fontStyle: FontStyle.italic)),
            ],
          ),
          if (capturedPieces.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              // --- ÁP DỤNG ICON CHO KHU VỰC QUÂN BỊ BẮT KHI ĂN QUÂN ---
              children: capturedPieces.map((p) => Text(
                _getPieceIcon(p), 
                style: TextStyle(
                  color: p.color == PieceColor.white ? Colors.white : Colors.black, 
                  fontSize: 24, // Cỡ vừa phải cho khu vực hiển thị
                  shadows: [
                    Shadow(color: p.color == PieceColor.white ? Colors.black54 : Colors.white54, offset: const Offset(1, 1), blurRadius: 1),
                  ]
                )
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBoard(BuildContext context, GameViewModel viewModel) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF404040), width: 3),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
          itemCount: 64,
          itemBuilder: (context, index) {
            bool isPlayerWhite = viewModel.playerColor == PieceColor.white;
            int row = isPlayerWhite ? index ~/ 8 : 7 - (index ~/ 8);
            int col = isPlayerWhite ? index % 8 : 7 - (index % 8);
            
            bool isWhiteSquare = (row + col) % 2 == 0;
            bool isSelected = viewModel.selectedPosition == Position(row, col);
            
            Piece? piece = viewModel.board[row][col];

            return GestureDetector(
              onTap: () => viewModel.onSquareTapped(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF81D4FA).withAlpha(180) 
                      : isWhiteSquare
                          ? const Color(0xFFF0F0F0) 
                          : const Color(0xFFA0A0A0), 
                  border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                ),
                child: Center(
                  child: piece != null
                      ? _buildPieceDisplay(piece)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- ĐÃ LÀM LẠI HÀM NÀY: Bỏ vòng tròn mờ, dùng Icon với font chữ to ---
  Widget _buildPieceDisplay(Piece piece) {
    bool isWhite = piece.color == PieceColor.white;
    
    return Text(
      _getPieceIcon(piece), 
      style: TextStyle(
        fontSize: 42, // Kích thước siêu to để lắp vừa ô cờ
        color: isWhite ? Colors.white : Colors.black,
        height: 1.0, // Đảm bảo icon không bị lệch chiều dọc
        shadows: [
          // Đổ bóng sắc nét để quân Trắng không bị chìm vào ô Trắng, Đen không chìm vào ô Đen
          Shadow(
            color: isWhite ? Colors.black87 : Colors.white54, 
            offset: const Offset(0.5, 0.5), 
            blurRadius: 3
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay(GameViewModel viewModel) {
    String winnerText = viewModel.winner == PieceColor.white ? "QUÂN TRẮNG THẮNG" : "QUÂN ĐEN THẮNG";
    
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.amber, size: 70),
          const SizedBox(height: 16),
          Text(
            winnerText,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.resetGame(),
            icon: const Icon(Icons.refresh),
            label: const Text('CHƠI LẠI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          )
        ],
      ),
    );
  }
}