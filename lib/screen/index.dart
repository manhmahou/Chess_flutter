import 'package:flutter/material.dart';
import 'dart:async';
import 'choose_side_dialog.dart';
import 'game_screen.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _isDarkMode = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _setLoggedIn(bool value) {
    setState(() {
      _isLoggedIn = value;
    });
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _isDarkMode ? const Color(0xFF1E3A5F) : const Color(0xFF90A4AE);
    final themeIconColor = _isDarkMode ? Colors.white : Colors.black87;
    final List<Widget> widgetOptions = <Widget>[
      HomeContent(
        isLoggedIn: _isLoggedIn,
        isDarkMode: _isDarkMode,
        onLoginChanged: _setLoggedIn,
      ),
      Center(child: Text('Chơi Trực tuyến', style: TextStyle(color: themeIconColor))),
      Center(child: Text('Xếp hạng', style: TextStyle(color: themeIconColor))),
      Center(child: Text('Cài đặt', style: TextStyle(color: themeIconColor))),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess App'),
        backgroundColor: themeColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thông báo')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E3A5F),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Trang chủ'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            if (_isLoggedIn) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Đổi tên'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangeNameScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Đổi mật khẩu'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                },
              ),
              SwitchListTile(
                secondary: Icon(_isDarkMode ? Icons.nights_stay : Icons.wb_sunny),
                title: const Text('Chế độ sáng/tối'),
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Đăng xuất'),
                onTap: () {
                  setState(() {
                    _isLoggedIn = false;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn đã đăng xuất')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: themeIconColor),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public, color: themeIconColor),
            label: 'Trực tuyến',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up, color: themeIconColor),
            label: 'Xếp hạng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: themeIconColor),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: themeIconColor,
        unselectedItemColor: themeIconColor.withAlpha(179),
        backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final bool isLoggedIn;
  final bool isDarkMode;
  final ValueChanged<bool> onLoginChanged;

  const HomeContent({super.key, required this.isLoggedIn, required this.isDarkMode, required this.onLoginChanged});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final backgroundColors = widget.isDarkMode
        ? const [Color(0xFF1E3A5F), Color(0xFF0F1419)]
        : const [Color(0xFFB3E5FC), Color(0xFFE1F5FE)];

    List<Map<String, dynamic>> menuItems = [
      {'title': widget.isLoggedIn ? 'Tìm trận online' : 'Chơi Trực tuyến', 'icon': Icons.public, 'onPressed': _onPlayOnline},
      {'title': 'Chơi với Máy', 'icon': Icons.computer, 'onPressed': _onPlayWithMachine},
      {'title': 'Chơi với Bạn', 'icon': Icons.people, 'onPressed': _onPlayWithFriend},
      {'title': 'Câu đố', 'icon': Icons.quiz, 'onPressed': _onPuzzle},
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundColors,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B5A8F),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/knight.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.sports_esports,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cờ Vua',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      int row = index ~/ 8;
                      int col = index % 8;
                      bool isWhite = (row + col) % 2 == 0;
                      return Container(
                        color: isWhite ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
                        child: Center(
                          child: Text(
                            _getPiece(row, col),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _buildMenuItem(item['title'], item['icon'], item['onPressed']);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPlayOnline() async {
    if (!widget.isLoggedIn) {
      final result = await Navigator.push<bool?>(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      if (!mounted) return;
      if (result == true) {
        widget.onLoginChanged(true);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FindingMatchScreen()),
      );
    }
  }

  void _onPlayWithMachine() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const ChooseSideDialog(),
    );
    if (!mounted) return;
    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(mode: 'computer', side: result),
        ),
      );
    }
  }

  void _onPlayWithFriend() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen(mode: 'friend')),
    );
  }

  void _onPuzzle() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen(mode: 'puzzle')),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B7DD9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getPiece(int row, int col) {
    if (row == 0) {
      switch (col) {
        case 0:
        case 7:
          return '♜';
        case 1:
        case 6:
          return '♞';
        case 2:
        case 5:
          return '♝';
        case 3:
          return '♛';
        case 4:
          return '♚';
      }
    } else if (row == 1) {
      return '♟';
    } else if (row == 6) {
      return '♙';
    } else if (row == 7) {
      switch (col) {
        case 0:
        case 7:
          return '♖';
        case 1:
        case 6:
          return '♘';
        case 2:
        case 5:
          return '♗';
        case 3:
          return '♕';
        case 4:
          return '♔';
      }
    }
    return '';
  }
}

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({super.key});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _newNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final newName = _newNameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || newName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email, tên mới và mật khẩu')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tên đã được đổi thành "$newName"')), 
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi tên'),
        backgroundColor: const Color(0xFF1E3A5F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newNameController,
              decoration: const InputDecoration(
                labelText: 'Tên mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B7DD9),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Đổi tên'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')), 
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp')), 
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đổi mật khẩu thành công')), 
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: const Color(0xFF1E3A5F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu cũ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B7DD9),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}

class FindingMatchScreen extends StatefulWidget {
  const FindingMatchScreen({super.key});

  @override
  State<FindingMatchScreen> createState() => _FindingMatchScreenState();
}

class _FindingMatchScreenState extends State<FindingMatchScreen> {
  int _elapsed = 0;
  late Timer _timer;
  late int _matchTime;

  @override
  void initState() {
    super.initState();
    _matchTime = 5 + (DateTime.now().millisecondsSinceEpoch % 10); // Ngẫu nhiên 5-14 giây
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed++;
        if (_elapsed >= _matchTime) {
          _timer.cancel();
          _onMatchFound();
        }
      });
    });
  }

  void _onMatchFound() {
    // Chuyển đến màn hình thi đấu cờ vua
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen(mode: 'online')),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        title: const Text('Tìm trận online'),
        automaticallyImplyLeading: false, // Không có nút back
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang tìm trận...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thời gian tìm: $_elapsed giây',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _timer.cancel();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B7DD9),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Hủy tìm trận'),
            ),
          ],
        ),
      ),
    );
  }
}