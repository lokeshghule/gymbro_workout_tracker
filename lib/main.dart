import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/template_model.dart';
import 'models/exercise_model.dart';
import 'models/set_model.dart';
import 'screens/home_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TemplateModelAdapter());
  Hive.registerAdapter(ExerciseModelAdapter());
  Hive.registerAdapter(SetModelAdapter());
  Hive.registerAdapter(WeightUnitAdapter());
  // Clear old data to avoid type errors
  await Hive.deleteBoxFromDisk('workouts');
  await Hive.openBox<TemplateModel>('workouts');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymBro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainNavigation(),
    );
  }
}
