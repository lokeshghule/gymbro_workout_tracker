import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/template_model.dart';
import '../models/exercise_model.dart';
import '../models/set_model.dart';
import '../models/workout_history_model.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final TemplateModel template;
  final dynamic hiveKey;

  const WorkoutSessionScreen({
    Key? key,
    required this.template,
    required this.hiveKey,
  }) : super(key: key);

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late List<ExerciseModel> _sessionExercises;
  final List<TextEditingController> _exerciseControllers = [];

  @override
  void initState() {
    super.initState();
    _sessionExercises =
        widget.template.exercises
            .map(
              (e) => ExerciseModel(
                name: e.name,
                sets:
                    e.sets
                        .map(
                          (s) => SetModel(
                            weight: s.weight,
                            repetitions: s.repetitions,
                            unit: s.unit,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();
    _syncControllers();
  }

  void _syncControllers() {
    while (_exerciseControllers.length < _sessionExercises.length) {
      _exerciseControllers.add(TextEditingController());
    }
    while (_exerciseControllers.length > _sessionExercises.length) {
      _exerciseControllers.removeLast();
    }
    for (int i = 0; i < _sessionExercises.length; i++) {
      _exerciseControllers[i].text = _sessionExercises[i].name;
      _exerciseControllers[i].selection = TextSelection.fromPosition(
        TextPosition(offset: _exerciseControllers[i].text.length),
      );
    }
  }

  void _addExercise() {
    setState(() {
      _sessionExercises.add(
        ExerciseModel(name: '', sets: [SetModel(weight: 0, repetitions: 0)]),
      );
      _syncControllers();
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _sessionExercises.removeAt(index);
      _syncControllers();
    });
  }

  void _updateExerciseName(int index, String name) {
    setState(() {
      _sessionExercises[index] = ExerciseModel(
        name: name,
        sets: _sessionExercises[index].sets,
      );
      _exerciseControllers[index].text = name;
      _exerciseControllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _exerciseControllers[index].text.length),
      );
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      _sessionExercises[exerciseIndex].sets.add(
        SetModel(weight: 0, repetitions: 0),
      );
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _sessionExercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void _updateSet(int exerciseIndex, int setIndex, double weight, int reps) {
    setState(() {
      _sessionExercises[exerciseIndex].sets[setIndex] = SetModel(
        weight: weight,
        repetitions: reps,
        unit: _sessionExercises[exerciseIndex].sets[setIndex].unit,
      );
    });
  }

  void _endWorkout() {
    final box = Hive.box<TemplateModel>('workouts');
    final prevHistory = widget.template.history ?? [];
    // final updatedHistory = List<WorkoutHistory>.from(prevHistory)..add(
    //   WorkoutHistory(
    //     date: DateTime.now(),
    //     exercises:
    //         _sessionExercises
    //             .map(
    //               (e) => ExerciseModel(
    //                 name: e.name,
    //                 sets:
    //                     e.sets
    //                         .map(
    //                           (s) => SetModel(
    //                             weight: s.weight,
    //                             repetitions: s.repetitions,
    //                             unit: s.unit,
    //                           ),
    //                         )
    //                         .toList(),
    //               ),
    //             )
    //             .toList(),
    //   ),
    // );
    final updatedTemplate = TemplateModel(
      id: widget.template.id,
      title: widget.template.title,
      exercises:
          _sessionExercises
              .map(
                (e) => ExerciseModel(
                  name: e.name,
                  sets:
                      e.sets
                          .map(
                            (s) => SetModel(
                              weight: s.weight,
                              repetitions: s.repetitions,
                              unit: s.unit,
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
      lastCompleted: DateTime.now(),
      note: widget.template.note,
      // history: updatedHistory,
    );
    box.put(widget.hiveKey, updatedTemplate);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Session')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ..._sessionExercises.asMap().entries.map((entry) {
            final exerciseIndex = entry.key;
            final exercise = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _exerciseControllers[exerciseIndex],
                            decoration: const InputDecoration(
                              labelText: 'Exercise Name',
                            ),
                            onChanged:
                                (value) =>
                                    _updateExerciseName(exerciseIndex, value),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeExercise(exerciseIndex),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exercise.sets.length,
                      itemBuilder: (context, setIndex) {
                        final set = exercise.sets[setIndex];
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: set.weight.toString(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                ),
                                onChanged: (val) {
                                  final weight = double.tryParse(val) ?? 0.0;
                                  _updateSet(
                                    exerciseIndex,
                                    setIndex,
                                    weight,
                                    set.repetitions,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: set.repetitions.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Reps',
                                ),
                                onChanged: (val) {
                                  final reps = int.tryParse(val) ?? 0;
                                  _updateSet(
                                    exerciseIndex,
                                    setIndex,
                                    set.weight,
                                    reps,
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed:
                                  () => _removeSet(exerciseIndex, setIndex),
                            ),
                          ],
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Set'),
                        onPressed: () => _addSet(exerciseIndex),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            onPressed: _addExercise,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _endWorkout,
        icon: const Icon(Icons.check),
        label: const Text('End Workout'),
      ),
    );
  }
}
