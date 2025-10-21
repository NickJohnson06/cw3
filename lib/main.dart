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
          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
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

  // Actions
  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task')),
      );
      return;
    }
    setState(() {
      _tasks.add(Task(name: text));
      _controller.clear();
    });
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      _tasks[index].isDone = value ?? false;
    });
  }

  void _deleteTask(int index) {
    final removed = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted: ${removed.name}')),
    );
  }

  // Derived view
  List<Task> get _visibleTasks {
    switch (_filter) {
      case TaskFilter.active:
        return _tasks.where((t) => !t.isDone).toList();
      case TaskFilter.done:
        return _tasks.where((t) => t.isDone).toList();
      case TaskFilter.all:
      default:
        return _tasks;
    }
  }

  // Map visible index to real index
  int _realIndex(int visibleIndex) {
    final current = _visibleTasks[visibleIndex];
    return _tasks.indexOf(current);
  }

  @override
  Widget build(BuildContext context) {
    final chipStyle = Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<TaskFilter>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFF2A313B);
                  return const Color(0xFF1A1F27);
                }),
                side: WidgetStateProperty.all(BorderSide.none),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                textStyle: WidgetStateProperty.all(chipStyle),
              ),
              segments: const [
                ButtonSegment(value: TaskFilter.all, label: Text('All')),
                ButtonSegment(value: TaskFilter.active, label: Text('Active')),
                ButtonSegment(value: TaskFilter.done, label: Text('Done')),
              ],
              selected: <TaskFilter>{_filter},
              onSelectionChanged: (sel) {
                setState(() => _filter = sel.first);
              },
              showSelectedIcon: false,
              multiSelectionEnabled: false,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: _tasks.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                itemCount: _visibleTasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final realIdx = _realIndex(i);
                  final task = _tasks[realIdx];
                  final leftStripe = task.isDone ? Colors.greenAccent : Colors.amber;

                  return Dismissible(
                    key: ValueKey(task),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    onDismissed: (_) => _deleteTask(realIdx),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F27),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(color: leftStripe, width: 4),
                        ),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (val) => _toggleTask(realIdx, val),
                          shape: const CircleBorder(),
                        ),
                        title: Text(
                          task.name,
                          style: TextStyle(
                            color: Colors.white,
                            decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteTask(realIdx),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),

      // Bottom input bar
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
                  onSubmitted: (_) => _addTask(),
                  decoration: const InputDecoration(
                    hintText: 'Add a new task…',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _addTask,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
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
