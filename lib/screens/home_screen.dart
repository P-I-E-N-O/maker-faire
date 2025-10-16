import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/logo_strip.dart';
import '../widgets/map_widget.dart';
import '../widgets/controls_panel.dart';
import '../widgets/ranking_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Logo strip - 1/10 of screen height
          const LogoStrip(),

          // Main content - 9/10 of screen height
          Expanded(
            child: Row(
              children: [
                // Map - 3/4 of screen width
                Expanded(flex: 3, child: const MapWidget()),

                // Controls panel - 1/4 of screen width
                Expanded(flex: 1, child: const ControlsPanel()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<AppState>(
        builder: (context, state, child) {
          if (state.destination == null) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const RankingDialog(),
              );
            },
            icon: const Icon(Icons.leaderboard),
            label: const Text('View Ranking'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }
}
