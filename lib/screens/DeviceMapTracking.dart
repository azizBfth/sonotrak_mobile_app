import 'dart:async';
import 'package:sonotrak/global.dart';
import 'package:sonotrak/models/device.dart';
import 'package:sonotrak/models/position.dart';
import 'package:sonotrak/providers/app_provider.dart';
import 'package:sonotrak/providers/language.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sonotrak/widgets/locationrow.dart';

class DeviceMapTracking extends StatefulWidget {
  const DeviceMapTracking({Key? key}) : super(key: key);

  @override
  _DeviceMapTrackingState createState() => _DeviceMapTrackingState();
}


class _DeviceMapTrackingState extends State<DeviceMapTracking> {
  final Completer<GoogleMapController> _mapSuiviController = Completer();
  late bool isMapCreated = false;
  late GoogleMapController mcontroller;
  Language _language = Language();

  void initState() {
    super.initState();
    setState(() {
      _language.getLanguage();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mcontroller = controller;

    _mapSuiviController.complete(controller);

    setState(() {
      isMapCreated = true;

      mcontroller = controller;
    });
    //controller.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 100));
    // _initMarkers(_mlocations);
  }

  late AppProvider _appProvider;
  LatLng _mapCenter = LatLng(35, 9);
  setMapCenter(center) {
    _mapCenter = center;
    if (isMapCreated)
      mcontroller.animateCamera(CameraUpdate.newLatLng(_mapCenter));
  }

 
  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
        backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 11.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(9.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green,
                          blurRadius: 3.0,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: Icon(Icons.map, color: Colors.white),
                ),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(9.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue,
                          blurRadius: 3.0,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: Icon(Icons.star, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.orange, Colors.orangeAccent]),
                    borderRadius: BorderRadius.circular(9.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.orange,
                          blurRadius: 3.0,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    "Show Ticket",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(color: Colors.white),
                        textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
  
      
      appBar: AppBar(
           backgroundColor: Colors.white,


        //   backgroundColor: Color(0xFF149cf7),
        title: Text(
          _device!.name != null ? (_device!.name.toString()).toUpperCase() : '',
          style: TextStyle(color: Colors.lightGreen),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.lightGreen,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            icon: Icon(
              Icons.home,
              color: Colors.lightGreen,
            ),
          )
        ],
      ),
     body: 
   Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
               Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    offset: Offset(0, 9),
                    color: lightGreen.withOpacity(.75),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Image.asset('assets/images/invoice.png'),
                  ),
                  SizedBox(width: 15.0),
                  Flexible(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Buying tickets is now much more comfortable.",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          "Buy a ticket now and get 50% discount.",
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
           
   googleMapForDeviceTrackingUI(),
     Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      LocationRow(
                        color: Colors.blue,
                        icon: Icon(
                          Icons.arrow_drop_up,
                          color: Colors.white,
                          size: 25,
                        ),
                        location: "SFAX",
                        time: "Oct 27, 14:39",
                      ),
                      LocationRow(
                        color: Colors.white,
                        location: "SFAX",
                        time: "Oct 27, 15:23",
                        border: Border.all(width: 2, color: Colors.grey),
                      ),
                      LocationRow(
                        color: Colors.orange,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 25,
                        ),
                        location: "KERKENNAH",
                        time: "Oct 27, 16:15",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(9.0),
                    decoration: BoxDecoration(
                      color: Color(0xfffcfcfd),
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "05",
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              fontSize: 41),
                        ),
                        Text(
                          "minute",
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 25),
                        ),
                        SizedBox(
                          height: 9.0,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "Travel Time: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                  text: "15 min",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.apply(
                                          color: darkBlue, fontWeightDelta: 2)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 9.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "07:05",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(
                                  height: 3.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.directions_bus,
                                      color: Colors.black54,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 9.0),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius:
                                            BorderRadius.circular(9.0),
                                      ),
                                      child: Text(
                                        "20",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(width: 9),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "07:23",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(
                                  height: 3.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.directions_bus,
                                      color: Colors.black54,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 9.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(9.0),
                                      ),
                                      child: Text(
                                        "20",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  late Device? _device =
      new Device(status: '', disabled: false, lastUpdate: '', position: null);
  late Position? _position = new Position(
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
  getDevicePosition(Position pos, Device device) {
 

    _device = device;
    _position = pos;
 
  }

  late bool devicePositionInitialise = false;
  Widget googleMapForDeviceTrackingUI() {
    // print('geoF::${_geofences[0].area}');
    return new WillPopScope(
        onWillPop: () async => false,
        child:
            new Consumer<AppProvider>(builder: (consumerContext, model, child) {
          if (model.markersToSuivi != null) {
            if (devicePositionInitialise == false) {
              _appProvider.setSuiviDevicePosition(_appProvider.selectedId);
              devicePositionInitialise = true;
              print('initOK');
            }

            setMapCenter(model.centerToSuivi);
            getDevicePosition(model.selectedPosition, model.selectedDevice);
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                    Color(0xFF1270E3),
                    Color(0xFF59C2FF),
                    Color(0xFF59C2FF),

                    
                  ])),
              child: Column(
                children: [
                  //  Expanded(child: LeafletMap()),
                  Container(
                    height: MediaQuery.of(context).size.height /4,
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      mapToolbarEnabled: true,
                      zoomGesturesEnabled: true,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      polylines:model.getTrackMarkerPolyline,
                      initialCameraPosition: CameraPosition(
                        target: _mapCenter,
                        zoom: 16,
                      ),
                      markers: model.markersToSuivi,
                      onMapCreated: (controller) => {
                        _onMapCreated(
                          controller,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }));
  }

}
