import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;

  const AvatarWidget({super.key, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Icon(Icons.person, size: 40, color: Colors.white)
          : null,
    );
  }
}
