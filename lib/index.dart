import 'package:appointement/features/appointments/views/calendar_view.dart';
import 'package:appointement/features/auth/views/profile_view.dart';
import 'package:appointement/features/category/category.dart';
import 'package:appointement/features/contacts/views/contact_view.dart';
import 'package:appointement/features/contacts/widgets/favorite_contacts.dart';
import 'package:appointement/theme/theme.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const List<Widget> _pages =[
    CalendarView(),
    ContactView(),
    Category(),
    FavoriteContacts(),
    ProfileView(),
  ];

  final List<BottomNavigationBarItem> _navBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: 'Calendar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_rounded),
      label: 'Contacts',
    ),
     BottomNavigationBarItem(
      icon: Icon(Icons.category),
      label: 'Service',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label: 'Favorite',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.format_align_justify),
      label: 'more',
    )
  ];

  void _onItemTapped(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _navBarItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 10),
        unselectedLabelStyle: TextStyle(fontSize: 10),
        selectedIconTheme: IconThemeData(size: 20),
        unselectedIconTheme: IconThemeData(size: 20),
        backgroundColor: TAppTheme.lightTheme.scaffoldBackgroundColor,
      ),
    );
  }
}
