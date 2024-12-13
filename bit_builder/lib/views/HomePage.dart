import 'package:flutter/material.dart';

class HomePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خوش آمدید, علی',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0x1A237E),
        elevation: 0,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/13.png'),
            ),
            onPressed: () {
              // Navigate to profile page
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting Section
            Text(
              'چه کاری می‌خواهید انجام دهید؟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildQuickAction(
                  icon: Icons.person_outline,
                  label: 'پروفایل',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildQuickAction(
                  icon: Icons.mic_none,
                  label: 'ضبط صدا',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/voice');
                  },
                ),
                _buildQuickAction(
                  icon: Icons.camera_alt_outlined,
                  label: 'دوربین',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, '/camera');
                  },
                ),
                _buildQuickAction(
                  icon: Icons.notifications_active,
                  label: 'یادآور',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, '/reminders');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Reminder Section
            Text(
              'آخرین یادآور',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.notifications, color: Colors.purple),
                title: Text('خرید مواد غذایی'),
                subtitle: Text('13 آذر 1402'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to reminders page
                  Navigator.pushNamed(context, '/reminders');
                },
              ),
            ),
            const SizedBox(height: 20),
            // Previous Conversations Section
            Text(
              'مکالمات اخیر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual data count
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.chat, color: Colors.blueAccent),
                      title: Text('مکالمه $index'),
                      subtitle: Text('متن مکالمه اخیر شما...'),
                      trailing: Text('10:30 AM'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   selectedItemColor: theme.colorScheme.primary,
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'خانه',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'پروفایل',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'تنظیمات',
      //     ),
      //   ],
      //   onTap: (index) {
      //     // Handle navigation
      //   },
      // ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
