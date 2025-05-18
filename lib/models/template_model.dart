import 'package:hive/hive.dart';
import 'exercise_model.dart';
import 'workout_history_model.dart';

part 'template_model.g.dart';

@HiveType(typeId: 0)
class TemplateModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? note;

  @HiveField(3)
  List<ExerciseModel> exercises;

  @HiveField(4)
  DateTime? lastCompleted;

  @HiveField(5)
  List<WorkoutHistory> history;

  TemplateModel({
    required this.title,
    required this.id,
    required this.exercises,
    this.note,
    this.lastCompleted,
    List<WorkoutHistory>? history,
  }) : history = history ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'lastCompleted': lastCompleted?.toIso8601String(),
  };

  static TemplateModel fromJson(Map<String, dynamic> json) => TemplateModel(
    id: json['id'],
    title: json['title'],
    note: json['note'],
    exercises:
        (json['exercises'] as List)
            .map((e) => ExerciseModel.fromJson(e))
            .toList(),
    lastCompleted:
        json['lastCompleted'] != null
            ? DateTime.tryParse(json['lastCompleted'])
            : null,
  );
}
