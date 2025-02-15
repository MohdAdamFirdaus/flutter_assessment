import 'package:flutter/material.dart';
import 'package:hendshake_technical_assessment/history.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Next Button',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String activity = "Press 'Next' to get an activity";
  String price = "";
  List<Map<String, String>> history = [];

  Future<void> fetchActivity() async {
    final response = await http.get(Uri.parse('https://bored.api.lewagon.com/api/activity'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        activity = data['activity'];
        price = "Price: \$${data['price'].toString()}";
        history.insert(0, {'activity': activity, 'price': price});
        if (history.length > 50) {
          history.removeLast();
        }
      });
    } else {
      setState(() {
        activity = 'Failed to load activity';
        price = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    activity,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    price,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: fetchActivity,
              child: Text('Next'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen(history: history)),
                );
              },
              child: Text('History'),
            ),
          ],
        ),
      ),
    );
  }
}


