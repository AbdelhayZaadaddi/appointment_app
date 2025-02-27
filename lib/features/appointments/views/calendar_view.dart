import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/features/appointments/views/next_day_appointments.dart';
import 'package:appointement/features/appointments/widgets/CalenderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
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
  int unreadCount = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? userName;
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
  try {
    //User? user = _auth.currentUser;
    Map<String, dynamic>? userData = await getUserData();
    if (userData != null) {
      setState(() {
        userName = userData['name'] ?? '';
      });
    } else {
      print("User data not found");
    }
  } catch (e) {
    print("Error loading user data: $e");
  }
}

  @override
  void initState() {
    super.initState();
    loadUserData();
    _scrollController.addListener(_handleScroll);
    fetchUnreadCount();
  }

  void fetchUnreadCount() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        unreadCount = snapshot.docs.length;
      });
    });
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
  final viewportBottom = viewportTop + _scrollController.position.viewportDimension;

  for (String dateStr in nextDaysState.formattedDates) {
    final key = nextDaysState.dayKeys[dateStr];
    if (key?.currentContext == null) continue;

    final renderBox = key!.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: scrollableBox);

    final widgetTop = position.dy;
    final widgetBottom = widgetTop + renderBox.size.height;

    if (widgetTop >= viewportTop && widgetBottom <= viewportBottom) {
      final distance = (widgetTop - viewportTop).abs();

      if (distance < minDistance) {
        minDistance = distance;
        final index = nextDaysState.formattedDates.indexOf(dateStr);
        closestDate = nextDaysState.dateTimes[index];
      }
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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final nextDaysState = _nextDaysKey.currentState;
    if (nextDaysState != null) {
      String formattedDate = DateFormat('E d').format(date);
      GlobalKey? key = nextDaysState.dayKeys[formattedDate];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              "${userName}",
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
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notificationPage);
                },
                icon: Icon(Icons.notification_important_sharp, color: Colors.black54),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 22,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 13,
                      minHeight: 13,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          WeekCalendarPage(
            selectedDate: selectedDate,
            onDateSelected: (date) {
              _handleManualNavigation(date);
            },
            onWeekNavigated: (date) {
              _handleManualNavigation(date);
            },
          ),
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6, 
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