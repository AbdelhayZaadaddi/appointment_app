import 'package:appointement/features/contacts/widgets/all_contacts.dart';
import 'package:flutter/material.dart';

class TestContact extends StatefulWidget {
  const TestContact({super.key});

  @override
  State<TestContact> createState() => _TestContactState();
}

class _TestContactState extends State<TestContact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add local contact'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: AllContacts(),
      ),
    );
  }
}
