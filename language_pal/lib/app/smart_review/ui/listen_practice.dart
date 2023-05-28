import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class ListenPracticeScreen extends ConsumerWidget {
  const ListenPracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: FrostedAppBar(
        title: Text("Listen Practice"),
      ),
      body: Center(
        child: Text("Listen"),
      ),
    );
  }
}
