import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';
import 'edit_student_profile_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/billing_details_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/help_faqs_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/notification_setting_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';



class StudentProfileScreenPersonal extends StatefulWidget {
  final int studentId;
  StudentProfileScreenPersonal({required this.studentId});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreenPersonal> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _email = "";
  File? _image;
  Uint8List? imageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final conn = await MySQLHelper.connect();
      if (conn == null) throw Exception('Cannot connect to database');

      final result = await conn.query(
        'SELECT username, email, profile_picture FROM users WHERE id = ?',
        [widget.studentId],
      );

      if (result.isEmpty) throw Exception('No se encontró el estudiante con el ID dado');

      final data = result.first;
      setState(() {
        _name = data['username'] ?? '';
        _email = data['email'] ?? '';

        final blobData = data['profile_picture'];
        if (blobData != null && blobData is Blob) {
          imageBytes = Uint8List.fromList(blobData.toBytes());
        } else {
          imageBytes = null;
        }
      });
    } catch (e) {
      print('Error loading student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logOut() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);
    //bool isDarkMode = themeProvider.isDarkMode;
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);


    return Scaffold(
      backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.grey[100],
      // backgroundColor: isDarkMode == true ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(color: themeProvider.isDarkMode == true ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),

        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.school,
              color: Colors.blue[800],
            ),
            onPressed: () {
              // do something
            },
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: imageBytes != null
                  ? MemoryImage(imageBytes!)
                  : null,
            ),
          ),
          SizedBox(height: 10),
          Text(
            _name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode == true ? Colors.white : Colors.black,
            ),
          ),
          Text(
            _email,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStudentProfileScreen(studentId: widget.studentId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            ),
            child: Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Icon(Icons.settings, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                  ),
                  title: Text('Settings', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Icon(Icons.account_balance_wallet, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                  ),
                  title: Text('Billing Details', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BillingDetailsScreen()), // Correct navigation
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Icon(Icons.notifications, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                  ),
                  title: Text('Notifications', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Icon(Icons.info, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                  ),
                  title: Text('Help & FAQs', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpFAQScreen()), // Correct navigation
                    );
                  },
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Logout"),
                          content: Text("Are you sure you want to log out?"),
                          actions: [
                            TextButton(
                              child: Text("Cancel", style: TextStyle(color: Colors.black)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Logout", style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _logOut();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
