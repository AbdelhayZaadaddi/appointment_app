import 'package:flutter/material.dart';

class SearchButton extends StatefulWidget {
  const SearchButton({super.key});

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search contacts...", // This will be styled by the theme
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}
