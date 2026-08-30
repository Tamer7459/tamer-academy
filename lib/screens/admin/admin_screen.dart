import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'admin_dashboard.dart';

class AdminScreen extends StatelessWidget {
  final AppUser user;
  const AdminScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AdminDashboard(user: user);
  }
}
