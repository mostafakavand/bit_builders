import 'dart:convert';
import 'package:flutter/material.dart';

class UserManager extends StatefulWidget {
  @override
  _UserManagerState createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  final dbHelper = DatabaseHelper();

  // Add user
  Future<void> addUser(Map<String, String> user) async {
    final db = await dbHelper.database;
    await db.insert('users', user);
    loadUsers(); // Refresh list
  }

  // Load users
  Future<void> loadUsers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    setState(() {
      users = List<Map<String, String>>.from(maps.map(
          (x) => {'name': x['name'], 'info': x['info'], 'image': x['image']}));
    });
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  /// Method to add a user from JSON data
  void addUserFromJson(String jsonString) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      if (jsonData.containsKey('name') &&
          jsonData.containsKey('info') &&
          jsonData.containsKey('image')) {
        addUser({
          'name': jsonData['name'] as String,
          'info': jsonData['info'] as String,
          'image': jsonData['image'] as String,
        });
      } else {
        throw FormatException('Invalid JSON format');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manager'),
        backgroundColor: const Color(0x1A237E),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(user['image']!),
                  radius: 30,
                ),
                title: Text(
                  user['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  user['info']!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info, color: Colors.blueAccent),
                  onPressed: () {
                    _showUserDetails(context, user);
                  },
                  tooltip: 'View Details',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, String> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(user['image']!),
                radius: 50,
              ),
              const SizedBox(height: 16),
              Text(
                user['name']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user['info']!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
