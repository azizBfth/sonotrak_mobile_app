import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sonotrak/models/events.dart';
import 'package:sonotrak/models/trips.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../models/position.dart';
import 'package:sonotrak/models/user.dart';
import 'package:sonotrak/providers/app_provider.dart';
import 'package:flutter/material.dart';
//import 'package:device/device.dart';
//import 'package:flutter_tracking_app/models/device.custom.dart';
//import 'package:flutter_tracking_app/models/user.model.dart';
//import 'package:flutter_tracking_app/providers/app_provider.dart';
//import 'package:flutter_tracking_app/traccar_client/src/models/position.dart';
//import 'package:flutter_tracking_app/utilities/constants.dart';
//import 'package:geopoint/src/models/geopoint.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:traccar_client/traccar_client.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
//import '../traccar_client/traccar_client.dart';

class TraccarClientService {
  final AppProvider appProvider;
  final _dio = Dio();

  late Device device;
  late Position position;
  late Event event;
  TraccarClientService({required this.appProvider});
  /*
   * @description Login Api
   */

  Future login(
      {required String username,
      required String password,
      rememberMe,
      required,
      required BuildContext context}) async {
    var url = '/https://tracking.emkatech.tn/api/session';
    var payLoad = Map<String, dynamic>();
    payLoad['email'] = username;
    payLoad['password'] = password;
    print(jsonEncode(payLoad));
    print("URL" + url);

    var response = await http.post(
      Uri.parse(
        'https://tracking.emkatech.tn/api/session',
      ),
      body: ({'email': username, 'password': password}),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      await Provider.of<AppProvider>(context, listen: false)
          .setLoggedIn(status: true);

      // print("this is my cookies ${response.headers["set-cookie"]![0]}");
      String cookie = response.headers["set-cookie"]!;
      print("cookie $cookie");

      User data =
          User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      print('userData:${data.administrator}');
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      appProvider.rememberMe = rememberMe;
      sharedPreferences.setString('kCookieKey', cookie);
      sharedPreferences.setString('username', username);
      sharedPreferences.setString('password', password);
      sharedPreferences.setBool('rememberMe', rememberMe);
      sharedPreferences.setBool('isAdministrator', data.administrator);

      sharedPreferences.setBool('loggedIn', true);
      appProvider.setCookie(apiCookie: cookie);
      // Provider.of<AppProvider>(context, listen: false).rememberMe = rememberMe;
      print('remember::$rememberMe');
      Provider.of<AppProvider>(context, listen: false)
          .setLoggedIn(status: true);
      Provider.of<AppProvider>(context, listen: false)
          .setResLoggedIn(res: true);
      print("data $data");

      Provider.of<AppProvider>(context, listen: false)
          .setIsAdmin(status: data.administrator);
      /*
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Succefull")));
*/

      Navigator.popAndPushNamed(context, '/home');
            print("okokokokok");

      return data;
    } else if (response.statusCode == 401) {
      print('formerrorApi401');
      Provider.of<AppProvider>(context, listen: false)
          .setResLoggedIn(res: true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Not Allowed !!')));
      Navigator.popAndPushNamed(context, '/home');
      //return jsonDecode(response.body);
    }
  }

  Future closeSession(
      {required String? username,
      required String? password,
      BuildContext? context}) async {
    var url = 'https://tracking.emkatech.tn/api/session';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await _dio.delete(url,
        options: Options(
          headers: {'authorization': basicAuth},
          contentType: "application/x-www-form-urlencoded",
          /* headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },*/
        ));
    if (response.statusCode == 204) {
      print('sessionClosed');
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      sharedPreferences.remove('username');
      sharedPreferences.remove('password');
      sharedPreferences.remove('kCookieKey');
      sharedPreferences.clear();

      Navigator.of(context!).pushNamed('/login');
      Provider.of<AppProvider>(context, listen: false)
          .setLoggedIn(status: false);
      Provider.of<AppProvider>(context, listen: false).setPositions([]);
      Provider.of<AppProvider>(context, listen: false).setDevices([]);
      Provider.of<AppProvider>(context, listen: false).clearMarkerss();
      Provider.of<AppProvider>(context, listen: false)
          .setResLoggedOut(res: false);
      sharedPreferences.setBool('loggedIn', false);
      Provider.of<AppProvider>(context, listen: false)
          .setLoggedIn(status: false);
    }
  }

  // Logout //
  logout({required BuildContext context}) async {
    appProvider.setLoggedIn(status: false);
    if (appProvider.rememberMe == false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //  prefs?.clear();
    }
    Navigator.popAndPushNamed(context, '/Login');
  }

  /*
   * @description Listen device-positions Stream emmitting by Websocket
   */

  Future<Stream> get getDevicePositionsStream async {
    // String cookie = appProvider.getCookie();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? cookie = sharedPreferences.getString('kCookieKey');
    print('cookie1 $cookie');
    print('appapp::${appProvider.isLoggedIn}');

    final streamController = StreamController<dynamic>.broadcast();
    final channel = IOWebSocketChannel.connect(
        "wss://tracking.emkatech.tn/api/socket",
        headers: {"Cookie": cookie});
    final posStream = channel.stream;
    late StreamSubscription raw;

    raw = posStream.listen((dynamic data) {
      final dataMap = jsonDecode(data.toString()) as Map<String, dynamic>;
      if (appProvider.isLoggedIn) {
        if (dataMap.containsKey('devices')) {
          print('socketRESdevices::');

          for (var d in dataMap['devices']) {
            device = Device.fromJson(d);
            /*
            NotificationService().showNotification(
                device.id!, device.name.toString().toUpperCase(),"PositionId:"+device.positionId.toString(), 10);
       */
          }

          streamController.sink.add(device);
        }
        if (dataMap.containsKey('events')) {
          print('socketRESevents::');

          for (var d in dataMap['events']) {
            event = Event.fromJson(d);
            String deviceName = appProvider.getDeviceNameById(event.deviceId);
            String notifType = '';
            print('socketRESevents::${event.type}');
          }

          streamController.sink.add(event);
        }
        if (dataMap.containsKey('positions')) {
          print('socketRESpositions::');

          for (var p in dataMap['positions']) {
            position = Position.fromJson(p);
            print('deviceID ${position.deviceId}');
            isPositionExist(position);

/*
          if( ! (appProvider.positions).contains(position) )
          appProvider.setPosition(position: position);
          else{
            final index = appProvider.positions.indexOf()
            
          }
*/
          }

          streamController.sink.add(position);
        }
      } else {
        channel.sink.close();
        print('channelClosed1');
      }
    });
    return streamController.stream;

    /* StreamSubscription<dynamic> rawPosSub;
    final streamController = StreamController<Device>.broadcast();
    rawPosSub = posStream.listen((dynamic data) {
      final dataMap = jsonDecode(data.toString()) as Map<String, dynamic>;
      print('socket $dataMap');
      if (dataMap.containsKey("positions")) {
        //DevicePosition pos;
        Device device;
        for (final posMap in dataMap["positions"]) {
          //  pos = DevicePosition.fromJson(posMap as Map<String, dynamic>);
          //device = Device.fromPosition(posMap as Map<String, dynamic>);
          device = Device.fromJson(posMap);
        }
        //  device.position = pos as GeoPoint ;
        // streamController.sink.add(device);
      }
    });
    return streamController.stream;*/
  }

  // Get All Users //
  Future<List<User>> getUsers() async {
    String cookie = await getCookie();
    String uri = "https://tracking.emkatech.tn/api/users";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );

    if (response.statusCode == 200) {
      final users = <User>[];

      for (final data in response.data) {
        var item = User.fromJson(data as Map<String, dynamic>);
        users.add(item);
      }
      appProvider.setUsers(users);

      return users;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  // Get All Devices of current User //
  Future<List<Device>> getDevices() async {
    String cookie = await getCookie();
    String uri = "https://tracking.emkatech.tn/api/devices";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );

    if (response.statusCode == 200) {
      final devices = <Device>[];
      String devicesIds = '';
      List<int> _allDevicesIds = [];
      int index = 0;
      for (final data in response.data) {
        var item = Device.fromJson(data as Map<String, dynamic>);
        devices.add(item);
        _allDevicesIds.add(item.id!);
        devicesIds += 'deviceId=' + item.id.toString() + '&';
      }
      String result = devicesIds.substring(0, devicesIds.length - 1);
      appProvider.setDevices(devices);
      print('devicesIds::$result');
      appProvider.setDevicesIds(result);
      appProvider.setAllDevicesIds(_allDevicesIds);
      return devices;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  Future<List<Device>> getUserDevices(int userId) async {
    String cookie = await getCookie();
    String uri =
        "https://tracking.emkatech.tn/api/devices?userId=" + userId.toString();
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );

    if (response.statusCode == 200) {
      final userDevices = <Device>[];
      List<int> _userDevicesIds = [];

      for (final data in response.data) {
        var item = Device.fromJson(data as Map<String, dynamic>);
        userDevices.add(item);
        _userDevicesIds.add(item.id!);
      }
      appProvider.setUserDevices(userDevices);
      appProvider.setUserDevicesIds(_userDevicesIds);

      return userDevices;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  Future<List<Position>> getPositions() async {
    String cookie = await getCookie();
    String uri = "https://tracking.emkatech.tn/api/positions";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );

    if (response.statusCode == 200) {
      final Positions = <Position>[];

      int index = 0;
      for (final data in response.data) {
        var item = Position.fromJson(data as Map<String, dynamic>);
        Positions.add(item);
      }

      appProvider.setPositions(Positions);

      return Positions;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  Future<Position> getPositionInfo({required int positionId}) async {
    String cookie = await getCookie();
    String uri = "https://tracking.emkatech.tn/api/positions";
    final queryParameters = <String, dynamic>{"id": positionId};
    var response = await Dio().get(
      uri,
      queryParameters: queryParameters,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );
    if (response.statusCode == 200) {
      Position position = Position.fromJson(response.data[0]);
      print('positionPos::${response.data[0]}');
      return position;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  // Get All Devices of current User //
  Future<List<Device>> getDeviceLatestPositions() async {
    String cookie = await getCookie();
    print('cookie $Cookie');

    String uri = "https://tracking.emkatech.tn/api/positions";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );
    if (response.statusCode == 200) {
      final devices = <Device>[];
      for (final data in response.data) {
        var item = Device.fromJson(data as Map<String, dynamic>);
        devices.add(item);
      }
      return devices;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  // Get Api Cookie //
  static Future<String> getCookie() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? cookie = sharedPreferences.getString('kCookieKey');
    if (cookie == null) {
      //  final trac = await getTraccarInstance();
      // cookie = trac.query.cookie;
      sharedPreferences.setString('kCookieKey', cookie!);
    }
    return cookie;
  }

  isPositionExist(Position position) {
    final int data = appProvider.getPositions
        .indexWhere((row) => row.deviceId == position.deviceId);
    print("dataIndex:: $data");
    if (data >= 0) {
      print("changed: $data");
      appProvider.replacePosition(index: data, position: position);
//      return true;
    } else {
      //    return false;
      appProvider.addPosition(position: position);
    }
  }

  /*
   * @description Get Traccar Instance
   */
  /*
  static Future<Traccar> getTraccarInstance() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userToken = sharedPreferences.getString(kTokenKey);
    final trac =
        Traccar(serverUrl: serverUrl, userToken: userToken, verbose: true);
    unawaited(trac.init());
    await trac.onReady;
    return trac;
  }
*/
  /*
   * @description Get Device Routes
   */

  // @description date conversion //
  String _formatDate(DateTime date) {
    final d = date.toIso8601String().split(".")[0];
    final l = d.split(":");
    return "${l[0]}:${l[1]}:00Z";
  }

  // @description Get SinglePosition
  static Future<Device> getPositionFromId({required int positionId}) async {
    String cookie = await getCookie();
    String uri = "https://tracking.emkatech.tn/api/positions";
    final queryParameters = <String, dynamic>{"id": positionId};
    var response = await Dio().get(
      uri,
      queryParameters: queryParameters,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );
    if (response.statusCode == 200) {
      Device devicePosition = Device.fromJson(response.data[0]);
      return devicePosition;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  // @description Get Single Device Info
  static Future<Device> getDeviceInfo({required int deviceId}) async {
    String cookie = await getCookie();
    String uri = "https://tracking.emkatech.tn/api/devices";
    final queryParameters = <String, dynamic>{"id": deviceId};
    var response = await Dio().get(
      uri,
      queryParameters: queryParameters,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );
    if (response.statusCode == 200) {
      Device deviceInfo = Device.fromJson(response.data[0]);
      return deviceInfo;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  // @description Refresh session cookie of monarchtrack server
  static Future<String> getMonarchTrackServerCookie() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? rawCookie = sharedPreferences.getString("kMonarchTrackCookieKey");
    if (rawCookie == null) {
      var url = 'https://tracking.emkatech.tn/api/session';
      var payLoad = jsonEncode({
        'username': sharedPreferences.getString('username'),
        'password': sharedPreferences.getString('password'),
      });
      try {
        var response = await http.post(
          Uri.parse(url),
          body: payLoad,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: 'application/json',
          },
        );
        String rawCookie = response.headers["set-cookie"] as String;
        return rawCookie;
      } catch (error) {
        throw Exception(error);
      }
    }
    return rawCookie;
  }
}
