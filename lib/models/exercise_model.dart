import 'package:hive/hive.dart';
import 'set_model.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 1)
class ExerciseModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<SetModel> sets;

  ExerciseModel({required this.name, required this.sets});

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  static ExerciseModel fromJson(Map<String, dynamic> json) => ExerciseModel(
    name: json['name'],
    sets: (json['sets'] as List).map((s) => SetModel.fromJson(s)).toList(),
  );
}
