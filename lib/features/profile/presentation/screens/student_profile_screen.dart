import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/quick_eat_app_bar.dart';
import '../../../shell/presentation/layouts/main_layout.dart';
import '../widgets/profile_scope.dart';
import '../widgets/profile_view.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: QuickEatAppBar(
          onOuvrirCommandes: () =>
              context.read<MainLayoutController?>()?.select(1),
        ),
        body: const ProfileView(estCommercant: false),
      ),
    );
  }
}
