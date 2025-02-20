import 'package:appointement/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<Map<String, dynamic>>> fetchNotifications() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> notification = doc.data() as Map<String, dynamic>;
        notification['id'] = doc.id;
        String senderId = notification['senderId'];


        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
          notification['senderName'] = userData['name'] ?? 'Unknown';
          notification['senderProfilePic'] = userData['profilePic'] ?? '';
        } else {
          notification['senderName'] = 'Unknown';
          notification['senderProfilePic'] = '';
        }

        notifications.add(notification);
      }

      notifications.sort((a, b) {
        if (a['isRead'] == b['isRead']) {
          return b['timestamp'].compareTo(a['timestamp']);
        } else {
          return a['isRead'] ? 1 : -1;
        }
      });

      return notifications;
    });
  }

  void markNotificationAsRead(String notificationId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true})
        .then((_) {
      print('Notification marked as read');
    }).catchError((error) {
      print('Failed to mark notification as read: $error');
    });
  }

  void deleteNotification(String notificationId) {
    FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
              ),
              title: Container(
                width: double.infinity,
                height: 16,
                color: Colors.grey[300],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              trailing: Container(
                width: 24,
                height: 24,
                color: Colors.grey[300],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: TAppTheme.lightTheme.scaffoldBackgroundColor,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerPlaceholder();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No notifications found.'));
              } else {
                final notifications = snapshot.data!;
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        deleteNotification(notification['id']);
                      },
                      child: Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: notification['senderProfilePic'] != null &&
                                    notification['senderProfilePic'].isNotEmpty
                                ? NetworkImage(notification['senderProfilePic'])
                                : null,
                            child: notification['senderProfilePic'] == null ||
                                    notification['senderProfilePic'].isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(notification['message']),
                          subtitle: Text(
                            'From: ${notification['senderName']}\n'
                            'Type: ${notification['type']}\n'
                          ),
                          trailing: IconButton(
                            icon: notification['isRead'] == false
                                ? const Icon(Icons.mark_as_unread, color: Colors.red)
                                : const Icon(Icons.mark_email_read, color: Colors.green),
                            onPressed: () {
                              if (notification['isRead'] == false) {
                                markNotificationAsRead(notification['id']);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}