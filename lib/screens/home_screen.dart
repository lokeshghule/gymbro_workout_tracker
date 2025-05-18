import 'package:flutter/material.dart';
import 'package:gymbro_workout_tracker/screens/settings_screen.dart';
import 'package:gymbro_workout_tracker/screens/workout_session_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/template_model.dart';
import 'add_template_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<TemplateModel> workoutsBox;

  @override
  void initState() {
    super.initState();
    workoutsBox = Hive.box<TemplateModel>('workouts');
  }

  void _navigateToAddTemplate({
    TemplateModel? template,
    dynamic hiveKey,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                AddTemplateScreen(existingTemplate: template, hiveKey: hiveKey),
      ),
    );
  }

  void _deleteTemplate(int index) {
    workoutsBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GymBro Templates"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: workoutsBox.listenable(),
        builder: (context, Box<TemplateModel> box, _) {
          final templates = box.values.toList();
          if (templates.isEmpty) {
            return const Center(child: Text("No templates yet."));
          }
          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (_, index) {
              final template = templates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

                child: ListTile(
                  title: Text(template.title),
                  subtitle: Text(
                    "${template.exercises.length} exercises\n"
                    "Last completed: ${template.lastCompleted != null ? timeago.format(template.lastCompleted!) : 'Never'}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed:
                            () => _navigateToAddTemplate(
                              template: template,
                              hiveKey: box.keyAt(index),
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTemplate(index),
                      ),
                      // Inside your ListTile or Card for each template:
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => WorkoutSessionScreen(
                                    template: template,
                                    hiveKey: box.keyAt(index),
                                  ),
                            ),
                          );
                        },
                        child: const Text('Start Workout'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTemplate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
