// import 'package:traccar_client/traccar_client.dart';
// import 'package:device/device.dart';
// import 'package:geopoint/geopoint.dart';
// import '../traccar_client/src/models/position.dart';
// import '../traccar_client/traccar_client.dart';

import 'package:sonotrak/models/position.dart';

class Device {
  final int? id;
  final String? uniqueId;
  final String? name;
  final String status;
  final bool disabled;
  final lastUpdate;
  final int? positionId;
  final int? groupId;
  final String? phone;
  final String? model;
  final String? contact;
  final String? category;
  final List<int>? geofenceIds;
  int keepAlive;

  // final position;
//  final Device device;

  // final bool isActive;

  final String? motion;
  DeviceAttributes? attributes;
  DeviceAccessories? accessories;
  Position? position;
  Device(
      {this.id,
      this.name,
      this.uniqueId,
      required this.status,
      required this.disabled,
      required this.lastUpdate,
      this.positionId,
      this.groupId,
      this.phone,
      this.model,
      this.contact,
      this.category,
      this.geofenceIds,
      this.attributes,
      this.keepAlive = 1,
      required this.position,
      this.motion,
      this.accessories});

  factory Device.fromJson(Map<String, dynamic> data) {
    //data["attributes"]["batteryLevel"] = 0;
    return Device(
      id: data["id"],
      /*   position: data["latitude"] != null
          ? DevicePosition.fromJson(data) as GeoPoint
          : null,*/
      positionId: data["positionId"],
      name: data["name"],
      position: data["latitude"] != null ? Position.fromJson(data) : null,
      // isActive: (data["status"].toString() != "offline"),
      status: data['status'], //for displayPurpose
      lastUpdate: data["lastUpdate"],
      category: data["category"],
      phone: data["phone"],
      model: data["model"],
      //  device: data["deviceId"] != null ? Device.fromPosition(data) : null,
      uniqueId: data["uniqueId"],
      disabled: data['disabled'],
      contact: data['contact'],
      geofenceIds: data['geofenceId'],
      groupId: data['groupId'],
      // attributes: data['attributes']
      motion: data["motion"],
      attributes: DeviceAttributes.fromJson(data['attributes']),
      accessories: data['attributes']['accessoires'] != null
          ? DeviceAccessories.fromJson(data['attributes']['accessoires'])
          : DeviceAccessories.fromJson({}),
    );
  }
}

class DeviceAttributes {
  final fuelDropThreshold;
  final double? speedLimit;
  final maitenanceId;
  final expiredDate;

// final DeviceAccessories? deviceAccessories;
  DeviceAttributes({
    this.fuelDropThreshold,
    this.speedLimit,
    this.maitenanceId,
    this.expiredDate,
  });

  factory DeviceAttributes.fromJson(Map<String, dynamic> attributes) {
    //  var attrs = attributes["attributes"];
    return DeviceAttributes(
      fuelDropThreshold: attributes['fuelDropThreshold'],
      speedLimit: attributes['speedLimit'],
      maitenanceId: attributes['maitenanceId'],
      expiredDate: attributes['expiredDate']
    );
  }
}

//////
///
class DeviceAccessories {
  final bool? can;
  final bool? relay;
  final bool? gauge;
  final bool? temp;
  final bool? ibutton;

  DeviceAccessories(
      {this.can, this.gauge, this.relay, this.temp, this.ibutton});
  factory DeviceAccessories.fromJson(Map<String?, dynamic> accessoire) {
    //  var attrs = attributes["attributes"];
    return DeviceAccessories(
      can: accessoire['can'],
      gauge: accessoire['gauge'],
      relay: accessoire['relais'],
      temp: accessoire['temp'],
      ibutton: accessoire['ibutton'],
    );
  }
}
