import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity;
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  } //

  //show dialog
  void _showDialog(String error_message,String error_text) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:  Text(error_message.toString()),
          content:  Text(error_text.toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
             FlatButton(
              child:  Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover, //
          image: AssetImage("assets/search.jpg"),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0, 
          title: Text("Search Page"),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: myController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "enter a city:",
                ),
                textAlign: TextAlign.center, //
                style: TextStyle(fontSize: 30),
              ),
            ),
            TextButton(
              onPressed: () async {
                var response = await http.get(
                    "https://www.metaweather.com/api/location/search/?query=${myController.text}");
                if (jsonDecode(response.body).isEmpty) {
                  print("null");
                  _showDialog("WARNING!", "City is not found.");
                } else {
                  Navigator.pop(context, myController.text);
                }
              },
              child: Text("send"),
            ),
          ],
        ),
      ),
    );
  }
}
