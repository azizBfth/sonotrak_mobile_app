import 'dart:io';
import 'dart:typed_data';

import 'package:sonotrak/apis/api_services.dart';
import 'package:sonotrak/apis/api_sonotrak.dart';
import 'package:sonotrak/models/Timetable.dart';

import 'package:sonotrak/models/device.dart';
import 'package:sonotrak/models/events.dart';
import 'package:sonotrak/models/position.dart';

import 'package:sonotrak/models/trips.dart';
import 'package:sonotrak/models/user.dart';
import 'package:latlong2/latlong.dart' as latlong2;

//import 'package:device/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
//import 'package:flutter_tracking_app/models/device.custom.dart';
//import 'package:flutter_tracking_app/models/user.model.dart';
//import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:traccar_client/traccar_client.dart';
//import '../traccar_client/traccar_client.dart';
import 'dart:ui' as ui;

import '../helper/map_marker.dart';


class AppProvider with ChangeNotifier {
  late bool isLoggedIn = false;
  late bool isAdministrator = false;

  late bool isResLoggedIn = false;
  late bool isResLoggedOut = false;

  int homeActiveTabIndex = 2;
  // User user = new User();
  late User user;
  List<Device> _devices = [];
    List<TimeTable> _timetable = [];

  List<Device> _userDevices = [];

  List<User> _users = [];

  List<Event> _events = [];
  List<Position> _todayTrip = [];

  List<Trips> _trips = [];

  late String _apiCookie = "";
  late bool rememberMe = false;
  List<Position> _positions = [];

  late List<LatLng> latlngPoly = [];
  Set<Polyline> _polylines = Set();
  Set<Polyline> _trackMarkerPolyline = Set();

  late BitmapDescriptor _pinLocationIcon;
  late BitmapDescriptor _pinLocationIconMove;
  late Set<Marker> _stopsMarkers = Set();
  Set<Marker> get stopsMarkers => _stopsMarkers;

  late Set<Marker> _eventMarker = Set();
  Set<Marker> get eventMarker => _eventMarker;
  late Position _selectedEventPosition;
  Position get selectedEventPosition => _selectedEventPosition;
  late Set<Marker> _markerss = Set();
  Set<Marker> get markerss => _markerss;
  late Set<Marker> _markertoSuivi = Set();
  Set<Marker> get markersToSuivi => _markertoSuivi;

  late Set<Marker> _markerStartEndTrips = Set();
  Set<Marker> get markerStartEndTrips => _markerStartEndTrips;

  LatLng _centerToSuivi = LatLng(35, 9);
  LatLng get centerToSuivi => _centerToSuivi;
  LatLng _eventMapCenter = LatLng(35, 9);
  LatLng get eventMapCenter => _eventMapCenter;
  LatLng _centerFirstStop = LatLng(35, 9);
  LatLng get centerFirstStop => _centerFirstStop;
  LatLng _centerTodayTrip = LatLng(35, 9);
  LatLng get centerTodayTrip => _centerTodayTrip;
  late LatLng minBounds;
  late LatLng maxBounds;

  late LatLngBounds _latLngBounds =
      LatLngBounds(southwest: LatLng(35, 9), northeast: LatLng(35, 10));
  LatLngBounds get latLngBounds => _latLngBounds;

  late LatLngBounds _stopsLatLngBounds =
      LatLngBounds(southwest: LatLng(35, 9), northeast: LatLng(35, 10));
  LatLngBounds get stopsLatLngBounds => _stopsLatLngBounds;

  late Map<MarkerId, Marker> _markers;
  Map<MarkerId, Marker> get markers => _markers;
  List points = [
    latlong2.LatLng(35.5, 9.709),
    latlong2.LatLng(35.8566, 9.8522),
  ];
  late int pointIndex = 0;
  final MarkerId markerId = MarkerId("0");
  late int _selectedId = 0;
  int get selectedId => _selectedId;

  late Position _selectedPosition = new Position(
    deviceId: 0,
    outdated: false,
    valid: false,
    latitude: 0,
    longitude: 0,
    altitude: 0,
    speed: 0,
    course: 0,
    id: 0,
    attributes: new PositionAttributes(),
  );
  Position get selectedPosition => _selectedPosition;

  late Device _selectedDevice = new Device(
      status: 'status',
      disabled: false,
      lastUpdate: 'lastUpdate',
      position: null);
  Device get selectedDevice => _selectedDevice;

  late GoogleMapController _mapController;
  GoogleMapController get mapController => _mapController;

