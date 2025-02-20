import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/features/appointments/views/next_day_appointments.dart';
import 'package:appointement/features/appointments/widgets/CalenderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final GlobalKey<NextDaysAppointmentsState> _nextDaysKey = GlobalKey();
  final List<String> titles = ['All', 'Personal', 'Business'];
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  DateTime? _lastNavigatedDate;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? UserName;
  DateTime displayedWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime focusedWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)); 
  
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  void loadUserData() async {
    User? user = _auth.currentUser;
    Map<String, dynamic>? userData = await getUserData();
    if (userData != null) {
      setState(() {
        UserName = userData['name'] ?? '';
      });
    } else {
      print("User data not found");
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  
  void _handleScroll() {
  final nextDaysState = _nextDaysKey.currentState;
  if (nextDaysState == null) return;

  DateTime? closestDate;
  double minDistance = double.infinity;

  final scrollableBox = _scrollController.position.context.storageContext.findRenderObject() as RenderBox;
  final viewportTop = _scrollController.offset;

  for (String dateStr in nextDaysState.formattedDates) {
    final key = nextDaysState.dayKeys[dateStr];
    if (key?.currentContext == null) continue;

    final renderBox = key!.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: scrollableBox);

    final widgetTop = position.dy;

    final distance = (widgetTop - viewportTop).abs();

    if (distance < minDistance) {
      minDistance = distance;
      final index = nextDaysState.formattedDates.indexOf(dateStr);
      closestDate = nextDaysState.dateTimes[index];
    }
  }

  if (closestDate != null && closestDate != selectedDate) {
    final newDisplayedWeekStart = closestDate.subtract(Duration(days: closestDate.weekday - 1));
    setState(() {
      selectedDate = closestDate!;
      displayedWeekStart = newDisplayedWeekStart;
    });
  }
}



  void _handleManualNavigation(DateTime date) {
    final newWeekStart = date.subtract(Duration(days: date.weekday - 1));
    setState(() {
      _lastNavigatedDate = newWeekStart;
      displayedWeekStart = newWeekStart;
      selectedDate = date;
    });
  }

  // ... rest of user data loading and other methods remain unchanged ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ... existing appBar code ...
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /*
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  'https://icon-library.com/images/default-profile-icon/default-profile-icon-24.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            */
            SizedBox(width: 10),
            Text(
              "${UserName}",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.newAppointment);
            },
            style: ButtonStyle(
                backgroundColor: WidgetStateColor.transparent
            ),
            icon: Icon(Icons.add, color: Colors.black54,)
          ),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notificationPage);
              },
              icon: Icon(Icons.notification_important_sharp, color: Colors.black54)
          )
        ],
      ),
      body: Column(
        children: [
          WeekCalendarPage(
            selectedDate: selectedDate,
            onDateSelected: (date) {
              // Optional: Handle date selection (if needed)
            },
            onWeekNavigated: (date) {
              _handleManualNavigation(date); // Use the new function
            },
          ),
          Expanded(
  child: SizedBox( // Add constrained height
    height: MediaQuery.of(context).size.height * 0.6, // Adjust as needed
    child: SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          NextDaysAppointments(
            key: _nextDaysKey,
            week: _lastNavigatedDate ?? displayedWeekStart,
          ),
        ],
      ),
    ),
  ),
),
        ],
      ),
    );
  }
}