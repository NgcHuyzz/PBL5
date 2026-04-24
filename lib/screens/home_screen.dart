import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'system_detail_screen.dart';
import 'statistics_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = "Nguyễn Minh Quân";

  final List<Widget> _screens = [
    const HomeContent(),
    const StatisticsScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textHint,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'TRANG CHỦ'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'THỐNG KÊ'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'LỊCH SỬ'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'CÁ NHÂN'),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> systems = [
      {
        'name': 'Berry Conveyor 01',
        'description': 'Hệ thống băng chuyền chính cho dâu tây xuất khẩu.',
        'location': 'Khu A - Xưởng đóng gói',
        'created': '12/10/2023',
        'icon': Icons.conveyor_belt,
        'color': const Color(0xFF006D5B),
        'status': 'Đang hoạt động',
        'statusColor': Colors.green,
      },
      {
        'name': 'Sorter AI Unit 04',
        'description': 'Cụm camera AI nhận diện độ chín và kích thước trái.',
        'location': 'Khu B - Line 2',
        'created': '05/11/2023',
        'icon': Icons.qr_code_scanner,
        'color': const Color(0xFF00796B),
        'status': 'Đang hoạt động',
        'statusColor': Colors.green,
      },
      {
        'name': 'Packaging Arm 02',
        'description': 'Cánh tay robot đóng hộp tự động khối lượng 500g.',
        'location': 'Khu A - Xưởng cuối',
        'created': '20/01/2024',
        'icon': Icons.handyman,
        'color': const Color(0xFF00897B),
        'status': 'Bảo trì',
        'statusColor': Colors.orange,
      },
      {
        'name': 'Environment Monitor',
        'description': 'Hệ thống cảm biến nhiệt độ và độ ẩm kho lạnh.',
        'location': 'Kho Lạnh Trung Tâm',
        'created': '02/02/2024',
        'icon': Icons.thermostat,
        'color': const Color(0xFF009688),
        'status': 'Đang hoạt động',
        'statusColor': Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, Nguyễn Minh Quân',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            Text(
              'Hệ thống của tôi',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: systems.length,
          itemBuilder: (context, index) {
            final system = systems[index];
            return _buildSystemCard(context, system);
          },
        ),
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context, Map<String, dynamic> system) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SystemDetailScreen(systemName: system['name']),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [system['color'], (system['color'] as Color).withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(system['icon'], color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              system['name'],
                              style: AppTheme.titleLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (system['statusColor'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              system['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: system['statusColor'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        system['description'],
                        style: AppTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: AppTheme.textHint),
                          const SizedBox(width: 4),
                          Text(system['location'], style: AppTheme.caption),
                          const SizedBox(width: 16),
                          Icon(Icons.calendar_today, size: 12, color: AppTheme.textHint),
                          const SizedBox(width: 4),
                          Text(system['created'], style: AppTheme.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_right, size: 18, color: AppTheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}