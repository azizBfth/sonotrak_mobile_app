import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sonotrak/models/Timetable.dart';
import 'package:provider/provider.dart';

import 'package:sonotrak/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//import '../traccar_client/traccar_client.dart';

class SonotrakClientService {
  final AppProvider appProvider;
  final _dio = Dio();

  SonotrakClientService({required this.appProvider});
  /*
   * @description Login Api
   */

  Future<List<TimeTable>> getSonotrakTimeTable() async {
    String uri = "https://emkatransit.emkatech.tn/api/timetable";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    if (response.statusCode == 200) {
      final timetable = <TimeTable>[];
      int index = 0;
      for (final data in response.data) {
        var item = TimeTable.fromJson(data as Map<String, dynamic>);
              print("TIMETABLE${item.estimation}");

        timetable.add(item);
      }
      appProvider.setSonotrakTimetable(timetable);
      return timetable;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }
   Future<List<TimeTable>> getSonotrakTimeTableFromSfax() async {
    String uri = "https://emkatransit.emkatech.tn/api/timetable/SONOTRAK/002";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    if (response.statusCode == 200) {
      final timetable = <TimeTable>[];
      int index = 0;
      for (final data in response.data) {
        var item = TimeTable.fromJson(data as Map<String, dynamic>);
              print("TIMETABLE${item.estimation}");

        timetable.add(item);
      }
      appProvider.setSonotrakTimetable(timetable);
      return timetable;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }
Future<List<TimeTable>> getSonotrakTimeTableFromKerkennah() async {
    String uri = "https://emkatransit.emkatech.tn/api/timetable/SONOTRAK/001";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: "application/json",
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    if (response.statusCode == 200) {
      final timetable = <TimeTable>[];
      int index = 0;
      for (final data in response.data) {
        var item = TimeTable.fromJson(data as Map<String, dynamic>);
              print("TIMETABLE${item.estimation}");

        timetable.add(item);
      }
      appProvider.setSonotrakTimetable(timetable);
      return timetable;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

}
