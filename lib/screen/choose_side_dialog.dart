import 'package:flutter/material.dart';

class ChooseSideDialog extends StatefulWidget {
  const ChooseSideDialog({super.key});

  @override
  State<ChooseSideDialog> createState() => _ChooseSideDialogState();
}

class _ChooseSideDialogState extends State<ChooseSideDialog> {
  String? selectedSide;

  void _selectSide(String side) {
    setState(() {
      selectedSide = side;
    });
  }

  Widget _sideButton(String side, String pieceSymbol, Color iconColor, String label) {
    final bool isSelected = selectedSide == side;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectSide(side),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B7DD9) : const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.yellow : Colors.white38,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pieceSymbol,
                style: TextStyle(fontSize: 30, color: iconColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn Tùy chọn'),
      backgroundColor: const Color(0xFF1B2A3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _sideButton('white', '♙', Colors.white, 'Trắng'),
              _sideButton('random', '⚖', Colors.grey, 'Ngẫu nhiên'),
              _sideButton('black', '♟', Colors.black, 'Đen'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Chọn một bên rồi bấm Chơi để bắt đầu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: selectedSide == null ? null : () => Navigator.pop(context, selectedSide),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedSide == null ? Colors.grey : const Color(0xFF3B7DD9),
          ),
          child: const Text('Chơi'),
        ),
      ],
    );
  }
}