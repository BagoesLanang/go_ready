import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'find_item_screen.dart'; // <-- Import Find Item gantiin History
import 'nearby_page.dart';
import 'profile_page.dart';
import 'more_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List halaman dipindah ke dalem build biar gampang nge-passing fungsi ganti tab
    final List<Widget> pages = [
      HomeScreen(
        // Ini fungsi sakti yang bikin tombol di Home bisa mindahin tab
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const FindItemScreen(), // <-- Index 1 sekarang isinya fitur nyari barang
      const NearbyPage(),
      const ProfilePage(),
      const MorePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex], // Nampilin halaman sesuai index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type:
            BottomNavigationBarType.fixed, // Biar labelnya tetep keliatan semua
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            // <-- Icon dan Label Navbar udah di-update
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'Find',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me_outlined),
            activeIcon: Icon(Icons.near_me_rounded),
            label: 'Nearby',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
