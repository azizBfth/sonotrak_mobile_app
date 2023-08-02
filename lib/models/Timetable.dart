class TimeTable {
  final String? arrival_time;
  final String? agency_name;
  final String? departure_time;
  final  estimation;
  final String? headsign;
  final String? schedule_relationship;
  final String? stop_code;
  final String? stop_name;
  final String? trip_id;
  final String? vehicle_id;
  final String? vehicle_name;
  TimeTable(
      {this.agency_name,
      this.arrival_time,
      this.departure_time,
      this.estimation,
      this.headsign,
      this.schedule_relationship,
      this.stop_code,
      this.stop_name,
      this.trip_id,
      this.vehicle_id,
      this.vehicle_name});

  factory TimeTable.fromJson(Map<String, dynamic> data) {
    return TimeTable(
      agency_name: data["agency_name"],
      arrival_time: data["arrival_time"],
      departure_time: data["departure_time"],
      estimation: data["estimation"] ,
      headsign: data['headsign'], 
      schedule_relationship: data["schedule_relationship"],
      stop_code: data["stop_code"],
      stop_name: data["stop_name"],
      trip_id: data["trip_id"],
      vehicle_id: data["vehicle_id"],
      vehicle_name: data['vehicle_name'],
      
    );
  }
}

