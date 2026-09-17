import 'package:flutter/material.dart';

class SectionPage extends StatelessWidget {
  const SectionPage({super.key, required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(description),
        ],
      );
}
