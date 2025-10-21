import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'storage/storage_helper.dart';

void main() => runApp(const TaskApp());

class TaskApp extends StatefulWidget {
  const TaskApp({super.key});

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _initTheme();
  }

  Future<void> _initTheme() async {
    final mode = await LocalStore.loadThemeMode();
    if (!mounted) return;
    setState(() => _themeMode = mode);
  }

  void _toggleTheme() {
    final next = cycleTheme(_themeMode);
    setState(() => _themeMode = next);
    LocalStore.saveThemeMode(next);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: TaskListScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class Task {
  String name;
  bool isDone;
  Task({required this.name, this.isDone = false});

  Map<String, dynamic> toJson() => {'n': name, 'd': isDone};
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(name: (json['n'] ?? '').toString(), isDone: (json['d'] ?? false) as bool);
}

enum TaskFilter { all, active, done }

class TaskListScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const TaskListScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final raw = await LocalStore.loadTasksRaw();
    setState(() {
      _tasks
        ..clear()
        ..addAll(raw.map((m) => Task.fromJson(m)));
      _loading = false;
    });
  }

  Future<void> _saveTasks() async {
    await LocalStore.saveTasksRaw(_tasks.map((t) => t.toJson()).toList());
  }

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
    _saveTasks();
  }

  void _toggleTask(int index, bool? value) {
    setState(() => _tasks[index].isDone = value ?? false);
    _saveTasks();
  }

  void _deleteTask(int index) {
    final removed = _tasks[index];
    setState(() => _tasks.removeAt(index));
    _saveTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted: ${removed.name}')),
    );
  }

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

  int _realIndex(int visibleIndex) {
    final current = _visibleTasks[visibleIndex];
    return _tasks.indexOf(current);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: isDark ? Colors.white : Colors.black);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(themeIconFor(widget.themeMode)),
            onPressed: widget.onToggleTheme,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<TaskFilter>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return isDark ? const Color(0xFF2A313B) : Colors.amber.shade100;
                  }
                  return isDark ? const Color(0xFF1A1F27) : Colors.grey.shade200;
                }),
                side: WidgetStateProperty.all(BorderSide.none),
                foregroundColor:
                    WidgetStateProperty.all(isDark ? Colors.white : Colors.black),
                textStyle: WidgetStateProperty.all(chipStyle),
              ),
              segments: const [
                ButtonSegment(value: TaskFilter.all, label: Text('All')),
                ButtonSegment(value: TaskFilter.active, label: Text('Active')),
                ButtonSegment(value: TaskFilter.done, label: Text('Done')),
              ],
              selected: <TaskFilter>{_filter},
              onSelectionChanged: (sel) => setState(() => _filter = sel.first),
              showSelectedIcon: false,
              multiSelectionEnabled: false,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    itemCount: _visibleTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final realIdx = _realIndex(i);
                      final task = _tasks[realIdx];
                      final leftStripe = task.isDone
                          ? Colors.greenAccent
                          : Theme.of(context).colorScheme.secondary;

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
                            color: isDark ? const Color(0xFF1A1F27) : Colors.grey.shade100,
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
                                decoration:
                                    task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
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
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
            border: const Border(
              top: BorderSide(color: Color(0xFF2A313B), width: 1),
            ),
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
            const Icon(Icons.hourglass_empty, size: 48),
            const SizedBox(height: 8),
            Text('No tasks yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Add one using the bar below'),
          ],
        ),
      ),
    );
  }
}
