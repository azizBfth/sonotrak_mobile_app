import 'package:sonotrak/models/device.dart';
import 'package:sonotrak/models/events.dart';
import 'package:sonotrak/models/user.dart';

import 'package:flutter/material.dart';
import 'package:sonotrak/screens/DeviceMapTracking.dart';
import 'package:sonotrak/screens/Schedule.dart';
import 'package:sonotrak/screens/details.dart';

import '../screens/Home.dart';
import '../widgets/spinnerLoading.dart';

class routeGenerator {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    final args = setting.arguments;
    switch (setting.name) {
       case '/loadingSpin':
        return MaterialPageRoute(builder: (_) => LoadingSpin());
         case '/home':
        return MaterialPageRoute(builder: (_) => Home());
        case '/schedule':
        return MaterialPageRoute(builder: (_) => Schedule());
         case 'deviceMapTracking':
        return MaterialPageRoute(builder: (_) => DeviceMapTracking());
        case 'timetabledetails':
        return MaterialPageRoute(builder: (_) => DetailsScreen());
    
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}

var routes = <String, WidgetBuilder>{
  '/home': (context) =>  Home(),
 
// '/devicesDetails': (context) => DevicesDetails()
};
