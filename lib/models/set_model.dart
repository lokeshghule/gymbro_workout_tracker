import 'package:hive/hive.dart';

part 'set_model.g.dart';

@HiveType(typeId: 2)
enum WeightUnit {
  @HiveField(0)
  kg,
  @HiveField(1)
  lbs,
}

@HiveType(typeId: 3)
class SetModel {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int repetitions;

  @HiveField(2)
  WeightUnit unit;

  SetModel({
    required this.weight,
    required this.repetitions,
    this.unit = WeightUnit.kg,
  });

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'repetitions': repetitions,
    'unit': unit.name,
  };

  static SetModel fromJson(Map<String, dynamic> json) => SetModel(
    weight: (json['weight'] as num).toDouble(),
    repetitions: json['repetitions'] as int,
    unit: WeightUnit.values.firstWhere(
      (e) => e.name == (json['unit'] ?? 'kg'),
      orElse: () => WeightUnit.kg,
    ),
  );
}
