import 'package:flutter/material.dart';
import 'section_settings.dart';

typedef SectionChanged = void Function(SectionId id, bool enabled);

class SectionSettingsScreen extends StatefulWidget {
  const SectionSettingsScreen({super.key, required this.settings, required this.onChanged});
  final SectionSettings settings;
  final SectionChanged onChanged;

  @override
  State<SectionSettingsScreen> createState() => _SectionSettingsScreenState();
}

class _SectionSettingsScreenState extends State<SectionSettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sections')),
        body: ListView(
          children: [
            for (final id in SectionId.values)
              SwitchListTile(
                key: Key('section-${id.name}'),
                title: Text(id.name),
                value: widget.settings.isEnabled(id),
                onChanged: (value) {
                  setState(() => widget.settings.setEnabled(id, value));
                  widget.onChanged(id, value);
                },
              ),
          ],
        ),
      );
}
