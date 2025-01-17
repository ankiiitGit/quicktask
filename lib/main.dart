import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quicktask/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "lib/.env");

  var keyApplicationId = dotenv.env['B4A_APPLICATION_ID'];
  var keyClientKey = dotenv.env['B4A_CLIENT_KEY'];
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId!, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  Widget initialScreen = LoginPage();

  runApp(MaterialApp(home: initialScreen));
}

class QuickTaskApp extends StatefulWidget {
  const QuickTaskApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QuickTaskAppState createState() => _QuickTaskAppState();
}

class _QuickTaskAppState extends State<QuickTaskApp> {
  List<ParseObject> tasks = [];
  TextEditingController taskController = TextEditingController();
  TextEditingController editTaskController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController editDueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTasks();
  }  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        hintColor: const Color.fromARGB(255, 156, 245, 96),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 80, 138, 225),
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QuickTask'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                getTasks();
              },
            ),
          ],
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTaskInput(),
              const SizedBox(height: 20),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            taskController.clear();
            dueDateController.clear();
            addTask();
          },
          backgroundColor: const Color.fromARGB(255, 80, 138, 225),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: taskController,
            decoration: InputDecoration(
              hintText: 'Task',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: dueDateController,
            decoration: InputDecoration(
              hintText: 'Due Date',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: addTask,
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final varTask = tasks[index];
        final varTitle = varTask.get('title') ?? '';
        final varDueDate = varTask.get('dueDate') ?? '';
        bool done = varTask.get<bool>('done') ?? false;

        return ListTile(
          title: Row(
            children: [
              Checkbox(
                value: done,
                onChanged: (newValue) {
                  updateTask(index, newValue!, varTitle, varDueDate);
                },
              ),
              Expanded(child: Text(varTitle)),
              Expanded(child: Text(varDueDate)),
              IconButton(
                icon: const Icon(Icons.edit,
                    color: Color.fromARGB(255, 0, 162, 255)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Edit Task'),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextField(
                            controller: editTaskController..text = varTitle,
                            decoration: InputDecoration(
                              hintText: varTitle,
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: editDueDateController
                              ..text = varDueDate,
                            decoration: InputDecoration(
                              hintText: varDueDate,
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            editTask(
                                context,
                                index,
                                done,
                                editTaskController.text.trim(),
                                editDueDateController.text.trim());
                          },
                          child: Text('Save',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 170, 0))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 223, 2, 2))),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete,
                    color: Color.fromARGB(255, 255, 0, 0)),
                onPressed: () {
                  deleteTask(index, varTask.objectId!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addTask() async {
    String task = taskController.text.trim();
    String dueDate = dueDateController.text.trim();
    if (task.isEmpty || dueDate.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter ${task.isEmpty ? 'Task!' : 'Due Date!'}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      var newTask = ParseObject('Task')
        ..set('title', task)
        ..set('dueDate', dueDate)
        ..set('done', false);

      var response = await newTask.save();

      if (response.success) {
        setState(() {
          tasks.add(newTask);
        });
        taskController.clear();
        dueDateController.clear();
      }
    }
  }

  Future<void> updateTask(
      int index, bool done, String varTitle, String varDueDate) async {
    final varTask = tasks[index];
    final String id = varTask.objectId.toString();

    var updatedTask = ParseObject('Task')
      ..objectId = id
      ..set('title', varTitle)
      ..set('dueDate', varDueDate)
      ..set('done', done);

    var response = await updatedTask.save();

    if (response.success) {
      setState(() {
        tasks[index] = updatedTask;
      });
    }
  }

  Future<void> editTask(
      context, int index, bool done, String varTitle, String varDueDate) async {
    final varTask = tasks[index];
    final String id = varTask.objectId.toString();

    var updatedTask = ParseObject('Task')
      ..objectId = id
      ..set('title', varTitle)
      ..set('dueDate', varDueDate)
      ..set('done', done);

    var response = await updatedTask.save();

    if (response.success) {
      setState(() {
        tasks[index] = updatedTask;
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> getTasks() async {
    var queryBuilder = QueryBuilder<ParseObject>(ParseObject('Task'));
    var apiResponse = await queryBuilder.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        tasks = apiResponse.results as List<ParseObject>;
      });
    }
  }

  Future<void> deleteTask(int index, String id) async {
    var deletedTask = ParseObject('Task')..objectId = id;
    var response = await deletedTask.delete();

    if (response.success) {
      setState(() {
        tasks.removeAt(index);
      });
    }
  }
}