// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:todo_list/model/todo.dart';

class MyController extends GetxController {
  final GlobalKey<AnimatedListState> _todoListStateKey =
      GlobalKey<AnimatedListState>();
  final count = 0.obs;
  increment() => count.value++;

  late final Isar _isar;
  late List<Todo> todoList = [];

  Widget removeListTile(String title) {
    return Container();
  }

  List text = ["item 1", "item 2", "item 3"];

  void addItem(int index) {
    text.add('item ${index}');
    update();
  }

  editTodo(int index, String newTitle) async {
    print("PAPAPA ${index} ${newTitle} ${todoList[index]}");
    todoList[index].title = newTitle;
    _todoListStateKey.currentState?.setState(() {});
    await _isar.writeTxn(() async {
      await _isar.todos.put(todoList[index]);
    });
  }
}
