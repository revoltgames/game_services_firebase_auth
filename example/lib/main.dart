import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_services_firebase_auth/game_services_firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  bool success = false;
  Object? error;

  @override
  void initState() {
    super.initState();
    testLogin();
  }

  Future<void> testLogin() async {
    setState(() {
      loading = true;
    });
    try {
      success = await GameServicesFirebaseAuth.signInWithGameService();
      setState(() {});
    } catch (e) {
      error = e;
    } finally {
      setState(() {
        loading = false;
        success = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auth test'),
        ),
        body: Column(
          children: [
            Text('Loading: $loading'),
            Text('Error: $error'),
            if (!loading) ...[
              Text('Success: $success'),
              Text('Error: $error'),
            ]
          ],
        ),
      ),
    );
  }
}
