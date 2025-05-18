import 'package:hive/hive.dart';
import 'exercise_model.dart';

part 'workout_history_model.g.dart';

@HiveType(typeId: 4)
class WorkoutHistory extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  List<ExerciseModel> exercises;

  WorkoutHistory({required this.date, required this.exercises});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  static WorkoutHistory fromJson(Map<String, dynamic> json) => WorkoutHistory(
    date: DateTime.parse(json['date']),
    exercises:
        (json['exercises'] as List)
            .map((e) => ExerciseModel.fromJson(e))
            .toList(),
  );
}
