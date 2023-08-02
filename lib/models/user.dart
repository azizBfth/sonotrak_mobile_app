class User {
  final id;
  String? email;
  String? name;
  String? phone;
  bool? readonly;
  bool administrator;
  String? map;
  double? latitude;
  double? longitude;
  final zoom;
  final password;
  final twelveHourFormat;
  final coordinateFormat;
  bool? disabled;
  final expirationTime;
  final deviceLimit;
  final userLimit;
  final deviceReadOnly;
  final limitCommands;
  final poiLayer;
  final token;
  UserAttributes? attributes;

  User(
      {required this.email,
      this.password,
      this.token,
      required this.administrator,
      required this.attributes,
      required this.coordinateFormat,
      required this.deviceLimit,
      required this.deviceReadOnly,
      required this.disabled,
      required this.expirationTime,
      required this.id,
      required this.latitude,
      required this.limitCommands,
      required this.longitude,
      required this.map,
      required this.name,
      required this.phone,
      required this.poiLayer,
      required this.readonly,
      required this.twelveHourFormat,
      required this.userLimit,
      required this.zoom});

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      email: data['email'],
      token: data['token'],
      administrator: data['administrator'],
      deviceLimit: data['deviceLimit'],
      zoom: data['zoom'],
      userLimit: data['userLimit'],
      twelveHourFormat: data['twelveHourFormat'],
      readonly: data['readonly'],
      poiLayer: data['poiLayer'],
      phone: data['phone'],
      coordinateFormat: data['coordinateFormat'],
      deviceReadOnly: data['deviceReadonly'],
      disabled: data['disabled'],
      expirationTime: data['expirationTime'],
      latitude: data['latitude'],
      id: data['id'],
      limitCommands: data['limitCommands'],
      longitude: data['longitude'],
      map: data['map'],
      name: data['name'],
      
      attributes: UserAttributes.fromJson(data['attributes']),
    );
  }
}

class UserAttributes {
 

// final DeviceAccessories? deviceAccessories;
  UserAttributes(
 );

  factory UserAttributes.fromJson(Map<String, dynamic> attributes) {
    //  var attrs = attributes["attributes"];
    return UserAttributes(
      
    );
  }
}
