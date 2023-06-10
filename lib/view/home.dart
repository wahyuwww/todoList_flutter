import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_list/controller/Controller.dart';
import 'package:todo_list/model/todo.dart';
import 'package:get/get.dart';

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.lightBlueAccent,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<AnimatedListState> _todoListStateKey =
      GlobalKey<AnimatedListState>();
  final MyController controller = Get.put(MyController());
  // List<Todo> todoList = [];
  late final Isar _isar;
  @override
  void initState() {
    getTodos();
    super.initState();
  }

  getTodos() async {
    final _dir = await getApplicationDocumentsDirectory();
    // ignore: no_leading_underscores_for_local_identifiers
    _isar = await Isar.open([TodoSchema], directory: _dir.path);
    controller.todoList = await _isar.todos.where().findAll();
    print("COBAINI ${controller.todoList}");
    for (int i = 0; i < controller.todoList.length; i++) {
      _todoListStateKey.currentState?.insertItem(i);
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  // ADD TODOLIST
  addTodo(String title) async {
    _todoListStateKey.currentState?.insertItem(controller.todoList.length);
    controller.todoList.add(Todo(title));
    print("testetst ${title} ${controller.todoList.obs}");
    // update();
    await _isar.writeTxn(() async {
      await _isar.todos.put(controller.todoList.last);
    });
  }

  // DELETE TODOLIST
  void deleteTodo(int index) async {
    Todo removedTodo = controller.todoList.removeAt(index);
    print("iniprint ${removedTodo}");
    _todoListStateKey.currentState?.removeItem(
      index,
      (context, _) => controller.removeListTile(removedTodo.title),
    );
    await _isar.writeTxn(() async {
      await _isar.todos.delete(index);
    });
  }

  Widget listTile(BuildContext context, int index) {
    // ignore: avoid_print
    MyController controller = Get.find();
    print("CEKTITLE ${controller.todoList[index].title}");
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: Offset(3, 3),
              blurRadius: 6),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Obx(() {
          //   return Column(
          //     children: [Text(controller.todoList[index].title)],
          //   );
          // }),
          Text(controller.todoList[index].title),
          Row(
            children: <Widget>[
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String newTitle = "";
                        return StatefulBuilder(builder: (context, setState2) {
                          print("IDEN ${index} ${newTitle}");
                          return AlertDialog(
                            title: const Text("Edit Todo"),
                            content: TextFormField(
                              autofocus: true,
                              initialValue: controller.todoList[index].title,
                              decoration:
                                  const InputDecoration(hintText: "Input name"),
                              onChanged: (val) {
                                setState2(() {
                                  newTitle = val;
                                });
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: (newTitle.isEmpty)
                                    ? null
                                    : () => controller
                                        .editTodo(index, newTitle)
                                        .then(
                                            (value) => Navigator.pop(context)),
                                child: const Text("Edit"),
                              ),
                            ],
                          );
                        });
                      },
                    );
                  },
                  icon: Icon(Icons.edit_document),
                  color: Colors.green),
              IconButton(
                  onPressed: () {
                    deleteTodo(index);
                  },
                  icon: Icon(Icons.delete),
                  color: Colors.red)
            ],
          )
        ],
      ),
    );
  }

  void addTodoDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        String title = "";
        print("tittle${title}");
        return StatefulBuilder(builder: (context, setState2) {
          return AlertDialog(
            title: const Text("Add Todo"),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: "Input name"),
              onChanged: (val) {
                setState2(() {
                  title = val;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: (title.isEmpty)
                    ? null
                    : () =>
                        addTodo(title).then((value) => Navigator.pop(context)),
                child: const Text("Add"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("CEKVALUE ${controller.count.value}");
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Example Todo List")),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodoDialogBox,
        child: const Icon(Icons.add),
      ),
      body: AnimatedList(
        key: _todoListStateKey,
        initialItemCount: controller.todoList.length,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        itemBuilder: (context, index, _) {
          return listTile(context, index);
        },
      ),
    );
  }
}
