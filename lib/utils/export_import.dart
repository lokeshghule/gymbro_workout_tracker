import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import '../models/template_model.dart';

// You must now use a fixed path or show an error if export/import is attempted.
// Example: Save to project root (not recommended for production apps)
final String exportFileName = 'gymbro_export.json';

Future<File> exportTemplatesToAppDirectory() async {
  final box = Hive.box<TemplateModel>('workouts');
  final templates = box.values.map((t) => t.toJson()).toList();
  final jsonString = jsonEncode(templates);

  final file = File(exportFileName);
  return file.writeAsString(jsonString);
}

Future<void> importTemplatesFromAppDirectory() async {
  final file = File(exportFileName);
  if (!await file.exists()) return;

  final box = Hive.box<TemplateModel>('workouts');
  final jsonString = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(jsonString);

  for (var json in jsonList) {
    final template = TemplateModel.fromJson(json);
    box.add(template);
  }
}
