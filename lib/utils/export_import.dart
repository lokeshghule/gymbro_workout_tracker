import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import '../models/template_model.dart';

Future<File?> exportTemplatesToCustomFolder() async {
  final box = Hive.box<TemplateModel>('workouts');
  final templates = box.values.map((t) => t.toJson()).toList();
  final jsonString = jsonEncode(templates);

  // Let user pick a directory
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory == null) return null; // User canceled

  final file = File('$selectedDirectory/gymbro_export.json');
  return file.writeAsString(jsonString);
}

Future<void> importTemplatesFromCustomFile() async {
  // Let user pick a file
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (result == null || result.files.single.path == null)
    return; // User cancelled

  final file = File(result.files.single.path!);
  final box = Hive.box<TemplateModel>('workouts');
  final jsonString = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(jsonString);

  for (var json in jsonList) {
    final template = TemplateModel.fromJson(json);
    box.add(template);
  }
}
