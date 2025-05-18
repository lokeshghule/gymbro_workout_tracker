import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/template_model.dart';
import '../models/exercise_model.dart';
import '../models/set_model.dart';

class AddTemplateScreen extends StatefulWidget {
  final TemplateModel? existingTemplate; // for editing
  final dynamic hiveKey; // <-- add this

  const AddTemplateScreen({Key? key, this.existingTemplate, this.hiveKey})
    : super(key: key);

  @override
  _AddTemplateScreenState createState() => _AddTemplateScreenState();
}

class _AddTemplateScreenState extends State<AddTemplateScreen> {
  final _titleController = TextEditingController();
  final List<TextEditingController> _exerciseControllers = [];

  List<ExerciseModel> _exercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingTemplate != null) {
      _titleController.text = widget.existingTemplate!.title;
      _exercises =
          widget.existingTemplate!.exercises
              .map(
                (e) => ExerciseModel(
                  name: e.name,
                  sets: List<SetModel>.from(e.sets),
                ),
              )
              .toList();
    }
    _syncControllers();
  }

  void _syncControllers() {
    // Ensure controllers match the number of exercises
    while (_exerciseControllers.length < _exercises.length) {
      _exerciseControllers.add(TextEditingController());
    }
    while (_exerciseControllers.length > _exercises.length) {
      _exerciseControllers.removeLast();
    }
    for (int i = 0; i < _exercises.length; i++) {
      _exerciseControllers[i].text = _exercises[i].name;
      _exerciseControllers[i].selection = TextSelection.fromPosition(
        TextPosition(offset: _exerciseControllers[i].text.length),
      );
    }
  }

  void _addExercise() {
    setState(() {
      _exercises.add(
        ExerciseModel(name: '', sets: [SetModel(weight: 0, repetitions: 0)]),
      );
      _syncControllers();
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
      _syncControllers();
    });
  }

  void _updateExerciseName(int index, String name) {
    setState(() {
      _exercises[index] = ExerciseModel(
        name: name,
        sets: _exercises[index].sets,
      );
      _exerciseControllers[index].text = name;
      _exerciseControllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _exerciseControllers[index].text.length),
      );
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      _exercises[exerciseIndex].sets.add(SetModel(weight: 0, repetitions: 0));
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _exercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void _updateSet(int exerciseIndex, int setIndex, double weightKg, int reps) {
    setState(() {
      _exercises[exerciseIndex].sets[setIndex] = SetModel(
        weight: weightKg,
        repetitions: reps,
      );
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }
    for (var e in _exercises) {
      if (e.name.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise names cannot be empty')),
        );
        return;
      }
    }

    final template = TemplateModel(
      id:
          widget.existingTemplate?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      exercises: _exercises,
    );

    final box = Hive.box<TemplateModel>('workouts');

    if (widget.existingTemplate != null && widget.hiveKey != null) {
      box.put(widget.hiveKey, template);
    } else {
      box.add(template);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingTemplate == null ? 'Add Template' : 'Edit Template',
        ),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _submit)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Template Title'),
            ),
            const SizedBox(height: 20),
            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
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
                              controller: _exerciseControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'Exercise Name',
                              ),
                              textDirection: TextDirection.ltr,
                              onChanged:
                                  (value) => _updateExerciseName(index, value),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeExercise(index),
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
                                      index,
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
                                      index,
                                      setIndex,
                                      set.weight,
                                      reps,
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeSet(index, setIndex),
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
                          onPressed: () => _addSet(index),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
              onPressed: _addExercise,
            ),
          ],
        ),
      ),
    );
  }
}
