import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/features/auth/views/logout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? phoneNumber;
  String? userName;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        phoneNumber = user.phoneNumber;
        print(phoneNumber);
      });

      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc.get('name') ?? 'Test';
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    Widget? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) badge,
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'Test',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Training courses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                  ],
                ),

                IconButton(
                  onPressed: (){
                    Navigator.of(context).pushNamed(AppRoutes.editProfilePage);
                  },
                  icon: Icon(Icons.edit, color: Colors.white,),
                )
              ],
            ),
          ),

          // Business Details Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Business Details',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildListItem(
            icon: Icons.business,
            title: 'Business Info',
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.calendar_today,
            title: 'Calendar Preferences',
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.share,
            title: 'Booking Page',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.work_outline,
            title: 'Work Schedule',
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.bar_chart,
            title: 'Statistics',
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.notifications_outlined,
            title: 'Reminders and Follow-Ups',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.star_border,
            title: 'Rating & Reviews',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            onTap: () {},
          ),

          // Account Details Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Account Details',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildListItem(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.attach_money,
            title: 'Billing',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            onTap: () {},
          ),
          _buildListItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),

          // Other Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Other',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Logout(),
              Text("Logout", style: TextStyle(color: Colors.red),),
            ],
          )
            ],
          )
        ],
      ),
    );
  }
}