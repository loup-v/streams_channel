//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

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
  StreamSubscription<dynamic> _subscriptionA;
  StreamSubscription<dynamic> _subscriptionB;

  void _start(bool a) {
    // ignore: cancel_subscriptions
    StreamSubscription<dynamic> subscription =
        a ? _subscriptionA : _subscriptionB;

    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    } else {
      final streamId = 'Stream ${a ? 'A' : 'B'}';
      subscription = testChannel
          .receiveBroadcastStream(streamId)
          .listen((data) => debugPrint('Received from $streamId: $data'));

      subscription.onDone(() {
        setState(() {
          if (a) {
            _subscriptionA = null;
          } else {
            _subscriptionB = null;
          }
        });
      });
    }

    setState(() {
      if (a) {
        _subscriptionA = subscription;
      } else {
        _subscriptionB = subscription;
      }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new FlatButton(
                onPressed: () => _start(true),
                child: Text(_subscriptionA != null ? 'Stop A' : 'Start A'),
              ),
              new FlatButton(
                onPressed: () => _start(false),
                child: Text(_subscriptionB != null ? 'Stop B' : 'Start B'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
