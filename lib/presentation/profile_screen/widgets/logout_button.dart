import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 4.h), // odstęp od dołu
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // czerwony kolor
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
            ),
          ),
        ),
      ),
    );
  }
}
