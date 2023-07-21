import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bottom_picker/bottom_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 135, 153, 218)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var tasks = <Task>[];
  var currentDate = DateTime.now();
  var currentPriority = 1;
  var currentDescription = "";
  var currentName = "";
  var currentTaskIndex = 0;

  void setCurrentPriority(int priority) {
    currentPriority = priority;
    notifyListeners();
  }

  void setCurrentDate(DateTime date) {
    currentDate = date;
    notifyListeners();
  }

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void removeTask() {
    tasks.remove(tasks[currentTaskIndex]);
    notifyListeners();
  }

  void updateTask(Task task) {
    tasks[currentTaskIndex] = task;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return TasksPage();
  }
}

class TasksPage extends StatelessWidget {
  const TasksPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Stack(children: [
        // Expanded(                    //ListView is already flexible
        // child:
        ListView(children: [
          for (var t in appState.tasks)
            ListTile(
              leading: Icon(
                Icons.circle,
                color: t.priority == 1
                    ? Colors.red
                    : t.priority == 2
                        ? Colors.yellow
                        : Colors.green,
              ),
              title: Text(t.name),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return TaskDetails(task: t);
                  },
                );
              },
            ),
        ]),
        // ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return const AddTaskForm();
            },
          );
        },
      ),
    );
  }
}

class Task {
  String name;
  String description;
  DateTime date;
  int priority;

  Task(
      {required this.name,
      required this.description,
      required this.date,
      required this.priority});
}

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({
    super.key,
  });

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Task name',
            ),
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter task name';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const DateForm();
                }),
            child: Text(appState.currentDate.toString().substring(0, 16)),
          ),
          TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Task description',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter task description';
              }
              return null;
            },
          ),
          Text("Choose task priority"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => appState.setCurrentPriority(1),
                  child: PriorityCard(
                    cartNumber: 1,
                  )),
              TextButton(
                  onPressed: () => appState.setCurrentPriority(2),
                  child: PriorityCard(
                    cartNumber: 2,
                  )),
              TextButton(
                  onPressed: () => appState.setCurrentPriority(3),
                  child: PriorityCard(
                    cartNumber: 3,
                  )),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                appState.addTask(Task(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    date: appState.currentDate,
                    priority: appState.currentPriority));
                Navigator.pop(context);
              }
            },
            child: const Text('Add task'),
          ),
        ],
      ),
    );
  }
}

class PriorityCard extends StatefulWidget {
  final int cartNumber;
  const PriorityCard({
    super.key,
    required this.cartNumber,
  });

  @override
  State<PriorityCard> createState() => _PriorityCardState();
}

class _PriorityCardState extends State<PriorityCard> {
  int cartNumber = 1;
  var color;
  @override
  void initState() {
    super.initState();
    cartNumber = widget.cartNumber;
  }

  @override
  Widget build(BuildContext context) {
    if (cartNumber == 3) {
      color = Colors.green;
    } else if (cartNumber == 2) {
      color = Colors.yellow;
    } else if (cartNumber == 1) {
      color = Colors.red;
    }
    var appState = context.watch<MyAppState>();
    return Container(
      width: 50,
      height: 50,
      child: Card(
        color: appState.currentPriority == widget.cartNumber
            ? color
            : Colors.white,
        child: Center(child: Text(widget.cartNumber.toString())),
      ),
    );
  }
}

class DateForm extends StatelessWidget {
  const DateForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return BottomPicker.dateTime(
      title: 'Set the event exact time and date',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.black,
      ),
      onSubmit: (inputDate) {
        appState.setCurrentDate(inputDate);
      },
      iconColor: Colors.black,
      minDateTime: DateTime.now(),
      maxDateTime: DateTime.now().add(Duration(days: 364)),
      initialDateTime: DateTime.now(),
      gradientColors: [Color(0xfffdcbf1), Color(0xffe6dee9)],
    );
  }
}

class TaskDetails extends StatefulWidget {
  TaskDetails({super.key, required this.task});
  Task task;
  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Text(widget.task.name),
          SizedBox(width: 10),
          Icon(
            Icons.circle,
            color: widget.task.priority == 1
                ? Colors.red
                : widget.task.priority == 2
                    ? Colors.yellow
                    : Colors.green,
          ),
        ],
      )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("  Date: ${widget.task.date.toString().substring(0, 10)}"),
          Text("  Time: ${widget.task.date.toString().substring(11, 16)}"),
          Text("  Description: ${widget.task.description}"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              // return const EditTaskForm(EditableTask: widget.task);
              appState.currentDescription = widget.task.description;
              appState.currentName = widget.task.name;
              appState.currentTaskIndex = appState.tasks.indexOf(widget.task);
              return const EditTaskForm();
            },
          );
        },
      ),
    );
  }
}

class EditTaskForm extends StatefulWidget {
  const EditTaskForm({
    super.key,
  });

  @override
  State<EditTaskForm> createState() => _EditTaskFormState();
}

class _EditTaskFormState extends State<EditTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "");
  final _descriptionController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (_nameController.text == "") {
      _nameController.text = appState.currentName;
    }
    if (_descriptionController.text == "") {
      _descriptionController.text = appState.currentDescription;
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Task name',
            ),
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter task name';
              }
              return null;
            },
            // initialValue: widget.EditableTask?.name ?? "",       can't use it with controller
          ),
          ElevatedButton(
            onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const DateForm();
                }),
            child: Text(appState.currentDate.toString().substring(0, 16)),
          ),
          TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Task description',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter task description';
              }
              return null;
            },
          ),
          Text("Choose task priority"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => appState.setCurrentPriority(1),
                  child: PriorityCard(
                    cartNumber: 1,
                  )),
              TextButton(
                  onPressed: () => appState.setCurrentPriority(2),
                  child: PriorityCard(
                    cartNumber: 2,
                  )),
              TextButton(
                  onPressed: () => appState.setCurrentPriority(3),
                  child: PriorityCard(
                    cartNumber: 3,
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    appState.updateTask(Task(
                        name: _nameController.text,
                        description: _descriptionController.text,
                        date: appState.currentDate,
                        priority: appState.currentPriority));
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Confirm changes'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.removeTask();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Remove task'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
