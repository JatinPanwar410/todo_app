import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/add_todo.dart';
import 'package:http/http.dart' as http;

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Todo List"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: fetchTodo,
              child: Visibility(
                visible: items.isNotEmpty,
                replacement: Center(child: LottieBuilder.asset('assets/lottie/Animation - 1724156944295.json',height: 250,width: 250,),),
                child: ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final id = item['_id'] as String;
                      return Dismissible(
                        onDismissed: (DismissDirection direction) {
                          deleteById(id);
                        },
                        key: ValueKey(id),
                        background: Container(
                          color: Colors.red,
                          child: const Icon(Icons.delete),
                        ),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                                backgroundColor: Colors.grey[900],
                                child: Text(
                                  "${index + 1}",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                  ),
                                )),
                            title: Text(
                              item['title'],
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              item['description'],
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                            ),
                            trailing: IconButton(
                              onPressed: () async{
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTodoScreen(
                                        todo: item,
                                      ),
                                    ));
                                if(result == true){
                                  fetchTodo();
                                }
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[600],
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTodoScreen(),
              ));
          if(result == true){
            fetchTodo();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true;
    });
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map;
        final result = json['items'] as List;
        setState(() {
          items = result;
        });
      } else {
        showError('Failed to load todos');
      }
    } catch (e) {
      showError('An error occurred');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> deleteById(String id) async {
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        final filtered =
            items.where((element) => element['_id'] != id).toList();
        setState(() {
          items = filtered;
        });
      } else {
        showError('Failed to delete todo');
      }
    } catch (e) {
      showError('An error occurred');
    }
  }
}