  late Location _location;
  Location get location => _location;
  BitmapDescriptor get pinLocationIcon => _pinLocationIcon;
  BitmapDescriptor get pinLocationIconMove => _pinLocationIconMove;

  late LatLng _locationPosition = LatLng(33.8869, 9.5375);
  LatLng get locationPosition => _locationPosition;

  bool locationServiceActive = true;

  /// Maximum zoom at which the markers will cluster

  /// [Fluster] instance used to manage the clusters



  /// Markers loading flag
  late List<LatLng> _markerLocations;
  List<LatLng> get markerLocations => _markerLocations;
  late List<MapMarker> _mapmarkers = [];
  List<MapMarker> get mapmarkers => _mapmarkers;
  late Uint8List moveIcon;
  late Uint8List tankIcon;

  late Uint8List eventIcon;

  late Uint8List stoppedIcon;
  late Uint8List parkIcon;
  late Uint8List startMarker;

  late bool setbounds = false;
  late String _devicesIds = '';
  late List<int> _allDevicesIds = [];
  late List<int> _userDevicesIds = [];

  late Set<Polyline> polylineSet = new Set();
  late List<LatLng> pointsPlyline = [];

  /// Color of the cluster text
  AppProvider() {
    _location = new Location();
    _markers = <MarkerId, Marker>{};
    _markerLocations = <LatLng>[];
    _mapmarkers = <MapMarker>[];
  }

  //loggedIn Updates
  Future setLoggedIn({required bool status}) async {
    isLoggedIn = status;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool('kIsloggedInKey', status);
  }

  Future setIsAdmin({required bool status}) async {
    isAdministrator = status;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool('isAdministrator', status);
  }

