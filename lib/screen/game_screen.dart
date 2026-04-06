import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../model/game_position.dart';
import '../model/game_pieces_color.dart';

class GameScreen extends StatelessWidget {
  final String mode;
  
  const GameScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    // BỌC MÀN HÌNH BẰNG PROVIDER ĐỂ GỌI ĐẾN FILE LOGIC
    return ChangeNotifierProvider(
      create: (_) => GameViewModel(mode:mode),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A), 
        appBar: AppBar(
          title: const Text('Cờ Vua - Chơi 2 người'),
          backgroundColor: const Color(0xFF2C3E50),
          actions: [
            Consumer<GameViewModel>(
              builder: (context, viewModel, child) => IconButton(
                icon: const Icon(Icons.refresh), 
                onPressed: () => viewModel.resetGame(),
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
    // Đổi tên dựa theo chế độ
    String playerName;
    if (viewModel.mode == 'friend') {
      playerName = color == PieceColor.white ? 'Người 1 (Trắng)' : 'Người 2 (Đen)';
    } else {
      playerName = color == PieceColor.white ? 'Bạn (Trắng)' : 'Máy tính (Đen)';
    }
    
    // Hiện chữ máy đang nghĩ
    bool showThinking = isCurrentTurn && viewModel.isComputerThinking && color == PieceColor.black;


            // Thay phần Spacer() cũ bằng đoạn này:
              const Spacer();
              if (showThinking)
                {const Text('Máy đang nghĩ...', style: TextStyle(color: Color(0xFFE74C3C), fontSize: 13, fontStyle: FontStyle.italic));}
              else if (isCurrentTurn)
                {const Text('Đến lượt', style: TextStyle(color: Color(0xFF3498DB), fontSize: 13, fontStyle: FontStyle.italic));}
    
    List<Piece> capturedPieces = (color == PieceColor.white) 
        ? viewModel.capturedWhitePieces 
        : viewModel.capturedBlackPieces;

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
              if (isCurrentTurn)
                const Text('Đang nghĩ...', style: TextStyle(color: Color(0xFF3498DB), fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
          if (capturedPieces.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: capturedPieces.map((p) => Text(
                p.displayName, 
                style: TextStyle(
                  color: p.color == PieceColor.white ? Colors.white70 : Colors.grey, 
                  fontSize: 14,
                  fontWeight: FontWeight.bold
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
            int row = index ~/ 8;
            int col = index % 8;
            bool isWhiteSquare = (row + col) % 2 == 0;
            bool isSelected = viewModel.selectedPosition == Position(row, col);
            
            // LẤY QUÂN CỜ TỪ VIEWMODEL CHỨ KHÔNG PHẢI TỪ MA TRẬN STRING CŨ
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

  Widget _buildPieceDisplay(Piece piece) {
    bool isWhite = piece.color == PieceColor.white;
    
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isWhite ? Colors.black.withAlpha(20) : Colors.white.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Text(
        piece.displayName, 
        style: TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.bold,
          color: isWhite ? Colors.white : Colors.black,
          shadows: [
            Shadow(color: isWhite ? Colors.black54 : Colors.white54, offset: const Offset(1, 1), blurRadius: 1),
          ],
        ),
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
            label: const Text('CHƠI VÁN MỚI'),
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