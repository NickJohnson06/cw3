import 'package:flutter/material.dart';

void main() => runApp(const TaskApp());

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1115),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1A1F27),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white70,
          textColor: Colors.white,
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}

class Task {
  String name;
  bool isDone;
  Task({required this.name, this.isDone = false});
}

enum TaskFilter { all, active, done }


class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar(
        title: Text('Tasks', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: _EmptyState(),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1115),
            border: Border(top: BorderSide(color: Color(0xFF2A313B), width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(hintText: 'Add a new task…'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              const FilledButton.icon(
                onPressed: null, // will wire up in next commit
                icon: Icon(Icons.add),
                label: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, size: 48, color: Colors.white70),
            const SizedBox(height: 8),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text('Add one using the bar below', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

