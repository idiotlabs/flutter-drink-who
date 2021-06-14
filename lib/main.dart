import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:async';
import 'package:quiver/async.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = Crashlytics.instance.recordFlutterError;

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
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  FirebaseAnalytics analytics;

  AnimationController _controller;
  AnimationController _controller2;

  bool _spinningFirst = false;
  int _start = 10;
  int _current = 10;
  int _angleWeight = 1;

  String _textFull = '누가 마실래?';
  String _textFirst = '';
  String _textSecond = '';

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
            Padding(padding: EdgeInsets.all(10.0),),
            Expanded(
              child: Text(
                _textFull,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('▼', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            // image
            Expanded(
              flex: 4,
              child: AnimatedBuilder(
                animation: _controller,
                child: FlatButton(
                  onPressed: () {
                    analytics.logEvent(name: 'click_first_roulette');

                    _controller.repeat();

                    var stopTime = Random().nextInt(2000) + 500;
                    print("stopTIme: " + stopTime.toString());

                    Timer(Duration(milliseconds: stopTime), () {
                      _controller.stop();

                      print("STOP: " + _controller.value.toString());
                      print("STOP: " + (pi * _controller.value * 2).toString());

                      setState(() {
                        if (_textFirst != '' && _textSecond != '') {
                          _textSecond = '';
                        }

                        if (_textSecond == '패스!') {
                          _textSecond = '';
                        }

                        if (_controller.value < 0.25) {
                          _textFirst = '내가';
                        }
                        else if (_controller.value < 0.5) {
                          _textFirst = '내 오른쪽이';
                        }
                        else if (_controller.value < 0.75) {
                          _textFirst = '내가 지목한 사람이';
                        }
                        else {
                          _textFirst = '내 왼쪽이';
                        }

                        _textFull = _textFirst + ' ' + _textSecond;
                      });
                    });
                  },
                  child: Image.asset(
                    'images/roulette_1.png',
                    fit: BoxFit.cover,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                builder: (BuildContext context, Widget _widget) {
                  // math.pi = 180 degree
                  return new Transform.rotate(
                    angle: pi *  _controller.value * 2,
                    child: _widget,
                  );
                },
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0),),
            Text('▼', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            // image
            Expanded(
              flex: 4,
              child: AnimatedBuilder(
                animation: _controller2,
                child: FlatButton(
                  onPressed: () {
                    analytics.logEvent(name: 'click_second_roulette');

                    _controller2.repeat();

                    var stopTime = Random().nextInt(2000) + 500;
                    print("[2] stopTIme: " + stopTime.toString());

                    Timer(Duration(milliseconds: stopTime), () {
                      _controller2.stop();

                      print("[2] STOP: " + _controller2.value.toString());
                      print("[2] STOP: " + (pi * _controller2.value * 2).toString());

                      setState(() {
                        if (_textFirst != '' && _textSecond != '') {
                          _textFirst = '';
                        }

                        if (_controller2.value < 0.25) {
                          _textSecond = '원샷!';
                        }
                        else if (_controller2.value < 0.5) {
                          _textSecond = '투샷!';
                        }
                        else if (_controller2.value < 0.75) {
                          _textFirst = '';
                          _textSecond = '패스!';
                        }
                        else {
                          _textSecond = '반샷!';
                        }

                        _textFull = _textFirst + ' ' + _textSecond;
                      });
                    });
                  },
                  child: Image.asset(
                    'images/roulette_2.png',
                    fit: BoxFit.cover,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                builder: (BuildContext context, Widget _widget) {
                  // math.pi = 180 degree
                  return new Transform.rotate(
                    angle: pi *  _controller2.value * 2,
                    child: _widget,
                  );
                },
              ),
            ),
            Padding(padding: EdgeInsets.all(20.0),),
          ],
        ),
      ),
    );
  }
}
