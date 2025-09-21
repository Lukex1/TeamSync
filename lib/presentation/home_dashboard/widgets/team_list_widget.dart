import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class TeamListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> teams;
  final bool isLoading;

  const TeamListWidget({
    super.key,
    required this.teams,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (teams.isEmpty) {
      return const Center(child: Text('No teams joined yet.'));
    }

    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: ListTile(
            title: Text(team['name']),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.calendarDashboard,
                  arguments: team['id']);
            },
          ),
        );
      },
    );
  }
}
