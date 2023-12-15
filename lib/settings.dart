import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: const Column(
        children: [
          SizedBox(
            height: 400,
          ),
          Divider(
            height: 1,
          ),
          Text(
            'Contact Us ',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ), //TODO: Telefon numarası eklenecek ve ordan arama menüsüne geçecek.
          Image(
            image: NetworkImage(
              'https://egeteknopark.com.tr/wp-content/uploads/2020/03/proge.png',
            ),
          ),
        ],
      ),
    );
  }
}
