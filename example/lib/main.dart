import 'dart:async';

import 'package:flutter/material.dart';
import 'package:streams_channel/streams_channel.dart';

final StreamsChannel testChannel = new StreamsChannel('streams_channel_test');

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<dynamic> _subscription;
  int _id = 0;

  void _onPressed() {
    // ignore: cancel_subscriptions
    StreamSubscription<dynamic> subscription;

    if (_subscription != null) {
      _subscription.cancel();
    } else {
      final id = ++_id;
      subscription = testChannel
          .receiveBroadcastStream('stream $id')
          .listen((data) => debugPrint('Received from $id: $data'));
    }

    setState(() {
      _subscription = subscription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Demo'),
        ),
        body: new Center(
          child: new FlatButton(
            onPressed: _onPressed,
            child: Text(_subscription != null ? 'Stop' : 'Start'),
          ),
        ),
      ),
    );
  }
}
