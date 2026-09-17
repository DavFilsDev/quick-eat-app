import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/quick_eat_app_bar.dart';
import '../widgets/profile_scope.dart';
import '../widgets/profile_view.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const QuickEatAppBar(),
        body: const ProfileView(estCommercant: false),
      ),
    );
  }
}
