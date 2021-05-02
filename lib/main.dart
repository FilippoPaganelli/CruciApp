import 'package:cruciapp/home/home.dart';
import 'package:flutter/material.dart';
import 'routeGenerator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // ROOT
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CruciApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
