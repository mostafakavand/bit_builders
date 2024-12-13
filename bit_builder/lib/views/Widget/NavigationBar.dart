import 'package:bit_builder/service/picture/PictureService.dart';
import 'package:bit_builder/views/HomePage.dart';
import 'package:bit_builder/views/Widget/userManager.dart';
import 'package:flutter/material.dart';
import 'package:bit_builder/views/profile/Profile.dart';
import 'package:bit_builder/service/voice/speechToTextPersion.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      //
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top:
                BorderSide(color: Colors.grey.shade400, width: 1), // Top border
          ),
        ),
        child: NavigationBar(
          elevation: 8,
          backgroundColor: Color(0x1A237E),
          indicatorColor: Colors.blue,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon:
                  Icon(Icons.person, color: theme.colorScheme.primary),
              label: 'پروفایل',
            ),
            NavigationDestination(
              icon: Icon(Icons.mic_none),
              selectedIcon: Icon(Icons.mic, color: theme.colorScheme.primary),
              label: 'ضبط صدا',
            ),
            const SizedBox.shrink(), // Placeholder for FAB
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon:
                  Icon(Icons.camera_alt, color: theme.colorScheme.primary),
              label: 'دوربین',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon:
                  Icon(Icons.list_alt, color: theme.colorScheme.primary),
              label: 'کارمندان',
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeOut,
        child: _getPage(currentPageIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage1()), // Navigate to HomePage
          );
        },
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        child: const Icon(
          Icons.home,
          size: 28,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  // Dynamically switch between pages
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return ManagerProfile();

      case 1:
        return SpeechToTextExample();
      case 2:
      // Placeholder for future implementation
      case 3:
        return CameraScreen();
      case 4:
        return UserManager();

      default:
        return const Center(
          child: Text(
            "Coming Soon",
            style: TextStyle(fontSize: 18, color: Color(0x1A237E)),
          ),
        );
    }
  }
}
