import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'modalclass.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WatchData(),
    );
  }
}

class WatchData extends StatefulWidget {
  @override
  _WatchDataState createState() => _WatchDataState();
}

class _WatchDataState extends State<WatchData> {
  late String code;
  late Color tileColor;
  late Timer timer;
  bool showWarning = false;

  ScrollController _scrollController = ScrollController();
  double audioLevel = 0.0;
  double hrv = 0.0;
  double heartrate = 0;
  double spo2 = 0;
  List<HealthData> _healthDataList = [];

  Future<String> _loadHealthData() async {
    final response = await http.get(Uri.parse(
        'https://byqa2hsitf.execute-api.us-east-2.amazonaws.com/dev/displayVitalsMobile'));

    return response.body;
  }

  _buildHeartRateTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Heart Rate:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('${heartrate.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  _buildHRVTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('HRV:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('${hrv.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  _buildNoiseTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Noise:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('${audioLevel.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  _buildSpo2Tab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('SpO2:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('${spo2.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  Future<String> generateAndStoreCode() async {
    try {
      code = List.generate(4, (index) => Random().nextInt(10)).join();
      final headers = {'Content-Type': 'application/json'};

      // Create the request body
      final body = json.encode({'code': code});

      // Send the POST request to the API endpoint
      const url =
          'https://aax5u0nfg0.execute-api.us-east-2.amazonaws.com/dev/storecode';
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      // Check if the code was successfully stored
      if (response.statusCode == 200) {
        // Return the code if it was stored successfully
        return code;
      } else {
        // Handle the error if the code was not stored successfully
        throw Exception('Failed to store code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any other errors that may have occurred

      throw Exception('Failed to generate and store code');
    }
  }

  Future<void> _parseHealthData() async {
    String jsonString = await _loadHealthData();
    final jsonData = json.decode(jsonString);
    Map<String, dynamic> data = jsonDecode(jsonData['body']);
    audioLevel = data['audio_level'];
    hrv = data['hrv'];
    heartrate = data['heart_rate'];
    spo2 = data['oxygen_saturation'];

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    generateAndStoreCode();
    _parseHealthData();
    tileColor = Colors.red;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        tileColor = (tileColor == Colors.red) ? Colors.white : Colors.red;
      });
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // User has reached the end of the list, fetch new data
        _parseHealthData();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              bottom: const TabBar(
                tabs: [
                  Tab(
                    text: "Noise",
                  ),
                  Tab(
                    text: "HRV",
                  ),
                  Tab(
                    text: "Heart Rate ",
                  ),
                  Tab(
                    text: "SpO2",
                  )
                ],
              ),
            ),
            body: TabBarView(children: [
              _buildNoiseTab(),
              _buildHRVTab(),
              _buildHeartRateTab(),
              _buildSpo2Tab()
            ]),
          )),
    );
  }
}