  Future getLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    print(
        'the preference value ${sharedPreferences.getBool('kIsloggedInKey')}');
    isLoggedIn = sharedPreferences.getBool('kIsloggedInKey') ?? isLoggedIn;
    return Future.value(isLoggedIn);
  }

  setSelectedId({required id}) {
    _selectedId = id;
  }

  setResLoggedIn({required res}) {
    isResLoggedIn = res;
  }

  getResLoggedIn() {
    return isResLoggedIn;
  }

  setResLoggedOut({required res}) {
    isResLoggedOut = res;
  }

  getResLoggedOut() {
    return isResLoggedOut;
  }

  setSelectedDevicePosition(Position e) {
    _selectedPosition = e;
    //_selectedDevice = getDeviceById(e.deviceId);
  }

  setSelectedDevice(int id) {
    _selectedDevice = getDeviceById(id);
    //_selectedDevice = getDeviceById(e.deviceId);
  }

  setSuiviDevicePosition(id) {
    _markertoSuivi.clear();
    _selectedDevice = getDeviceById(id);
    _selectedPosition = getPositionById(id);
    _centerToSuivi =
        LatLng(_selectedPosition.latitude, _selectedPosition.longitude);
    Marker newMarkerToSuivi = Marker(
      markerId: MarkerId(_selectedPosition.deviceId.toString()),

      position: LatLng(
        _selectedPosition.latitude,
        _selectedPosition.longitude,
      ),
      rotation: (_selectedPosition.course!),
      icon: getIcon(
          _selectedPosition.attributes.motion!, _selectedPosition.deviceId),
      /* infoWindow: InfoWindow(
            title: getDeviceById(e.deviceId).name,
            snippet: (e.speed * 1.852).toString(),
          ),*/
      onTap: () {
        print('Marker clicked');
      },
      //icon:BitmapDescriptor.fromBytes(markerIcon),
      draggable: false,
    );
    // _latLngBounds = LatLngBounds(northeast: LatLng(maxLat, maxLon), southwest: LatLng(minLat, minLon));
    _markertoSuivi.add(newMarkerToSuivi);
    print('initokok');
  }

  //User states
  setUser({required User user}) {
    user = user;
  }

  User getUser() {
    return user;
  }

  //Active Tabs//
  getSelectedTabIndex() => homeActiveTabIndex;
  setSelectedTabIndex(int index) {
    homeActiveTabIndex = index;
    notifyListeners();
  }

  //Devices
  List<Device> getDevices() => _devices;
  setDevices(List<Device> device) {
    _devices = device;
    notifyListeners();
  }
  List<TimeTable> getSonotrakTimeTable() => _timetable;
  setSonotrakTimetable(List<TimeTable> timetable) {
    _timetable= timetable;
    notifyListeners();
  }
  //Devices
  List<Device> getUserDevices() => _userDevices;
  setUserDevices(List<Device> devices) {
    _userDevices = devices;
    notifyListeners();
  }

  List<User> getUsers() => _users;
  setUsers(List<User> users) {
    _users = users;
    notifyListeners();
  }


  String getDevicesIds() => _devicesIds;
  setDevicesIds(String devicesIds) {
    _devicesIds = devicesIds;
  }

  List<int> getAllDevicesIds() => _allDevicesIds;
  setAllDevicesIds(List<int> allDevicesIds) {
    _allDevicesIds = allDevicesIds;
  }

  List<int> getUserDevicesIds() => _userDevicesIds;
  setUserDevicesIds(List<int> userDevicesIds) {
    _userDevicesIds = userDevicesIds;
  }

  bool checkIsIdExist(int id) {
    if (_devicesIds.contains(id.toString()))
      return true;
    else
      return false;
  }

  clearMarkerss() {
    _markerss.clear();
  }

  List<Event> getEvents() => _events;
  setEvents(events) {
    _events = events;
    notifyListeners();
  }

 
  List<Position> getTodayTrip() => _todayTrip;
  setTodayTrip(todayTrip) {
    _todayTrip = todayTrip;
    notifyListeners();
  }

  setTodayTripPolyline(List<Position> _todayTrip) {
    pointsPlyline = [];
    polylineSet.clear();

    for (var e in _todayTrip) {
      pointsPlyline.add(LatLng(e.latitude, e.longitude));
    }

    if (_todayTrip.length != 0) {
      int index = (_todayTrip.length / 2).toInt();
      _centerTodayTrip =
          LatLng(_todayTrip[index].latitude, _todayTrip[index].longitude);

      Marker newStartMarker = Marker(
        markerId: MarkerId(_todayTrip[0].id.toString()),

        position: LatLng(
          _todayTrip[0].latitude,
          _todayTrip[0].longitude,
        ),

        icon: getStartIcon(),
        infoWindow: InfoWindow(
          title: (_todayTrip[0].address != null && _todayTrip[0].address != '')
              ? _todayTrip[0].address
              : 'Address Not Found',
          snippet:
              (_todayTrip[0].fixTime != null && _todayTrip[0].fixTime != '')
                  ? ((DateTime.parse(_todayTrip[0].fixTime.toString()))
                          .add(new Duration(hours: 1))
                          .toString())
                      .substring(
                          0,
                          ((DateTime.parse(_todayTrip[0].fixTime.toString()))
                                  .add(new Duration(hours: 1))
                                  .toString())
                              .indexOf('.'))
                  : '--',
        ),
        onTap: () {
          print('Marker clicked');
        },
        //icon:BitmapDescriptor.fromBytes(markerIcon),
        draggable: false,
      );

      Marker newEndMarker = Marker(
        markerId: MarkerId(_todayTrip[_todayTrip.length - 1].id.toString()),

        position: LatLng(
          _todayTrip[_todayTrip.length - 1].latitude,
          _todayTrip[_todayTrip.length - 1].longitude,
        ),
        rotation: _todayTrip[_todayTrip.length - 1].course!,
        icon: getIcon(_todayTrip[_todayTrip.length - 1].attributes.motion!,
            _todayTrip[_todayTrip.length - 1].deviceId),
        infoWindow: InfoWindow(
          title: (_todayTrip[_todayTrip.length - 1].address != null &&
                  _todayTrip[_todayTrip.length - 1].address != '')
              ? _todayTrip[_todayTrip.length - 1].address
              : 'Address Not Found',
          snippet: (_todayTrip[_todayTrip.length - 1].fixTime != null &&
                  _todayTrip[_todayTrip.length - 1].fixTime != '')
              ? ((DateTime.parse(
                          _todayTrip[_todayTrip.length - 1].fixTime.toString()))
                      .add(new Duration(hours: 1))
                      .toString())
                  .substring(
                      0,
                      ((DateTime.parse(_todayTrip[_todayTrip.length - 1]
                                  .fixTime
                                  .toString()))
                              .add(new Duration(hours: 1))
                              .toString())
                          .indexOf('.'))
              : '--',
          // snippet: stp.duration.toString(),
        ),
        onTap: () {
          print('Marker clicked');
        },
        //icon:BitmapDescriptor.fromBytes(markerIcon),
        draggable: false,
      );
      _markerStartEndTrips.clear();

      _markerStartEndTrips.add(newStartMarker);

      _markerStartEndTrips.add(newEndMarker);
    }

    print('polypoints${pointsPlyline.length}');
    polylineSet.add(Polyline(
      polylineId: PolylineId('1'),
      points: pointsPlyline,
      color: Colors.blue,
      width: 3,
    ));
  }



  setEventMarker(posId) {
    _eventMarker.clear();

    Position pos = getPositionByPosId(posId);
    _selectedEventPosition = pos;
    notifyListeners();
    _eventMapCenter = LatLng(pos.latitude, pos.longitude);
    Marker newEventMarker = Marker(
      markerId: MarkerId(posId.toString()),

      position: LatLng(
        pos.latitude,
        pos.longitude,
      ),
      rotation: pos.course!,
      icon: getEventIcon(),
      infoWindow: InfoWindow(
        title: (pos.address != null && pos.address != '')
            ? pos.address
            : 'Address Not Found',
        // snippet: stp.duration.toString(),
      ),
      onTap: () {
        print('Marker clicked');
      },
      //icon:BitmapDescriptor.fromBytes(markerIcon),
      draggable: false,
    );
    // _latLngBounds = LatLngBounds(northeast: LatLng(maxLat, maxLon), southwest: LatLng(minLat, minLon));
    _eventMarker.add(newEventMarker);
  }






  String getCookie() => _apiCookie;

  setCookie({required String apiCookie}) {
    _apiCookie = apiCookie;
    notifyListeners();
  }

  addPosition({required Position position}) {
    _positions.add(position);

    notifyListeners();
  }

  replacePosition({required Position position, required int index}) async {
    if (position.latitude != _positions[index].latitude &&
        position.longitude != _positions[index].longitude) {
      if (selectedId == position.deviceId) {
        _trackMarkerPolyline.clear();
        _trackMarkerPolyline.add(Polyline(
            polylineId: PolylineId(position.deviceId.toString()),
            visible: true,
            points: [
              LatLng(_positions[index].latitude, _positions[index].longitude),
              LatLng(position.latitude, position.longitude)
            ],
            color: Colors.blue,
            width: 3,
            zIndex: -1));
      }

      _polylines.add(Polyline(
          polylineId: PolylineId(position.deviceId.toString()),
          visible: true,
          points: [
            LatLng(_positions[index].latitude, _positions[index].longitude),
            LatLng(position.latitude, position.longitude)
          ],
          color: Colors.blue,
          width: 3,
          zIndex: -1));

      print("PolyI" + position.deviceId.toString());
    }

    //  print('${_positions[index].id} changed to ${position.id}');

    //_markers.clear();
    _markerss.clear();
    _markertoSuivi.clear();
    _positions[index] = position;
    print("change in ${position.deviceId}");
    notifyListeners();

    // _markerLocations.clear();
    _markerLocations = [];
    _mapmarkers = [];
    if (setbounds == false) await getLatlngBounds();
    double minLat = _positions[0].latitude;
    double maxLat = _positions[0].latitude;
    double minLon = _positions[0].longitude;
    double maxLon = _positions[0].longitude;

    _markerss.clear();

    for (var e in _positions) {
      if (selectedId == e.deviceId) {
        _centerToSuivi = LatLng(e.latitude, e.longitude);
        setSelectedDevicePosition(e);
        setSelectedDevice(e.deviceId);
        Marker newMarkerToSuivi = Marker(
          markerId: MarkerId(e.deviceId.toString()),

          position: LatLng(
            e.latitude,
            e.longitude,
          ),
          rotation: (e.course!),
          icon: getIcon(e.attributes.motion!, e.deviceId),
          /* infoWindow: InfoWindow(
            title: getDeviceById(e.deviceId).name,
            snippet: (e.speed * 1.852).toString(),
          ),*/
          onTap: () {
            print('Marker clicked');
          },
          //icon:BitmapDescriptor.fromBytes(markerIcon),
          draggable: false,
        );
        // _latLngBounds = LatLngBounds(northeast: LatLng(maxLat, maxLon), southwest: LatLng(minLat, minLon));
        _markertoSuivi.add(newMarkerToSuivi);
      }

      // print('${e.deviceId}:: ${e.id}');
      notifyListeners();
      if (e.latitude > maxLat) maxLat = e.latitude;
      if (e.latitude < minLat) minLat = e.latitude;
      if (e.longitude > maxLon) maxLon = e.longitude;
      if (e.longitude < minLon) minLon = e.longitude;
      _markerLocations.add(LatLng(e.latitude, e.longitude));
      notifyListeners();
      if (_selectedId == e.deviceId) {
        setSelectedDevicePosition(e);
      }



      Marker newmarker = Marker(
        markerId: MarkerId(e.deviceId.toString()),

        position: LatLng(
          e.latitude,
          e.longitude,
        ),
        rotation: (e.course!),

        icon: getIcon(e.attributes.motion!, e.deviceId),
        infoWindow: InfoWindow(
          title: getDeviceById(e.deviceId).name,
          snippet: e.address,
        ),
        onTap: () {
          print('Marker clicked');
          setSelectedDevicePosition(e);
          setSelectedId(id: e.deviceId);
          setSelectedDevice(e.deviceId);
          _mapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            zoom: 15,
            target: LatLng(e.latitude, e.longitude),
          )));
        },
        //icon:BitmapDescriptor.fromBytes(markerIcon),
        draggable: false,
      );
      // _latLngBounds = LatLngBounds(northeast: LatLng(maxLat, maxLon), southwest: LatLng(minLat, minLon));
      _markerss.add(newmarker);
      notifyListeners();
    }
    print('listlist:: $_markerLocations');
  }

  get getPositions {
    return _positions;
  }

  get getPolyline {
    return _polylines;
  }

  get getTrackMarkerPolyline {
    return _trackMarkerPolyline;
  }

  List<Position> getPositionsList() {
    return _positions;
  }

  setPositions(List<Position> pos) => _positions = pos;

  getLatlngBounds() {
    double minLat = _positions[0].latitude;
    double maxLat = _positions[0].latitude;
    double minLon = _positions[0].longitude;
    double maxLon = _positions[0].longitude;
    for (var e in _positions) {
      // print('${e.deviceId}:: ${e.id}');
      notifyListeners();
      if (e.latitude > maxLat) maxLat = e.latitude;
      if (e.latitude < minLat) minLat = e.latitude;
      if (e.longitude > maxLon) maxLon = e.longitude;
      if (e.longitude < minLon) minLon = e.longitude;
      notifyListeners();
    }
    _latLngBounds = LatLngBounds(
        northeast: LatLng(maxLat, maxLon), southwest: LatLng(minLat, minLon));
    setbounds = true;
    print('lklk$_latLngBounds');
  }

  //////////////////////////
  ///
  initialization() async {
    await getUserLocation();
    await setCustomMapPin();
    tz.initializeTimeZones();

    await TraccarClientService(appProvider: this).getDevices();

    await TraccarClientService(appProvider: this).getPositions();
    await SonotrakClientService(appProvider: this).getSonotrakTimeTable();


    TraccarClientService(appProvider: this).getDevicePositionsStream;
    // await getLatlngBounds();
  }

  getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    location.onLocationChanged.listen(
      (LocationData currentLocation) {
        _locationPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        print(_locationPosition);

        // _markers.clear();

        Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
            _locationPosition.latitude,
            _locationPosition.longitude,
          ),
          //icon: pinLocationIcon,
          draggable: true,
          onDragEnd: ((newPosition) {
            _locationPosition = LatLng(
              newPosition.latitude,
              newPosition.longitude,
            );

            notifyListeners();
          }),
        );

        _markers[markerId] = marker;

        notifyListeners();
      },
    );
  }

  setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  int iconPxSize() {
    if (Platform.isAndroid) {
     /* double mq = ui.ViewConfiguration().devicePixelRatio;
      print('mqmq::$mq');
      int px = 65; // default for 1.0x
      if (mq > 1.5 && mq < 2.5) {
        px = 55;
      } else if (mq >= 2.5) {
        px = 45;
      }*/
      return 50;
    }
    // this is for iOS
    return 65;
  }

  setCustomMapPin() async {
    moveIcon =
        await getBytesFromAsset('assets/images/greenarrow.png', iconPxSize());
    tankIcon = await getBytesFromAsset('assets/images/tank.png', 120);
    eventIcon =
        await getBytesFromAsset('assets/images/blueArrow.png', iconPxSize());
    stoppedIcon =
        await getBytesFromAsset('assets/images/redarrow.png', iconPxSize());
    parkIcon =
        await getBytesFromAsset('assets/images/parking.png', iconPxSize());
    startMarker = await getBytesFromAsset('assets/images/startMarker.png', 100);

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(2, 2)),
            'assets/images/destination_map_marker.png')
        .then((d) {
      _pinLocationIcon = d;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(2, 2)),
            'assets/images/greenarrow.png')
        .then((d) {
      _pinLocationIconMove = d;
    });
  }

  takeSnapshot() {
    return _mapController.takeSnapshot();
  }

  getIcon(bool motion, int id) {
   // if (getDeviceCategoryByID(id) != 'Tank' && getDeviceCategoryByID(id) != null) {
      if (motion == true)
        return BitmapDescriptor.fromBytes(moveIcon);
      else
        return BitmapDescriptor.fromBytes(stoppedIcon);
    /* } 
   else
      return BitmapDescriptor.fromBytes(tankIcon);*/
  }

  getEventIcon() {
    return BitmapDescriptor.fromBytes(eventIcon);
  }

  getStopIcon() {
    return BitmapDescriptor.fromBytes(parkIcon);
  }

  getStartIcon() {
    return BitmapDescriptor.fromBytes(startMarker);
  }

  Device getDeviceById(int deviceId) {
    return _devices.firstWhere((device) => device.id == deviceId);
  }

 Device getDeviceByName(String? name) {
    return _devices.firstWhere((device) => device.name == name);
  }



  String getDeviceCategoryByID(int deviceId) {
    final int isExist = _devices.indexWhere((row) => row.id == deviceId);

    if (isExist >= 0 &&
        deviceId != 0 &&
        _devices.isNotEmpty) {
      Device? device = _devices.firstWhere((device) => device.id == deviceId);
      String category = device.category!;
      return category;
    } else
      return '';
  }

  String getDeviceNameById(int deviceId) {
    final int isExist = _devices.indexWhere((row) => row.id == deviceId);
    if (isExist >= 0) {
      Device d = _devices.firstWhere((device) => device.id == deviceId);
      return d.name!;
    }
    return "UNKNOWN";
  }

  int? getDeviceIdByName(String? name) {
    Device d = _devices.firstWhere((device) => device.name == name);
    return d.id;
  }

  dynamic? getDeviceTotalDistanceById(int id) {
    Position d = _positions.firstWhere((pos) => pos.deviceId == id);
    return d.attributes.totalDistance;
  }

  int? getDeviceTotalWorkingHoursById(int id) {
    Position d = _positions.firstWhere((pos) => pos.deviceId == id);

    return d.attributes.hours;
  }

  int? getDeviceHoursById(int id) {
    Position d = _positions.firstWhere((pos) => pos.deviceId == id);
    return d.attributes.hours;
  }



  Position getPositionById(int deviceId) {
    final int exist = _positions.indexWhere((row) => row.deviceId == deviceId);
    Position pos;
    bool motion = false;
    if (exist >= 0) {
      pos = _positions.firstWhere((pos) => pos.deviceId == deviceId);
      print('plpl::${pos.address}');
      return pos;
    } else
      pos = new Position(
        deviceId: 0,
        outdated: false,
        valid: false,
        latitude: 0.0,
        longitude: 0.0,
        altitude: 0.0,
        speed: 0.0,
        course: 0.0,
        id: 0,
        attributes: PositionAttributes(),
      );
    return pos;
  }

  Position getPositionByPosId(int id) {
    Position pos = _positions.firstWhere((pos) => pos.deviceId == id);
    print('plpl::${pos.address}');
    return pos;
  }

  bool getMotionId(int deviceId) {
    final int exist = _positions.indexWhere((row) => row.deviceId == deviceId);
    Position? pos;
    bool motion = false;
    if (exist >= 0) {
      pos = _positions.firstWhere((pos) => pos.deviceId == deviceId);
      if (pos.attributes.motion != null) motion = pos.attributes.motion!;
    }

    return motion;
  }

  bool getExpiredStatus(int deviceId) {
    final int isExist = _userDevices.indexWhere((row) => row.id == deviceId);
    Device userDevice;
    bool expired = false;
    if (isExist >= 0) {
      userDevice = _userDevices.firstWhere((pos) => pos.id == deviceId);

      expired = lastupdate(userDevice.attributes!.expiredDate);
    }
    return expired;
  }

  lastupdate(date) {
    if (date == null) {
      return false;
    }
    DateTime newdate = DateTime.parse(date);
    final date2 = DateTime.now();
    final difference = date2.difference(newdate).inDays;
    var diff = calculTime(date2, newdate);
    if (diff < 0)
      return true;
    else
      return false;
  }

  calculTime(DateTime from, DateTime to) {
    // ffrom = DateTime(from.year, from.month, from.day);
    // fto = DateTime(to.year, to.month, to.day);

    return (to.difference(from).inDays).round();
  }
}
