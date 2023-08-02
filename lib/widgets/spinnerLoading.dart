import 'package:sonotrak/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonotrak/apis/api_services.dart';

class LoadingSpin extends StatefulWidget {
  const LoadingSpin({Key? key}) : super(key: key);

  @override
  _LoadingSpinState createState() => _LoadingSpinState();
}

class _LoadingSpinState extends State<LoadingSpin> {
  late AppProvider _appProvider;
  @override
  void initState() {
    super.initState();
    getSharedPrefrences().then((data) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Provider.of<AppProvider>(context, listen: false).getLoggedIn();

        //print(' isLogging ${Provider.of<AppProvider>(context, listen: false).getLoggedIn}');

        //  TraccarClientService(appProvider: _appProvider).getDevicePositionsStream();
      });
    });
  }

  Future getSharedPrefrences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // print('rem::${sharedPreferences.getBool('rememberMe')}');
    //print('rem::${sharedPreferences.getBool('loggedIn')}');

    if (sharedPreferences.getBool('loggedIn') == true &&
        sharedPreferences.getBool('rememberMe') == true) {
      String username = sharedPreferences.getString('username')!;
      String password = sharedPreferences.getString('password')!;
      try {
        await TraccarClientService(appProvider: _appProvider).login(
            username: username,
            password: password,
            rememberMe: true,
            context: context);
      } catch (error) {
        print("error lLog In");
      }

      // Navigator.of(context).pushNamed('/home');
    } else {
         try {
        await TraccarClientService(appProvider: _appProvider).login(
            username: "sonotrak",
            password: "sonotrak",
            rememberMe: true,
            context: context);
                 // Navigator.of(context).pushNamed('/home');

      } catch (error) {
        print("error lLog In");
      }
    }

    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    return WillPopScope(
        onWillPop: () async => false,
        child: const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SpinKitFadingFour(
              color: Colors.blue,
              size: 50.0,
            ),
          ),
        ));
  }
}
