import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('activityBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
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
  String activity = "Press 'Next' to generate random activity";
  String price = "";
  List<Map<String, String>> history = [];
  String? selectedType;
  final List<String> activityTypes = [
    'education', 'recreational', 'social', 'diy', 'charity',
    'cooking', 'relaxation', 'music', 'busywork'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    var box = Hive.box('activityBox');
    setState(() {
      selectedType = box.get('selectedType');
      history = List<Map<String, String>>.from(box.get('history', defaultValue: []));
    });
  }

  Future<void> _savePreferences() async {
    var box = Hive.box('activityBox');
    await box.put('selectedType', selectedType);
    await box.put('history', history);
  }

  Future<void> fetchActivity() async {
    String url = 'https://bored.api.lewagon.com/api/activity';
    if (selectedType != null && selectedType!.isNotEmpty) {
      url = 'https://bored.api.lewagon.com/api/activity?type=${Uri.encodeComponent(selectedType!)}';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        activity = data['activity'];
        price = "Price: \$${data['price'].toString()}";
        history.insert(0, {'activity': activity, 'price': price, 'type': data['type']});
        if (history.length > 50) {
          history.removeLast();
        }
      });
      _savePreferences();
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
      appBar: AppBar(title: Text('Technical Assessment'),backgroundColor: Colors.green,),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedType,
                hint: Text('Select Activity Type'),
                items: activityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                  _savePreferences();
                },
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
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
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
                child: Text('History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
