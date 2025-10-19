import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_home.dart';
import 'smart_doctor.dart';
import 'patient_record.dart';
import 'ward_schedule_screen.dart'; // ✅ Import your Ward Matching screen

class DashboardDoctor extends StatefulWidget {
  const DashboardDoctor({Key? key}) : super(key: key);

  @override
  State<DashboardDoctor> createState() => _DashboardDoctorState();
}

class _DashboardDoctorState extends State<DashboardDoctor> {
  String selectedMenu = 'Dashboard';

  @override
  void initState() {
    super.initState();

    // ✅ Match system status bar with top bar color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFF2F3F3),
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF016969),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/splash_logo.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'DocTriage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.dashboard, 'Dashboard'),
                  _buildDrawerItem(Icons.folder_shared, 'Patient Record'),
                  _buildDrawerItem(Icons.smart_toy, 'Smart Doctor'),
                  _buildDrawerItem(Icons.local_hospital, 'Ward Matching'), // ✅ new option
                  _buildDrawerItem(Icons.workspaces_filled, 'Workspace'),
                  _buildDrawerItem(Icons.announcement, 'Bulletin'),
                  _buildDrawerItem(Icons.biotech, 'Lab Report Analyzer'),
                  _buildDrawerItem(Icons.description, 'Clinical Summary'),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // ===== Custom Body =====
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF2F3F3),
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🟢 Custom Top Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ☰ Menu + DocTriage
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu,
                                size: 26, color: Color(0xFF016969)),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'DocTriage',
                          style: TextStyle(
                            color: Color(0xFF016969),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),

                    // 👤 Profile Icon + 🔔 Notifications
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.person_rounded),
                          color: Color(0xFF016969),
                          iconSize: 28,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded),
                          color: Colors.black87,
                          iconSize: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ===== Main Body =====
              Expanded(
                child: selectedMenu == 'Dashboard'
                    ? DashboardHome()
                    : selectedMenu == 'Patient Record'
                        ? const PatientRecord()
                        : selectedMenu == 'Smart Doctor'
                            ? const SmartDoctor()
                            : selectedMenu == 'Ward Matching'
                                ? const WardScheduleScreen() // ✅ opens Ward Matching screen
                                : Center(
                                    child: Text(
                                      'Welcome to $selectedMenu!',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF016969),
                                      ),
                                    ),
                                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    bool isSelected = selectedMenu == title;

    return ListTile(
      leading: Icon(icon, color: const Color(0xFF016969)),
      title: Text(title, style: const TextStyle(color: Color(0xFF016969))),
      tileColor: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
      onTap: () {
        setState(() {
          selectedMenu = title;
        });
        Navigator.pop(context);
      },
    );
  }
}
