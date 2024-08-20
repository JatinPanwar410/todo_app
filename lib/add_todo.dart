import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/model/todo_model.dart';


class AddTodoScreen extends StatefulWidget {
  AddTodoScreen({super.key, this.todo});
  Map? todo;

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final desc = todo['description'];
      titleController.text = title;
      descController.text = desc;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(isEdit? "Edit Todo" : "Add Todo"),
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 15
        ),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Title",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(18)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(18)
                ),
              ),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Description",
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(18)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(18)
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    )
                  ),
                  onPressed: (){
                    isEdit?
                    updateData():
                    submitData();
                  }, child: Text(isEdit ? "Update Task":"Add Task",style: GoogleFonts.montserrat(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),)),
            )
          ],
        ),
      )
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("Update not done");
      return;
    }

    final id = todo["_id"];
    final title = titleController.text;
    final desc = descController.text;
    final body = Items(
      title: title,
      description: desc,
      isCompleted: false,
    );

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
        uri,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json'
        }
    );

    if (response.statusCode == 200) {
      // Success
      Navigator.pop(context, true);
      showMessage('Update Success');
    } else if (response.statusCode == 500) {
      // Server Error
      showMessage("Server Error: Please try again later.");
      print(response.statusCode);
      print(response.body);
    } else {
      // Other errors
      showMessage("Update Failed");
      print(response.statusCode);
      print(response.body);
    }

  }

  Future<void> submitData() async {
    //Get the data from the server                            
    final title = titleController.text;
    final desc = descController.text;
    final body = Items(
      title: title,
      description: desc,
      isCompleted: false,
    );

    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type' : 'application/json'
      }
    );

    if(response.statusCode == 201){
      titleController.text="";
      descController.text="";
      Navigator.pop(context, true);
      showMessage('Creation Success');
    }else{
      showMessage("Creation Failed");
    }

  }

  void showMessage(String message){
    final snakBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snakBar);
  }
}
