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
  static const labels=<SectionId,String>{SectionId.cinema:'السينما',SectionId.liveTv:'البث المباشر',SectionId.sources:'المصادر',SectionId.resolvers:'المحللات',SectionId.tools:'المزودون',SectionId.optional:'تشخيص النظام'};
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الأقسام')),
        body: ListView(
          children: [
            for (final id in SectionId.values)
              SwitchListTile(
                key: Key('section-${id.name}'),
                title: Text(labels[id]!),
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
