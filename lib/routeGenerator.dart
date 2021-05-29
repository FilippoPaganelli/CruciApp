import 'package:flutter/material.dart';
import 'home/home.dart';
import 'cw/cw.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final List args = routeSettings.arguments;

    switch (routeSettings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/cw':
        return MaterialPageRoute(
            builder: (_) => CWPage(args[0], args[1], args[2]));
      // args[0], args[1], args[2] are cwNumber, rows and cols
      default:
        return _errorPage();
    }
  }

  static Route<dynamic> _errorPage() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[800],
          title: Text(
            'Error!',
            style: TextStyle(fontSize: 25),
          ),
        ),
        body: Center(
          child: Text(
            'ERROR',
            style: TextStyle(fontSize: 30),
          ),
        ),
      );
    });
  }
}
