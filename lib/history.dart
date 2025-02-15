import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    var box = Hive.box('activityBox');
    setState(() {
      history = (box.get('history') as List?)
              ?.map((e) => Map<String, String>.from(e))
              .toList() ??
          [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History'),backgroundColor: Colors.green,),
      body: history.isEmpty
          ? Center(child: Text('No history available'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(history[index]['activity']!),
                  subtitle: Text(history[index]['price']!),
                );
              },
            ),
    );
  }
}
