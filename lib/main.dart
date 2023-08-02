
import 'dart:io';
import 'package:sonotrak/providers/app_provider.dart';
import 'package:sonotrak/providers/connectivity_provider.dart';
import 'package:sonotrak/providers/language.dart';
import 'package:sonotrak/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonotrak/screens/Home.dart';
import 'package:sonotrak/utils/class_builder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

late String? language = 'FR';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SharedPreferences.getInstance().then((instance) {
    language = instance.getString('language');
  WidgetsFlutterBinding.ensureInitialized();
      
    ClassBuilder.registerClasses();
    runApp(MyApp());
    HttpOverrides.global = MyHttpOverrides();
 });
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context   ) {
    return MultiProvider(                                                                                                                                                                                                                                                  
      providers: [
        ChangeNotifierProvider(                                                                                                
          create: (context) => Language(),
          child: Home(),
        ), 
        ChangeNotifierProvider(
          create: (context) => AppProvider(),
          child: Home(),
        ),
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(),
          child: Home(),
        ),
   
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'sonotrak',
        localizationsDelegates: const [
        // ... app-specific localization delegate[s] here+
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        Locale.fromSubtags(
            languageCode: 'fr'), // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
        theme: ThemeData(
          // This is the theme of your application.
          // Try running your application with "flutter run". You'll see th
          // application has a blue toolbar. Then , without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
         
          primarySwatch: Colors.blue,

        ),
        initialRoute: '/loadingSpin',
        //   initialRoute: Provider.of<SessionProvider>(context, listen: false).loading ? '/home' : '/',
        onGenerateRoute: routeGenerator.generateRoute,
      ),
    );
  }
}
 class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient  (SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}