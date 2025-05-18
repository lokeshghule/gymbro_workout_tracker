import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/template_model.dart';
import '../models/workout_history_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TemplateModel>('workouts');
    final templates = box.values.toList();

    List<WorkoutHistory> allHistory = [];
    for (var t in templates) {
      allHistory.addAll(t.history);
    }
    allHistory.sort((a, b) => b.date.compareTo(a.date)); // Most recent first

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body:
          allHistory.isEmpty
              ? const Center(child: Text('No workout history yet.'))
              : ListView.builder(
                itemCount: allHistory.length,
                itemBuilder: (context, index) {
                  final history = allHistory[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        'Workout on ${history.date.toLocal().toString().split(' ')[0]}',
                      ),
                      subtitle: Text('${history.exercises.length} exercises'),
                      onTap: () {
                        // Optionally show details
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Workout Details'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      history.exercises
                                          .map((e) => Text(e.name))
                                          .toList(),
                                ),
                              ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
