import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '누가 마실래?',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: '누가 마실래?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum Wheel { top, bottom }

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late FirebaseAnalytics analytics;
  late AnimationController _controller;
  late AnimationController _controller2;

  bool _spinningFirst = false;
  int _start = 10;
  int _current = 10;
  int _angleWeight = 1;

  List<String> _result = ['누가', '마실래?'];
  Map<Wheel, List<String>> _wheelTexts = {
    Wheel.top: [
      '내가',
      '내 오른쪽이',
      '내가 지목한 사람이',
      '내 왼쪽이',
    ],
    Wheel.bottom: [
      '원샷!',
      '투샷!',
      '패스!',
      '반샷!',
    ]
  };

  @override
  void initState() {
    super.initState();

    analytics = FirebaseAnalytics();

    // Duration 동안 controller.value가 0부터 1까지 늘어남
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 20),
            _buildResultText(),
            Text(
              '▼',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            _buildTopWheel(),
            SizedBox(height: 20),
            Text('▼',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            _buildBottomWheel(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Expanded _buildResultText() {
    return Expanded(
      child: Text(
        _result[0] + ' ' + _result[1],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Expanded _buildTopWheel() {
    return Expanded(
      flex: 4,
      child: AnimatedBuilder(
        animation: _controller,
        child: TextButton(
          onPressed: () {
            analytics.logEvent(name: 'click_first_roulette');
            _spinAndSetResult(_controller, Wheel.top);
          },
          child: Image.asset(
            'images/roulette_1.png',
            fit: BoxFit.cover,
          ),
        ),
        builder: (BuildContext context, Widget? _widget) {
          // math.pi = 180 degree
          return new Transform.rotate(
            angle: pi * _controller.value * 2,
            child: _widget,
          );
        },
      ),
    );
  }

  Expanded _buildBottomWheel() {
    return Expanded(
      flex: 4,
      child: AnimatedBuilder(
        animation: _controller2,
        child: TextButton(
          onPressed: () {
            analytics.logEvent(name: 'click_second_roulette');
            _spinAndSetResult(_controller2, Wheel.bottom);
          },
          child: Image.asset(
            'images/roulette_2.png',
            fit: BoxFit.cover,
          ),
        ),
        builder: (BuildContext context, Widget? _widget) {
          // math.pi = 180 degree
          return new Transform.rotate(
            angle: pi * _controller2.value * 2,
            child: _widget,
          );
        },
      ),
    );
  }

  void _spinAndSetResult(AnimationController controller, Wheel wheel) {
    controller.repeat();

    var stopTime = Random().nextInt(2000) + 500;
    print("[$wheel] stopTIme: " + stopTime.toString());

    Timer(
      Duration(milliseconds: stopTime),
      () {
        controller.stop();

        print("[$wheel] STOP: " + controller.value.toString());
        print("[$wheel] STOP: " + (pi * controller.value * 2).toString());

        setState(
          () {
            if (_result[0].isNotEmpty && _result[1].isNotEmpty) {
              _result[0] = '';
            }
            if (_result[1].isNotEmpty) {
              _result[1] = '';
            }
            if (controller.value < 0.25) {
              _result[wheel.index] = _wheelTexts[wheel]![0];
            } else if (controller.value < 0.5) {
              _result[wheel.index] = _wheelTexts[wheel]![1];
            } else if (controller.value < 0.75) {
              _result[wheel.index] = _wheelTexts[wheel]![2];
            } else {
              _result[wheel.index] = _wheelTexts[wheel]![3];
            }
            if (_result[1] == '패스!') _result[0] = '';
          },
        );
      },
    );
  }
}
