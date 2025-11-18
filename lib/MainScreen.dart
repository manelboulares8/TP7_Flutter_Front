// main_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tp7_flutter/FormationManagement.dart';
import 'package:tp7_flutter/StudentManagement.dart';
import 'package:tp7_flutter/User.dart';
import 'package:tp7_flutter/absenceScreen.dart';
import 'package:tp7_flutter/classManagement.dart';
import 'package:tp7_flutter/matiereManagement.dart';
import 'package:tp7_flutter/noteManagement.dart';

import 'login.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      StudentManagement(user: widget.user),
      ClassManagement(),
      FormationManagement(user: widget.user),
      AbsenceScreen(),
      MatiereManagement(),
      NoteManagement(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MABEUL",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // ------------ DRAWER -------------
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue[800]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.user.email,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            _buildDrawerItem(
              icon: Icons.people,
              title: "Gérer les étudiants",
              index: 0,
            ),
            _buildDrawerItem(
              icon: Icons.school,
              title: "Gérer les classes",
              index: 1,
            ),
            _buildDrawerItem(
              icon: Icons.menu_book,
              title: "Gérer les formations",
              index: 2,
            ),
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: "Gérer les absences",
              index: 3,
            ),
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: "Gérer les matiéres",
              index: 4,
            ),
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: "Gérer les notes",
              index: 5,
            ),
            Divider(),

            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Fermer"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // ------------ SCREEN CONTENT -------------
      body: _screens[_currentIndex],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _currentIndex == index,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}
