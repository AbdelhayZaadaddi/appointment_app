import 'package:appointement/features/appointments/views/add_apointment_contact.dart';
import 'package:appointement/features/appointments/views/add_apointment_with_contact.dart';
import 'package:appointement/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteContacts extends StatefulWidget {
  const FavoriteContacts({super.key});

  @override
  State<FavoriteContacts> createState() => _FavoriteContactsState();
}

class _FavoriteContactsState extends State<FavoriteContacts> {
  List<Contact> contacts = [];
  List<Contact> favoriteContacts = [];
  bool _showContacts = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _loadFavoriteContacts();
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> fetchedContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      setState(() {
        contacts = fetchedContacts;
      });
    } else {
      print('Permission Denied For FlutterContacts');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts permission denied. Please enable it in settings.'),
        ),
      );
    }
  }

  void _toggleFavorite(Contact contact) {
    setState(() {
      if (favoriteContacts.any((c) => c.id == contact.id)) {
        _showRemoveFavoriteDialog(contact);
      } else {
        favoriteContacts.add(contact);
        _saveFavoriteContacts();
      }
    });
  }

  void _showRemoveFavoriteDialog(Contact contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TAppTheme.lightTheme.scaffoldBackgroundColor,
          title: const Text('Remove from Favorites?'),
          content: Text('Are you sure you want to remove ${contact.displayName} from favorites?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () {
                setState(() {
                  favoriteContacts.removeWhere((c) => c.id == contact.id);
                  _saveFavoriteContacts();
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _toggleContactsVisibility() {
    setState(() {
      _showContacts = !_showContacts; // Toggle visibility
    });
  }

  Future<void> _loadFavoriteContacts() async {
    final prefs = await SharedPreferences.getInstance();
    String? favContactsJson = prefs.getString('favoriteContacts');

    if (favContactsJson != null) {
      List<dynamic> favContactsData = jsonDecode(favContactsJson);
      setState(() {
        favoriteContacts = favContactsData.map((data) {
          return Contact()
            ..id = data['id']
            ..displayName = data['name']
            ..phones = [Phone(data['phone'])];
        }).toList();
      });
    }
  }

  Future<void> _saveFavoriteContacts() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> favContactsData = favoriteContacts.map((contact) {
      return {
        'id': contact.id,
        'name': contact.displayName,
        'phone': contact.phones.isNotEmpty ? contact.phones.first.number : '',
      };
    }).toList();

    prefs.setString('favoriteContacts', jsonEncode(favContactsData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Contacts', style: TextStyle(color: Colors.black54),),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black54,),
            onPressed: _toggleContactsVisibility,
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Show contacts only if _showContacts is true
          if (_showContacts)
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final isFavorite = favoriteContacts.any((c) => c.id == contact.id);
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(contact.displayName),
                    subtitle: Text(
                      contact.phones.isNotEmpty ? contact.phones.first.number : 'No Phone Number',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : null,
                      ),
                      onPressed: (){
                        _toggleFavorite(contact);
                        _toggleContactsVisibility();
                      },
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Favorite Contacts: ${favoriteContacts.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: favoriteContacts.length,
              itemBuilder: (context, index) {
                final contact = favoriteContacts[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(contact.displayName),
                  subtitle: Text(
                    contact.phones.isNotEmpty ? contact.phones.first.number : 'No Phone Number',
                  ),

                  trailing: IconButton(
                    onPressed: contact.phones.isNotEmpty
                        ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAppointmentsWithContact(
                              contact: contact.displayName,
                            ),
                          ),
                        )
                        : null,
                    icon: const Icon(Icons.add, color: Colors.black54,),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}