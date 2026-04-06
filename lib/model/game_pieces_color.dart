
enum PieceColor { white, black }
enum PieceType { pawn, knight, bishop, rook, queen, king }

class Piece {
  final PieceType type;
  final PieceColor color;

  Piece({required this.type, required this.color});

  // Tối ưu UI: Trả về tên viết tắt 1-2 chữ cái tiếng Việt để hiển thị rõ trên ô cờ
  String get displayName {
    switch (type) {
      case PieceType.pawn:
        return 'T'; // Tốt
      case PieceType.knight:
        return 'M'; // Mã
      case PieceType.bishop:
        return 'Tg'; // Tượng
      case PieceType.rook:
        return 'X'; // Xe
      case PieceType.queen:
        return 'H'; // Hậu
      case PieceType.king:
        return 'V'; // Vua
    }
  }

  //tính giá trị của quân cờ, để dùng cho máy tính và lựa chọn thế cờ
  
  int get value {
    switch (type) {
      case PieceType.pawn: 
        return 1;   // Tốt: 1 điểm
      case PieceType.knight: 
        return 3;   // Mã: 3 điểm
      case PieceType.bishop: 
        return 3;   // Tượng: 3 điểm
      case PieceType.rook: 
        return 5;   // Xe: 5 điểm
      case PieceType.queen: 
        return 9;   // Hậu: 9 điểm
      case PieceType.king: 
        return 10000; // Vua: Vô giá (Mất vua là thua)
    }
  }
}