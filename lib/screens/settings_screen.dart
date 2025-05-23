import 'package:flutter/material.dart';
import '../utils/export_import.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Export Templates'),
              onPressed: () async {
                final file = await exportTemplatesToAppDirectory();
                if (file != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to ${file.path}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export cancelled.')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Import Templates'),
              onPressed: () async {
                try {
                  await importTemplatesFromAppDirectory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Templates imported!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
                }
              },
            ),
            const SizedBox(height: 20),
                       const Text(
              'Exported file is saved in your app\'s documents directory as gymbro_export.json.\n'
              'To import, place gymbro_export.json in the same directory on this device.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
