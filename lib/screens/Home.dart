import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sonotrak/apis/api_services.dart';
import 'package:sonotrak/apis/api_sonotrak.dart';
import 'package:sonotrak/models/device.dart';
import 'package:sonotrak/providers/app_provider.dart';
import 'package:sonotrak/providers/connectivity_provider.dart';
import 'package:sonotrak/providers/language.dart';

import 'package:kf_drawer/kf_drawer.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sonotrak/screens/Schedule.dart';
import 'package:sonotrak/screens/google_map_page.dart';

import '../global.dart';
import '../models/Timetable.dart';
import '../widgets/departureselector.dart';
import '../widgets/locationselectorcontainer.dart';
import '../widgets/meanstransportmenu.dart';
import '../widgets/no_internet.dart';
import '../widgets/ticketcontainer.dart';
import 'package:intl/intl.dart';

//class needs to extend StatefulWidget since we need to make changes to the bottom app bar according to the user clicks
class Home extends KFDrawerContent {
  static const router = "/home";

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  Language _language = Language();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    Provider.of<AppProvider>(context, listen: false).initialization();
    setState(() => _language.getLanguage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //drawer: sideBar(),
        body: pageUI());
  }

  Widget checkloading() {
    return Consumer<AppProvider>(builder: (context, model, child) {
      if (model.getDevices().isEmpty && model.getPositionsList().isEmpty) {
        return loading();
      } else if (model.getDevices().isNotEmpty &&
          model.getPositionsList().isNotEmpty) {
        return const MainWidget();
      }

      return loading();
    });
  }

  Widget loading() {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color(0xFF59C2FF),
            Color(0xFF1270E3),
          ])),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SpinKitFadingFour(
                color: Colors.white,
                size: 50.0,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                _language.tDevicesLoading(),
                style: const TextStyle(color: Colors.white),
              )
            ],
          )),
    );
  }

  Widget pageUI() {
    return Consumer<ConnectivityProvider>(builder: (context, model, child) {
      return model.isOnline ? checkloading() : const NoInternt();
    });
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({
    Key? key,
  }) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  _MainWidgetState();
  Language _language = Language();
  String username = "--";
  List<TimeTable> _timetable = [];
  bool _searchClicked = false;
  late String from = "SFAX";
  late String to = "KERKENNAH";
  TextEditingController _searchController = new TextEditingController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  late AppProvider _appProvider;
  @override
  void initState() {
    super.initState();
    setState(() => _language.getLanguage());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  // onRefresh //
  void _onRefresh() async {
    if (from == "SFAX")
      await _getSonotrakTimeTableFromSfax();
    else
      await _getSonotrakTimeTableFromKerkennah();
    _appProvider.setSonotrakTimetable(_timetable);
    _refreshController.refreshCompleted();
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<TimeTable>> _getSonotrakTimeTable() async {
    _timetable = await SonotrakClientService(appProvider: _appProvider)
        .getSonotrakTimeTable();
    return _timetable;
  }

  Future<List<TimeTable>> _getSonotrakTimeTableFromSfax() async {
    _timetable = await SonotrakClientService(appProvider: _appProvider)
        .getSonotrakTimeTableFromSfax();
    return _timetable;
  }

  Future<List<TimeTable>> _getSonotrakTimeTableFromKerkennah() async {
    _timetable = await SonotrakClientService(appProvider: _appProvider)
        .getSonotrakTimeTableFromKerkennah();
    return _timetable;
  }

  Widget buildCard(BuildContext context, TimeTable item) {
    return _listViewElementWidget(item);
  }

  calculEstimation(arrivalTime) {
    var newString = arrivalTime.substring(0, 2);
    int aHr = int.parse(newString);

    DateTime now = DateTime.now();
    String formattedTime = DateFormat.Hms().format(now);

    var dateString = formattedTime.substring(0, 2);

    int tHr = int.parse(dateString);

    return (aHr - tHr).toString();
  }

  calculeArrivalTime(int estimation) {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat.Hms().format(now);
    
    var hrString = formattedTime.substring(0, 2);
    var minString = formattedTime.substring(3, 5);

    int tHr = int.parse(hrString);
    int tmin = int.parse(minString);

    int pmin = tmin + estimation;
    print("PMIN:$pmin");
    if (pmin >= 60) {
      int pfhr = (pmin / 60).toInt();
      int pfmin = pmin % 60;
      int ffhr = pfhr + tHr;
      return ffhr.toString() + ':' + pfmin.toString();
    }

    return tHr.toString()+':'+pmin.toString();
  }

  Widget _listViewElementWidget(TimeTable item) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(vertical: 15.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(25.0)),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Text(
              item.estimation != "UNKNOWN"
                  ? calculeArrivalTime(item.estimation)
                  : item.arrival_time.toString(),
              style: Theme.of(context).textTheme.titleSmall?.apply(
                  color: item.estimation != "UNKNOWN"
                      ? Colors.lightGreen
                      : Colors.blue),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Arrival In:"),
                    const SizedBox(
                      height: 5.0,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: item.estimation.toString() != "UNKNOWN"
                                ? item.estimation.toString()
                                : calculEstimation(item.arrival_time),
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          TextSpan(
                              text: item.estimation.toString() != "UNKNOWN"
                                  ? "min"
                                  : "hr",
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                              text: "Travel Time: ",
                              style: TextStyle(color: Colors.black87)),
                          TextSpan(
                              text: "45 min",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  item.arrival_time.toString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  item.departure_time.toString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 3.0,
                            ),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.directions_boat_outlined,
                                  color: Colors.black54,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  child: Text(
                                    item.vehicle_name.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(.3),
                          border: Border.all(color: Colors.blue, width: 3.0),
                        ),
                      ),
                      const SizedBox(
                        width: 9.0,
                      ),
                      Text(item.stop_name.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(.3),
                          border: Border.all(color: Colors.orange, width: 3.0),
                        ),
                      ),
                      const SizedBox(
                        width: 9.0,
                      ),
                      Text(item.headsign!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                //color: lightGreen,
                icon:
                    const Icon(Icons.confirmation_number, color: Colors.white),
                onPressed: () =>{
                                        _appProvider.setSelectedId(id:  _appProvider.getDeviceByName(item.vehicle_name).id),

                    Navigator.of(context).pushNamed('deviceMapTracking'),

                },
                label: Text(
                  "DETAILS",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
    _timetable = _appProvider.getSonotrakTimeTable();

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: lightGreen,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue.withOpacity(.3),
                                            border: Border.all(
                                                color: Colors.blue, width: 3.0),
                                          ),
                                        ),
                                        SizedBox(width: 15.0),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "From",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.apply(
                                                      color: Colors.black38),
                                            ),
                                            GestureDetector(
                                                child: Text(
                                                  from,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.apply(
                                                          color:
                                                              Colors.black87),
                                                ),
                                                onTap: () {}),
                                          ],
                                        )
                                      ],
                                    ),
                                    const Divider(
                                      height: 25,
                                      color: Colors.black,
                                      thickness: .7,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.orange.withOpacity(.3),
                                            border: Border.all(
                                                color: Colors.orange,
                                                width: 3.0),
                                          ),
                                        ),
                                        SizedBox(width: 15.0),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "To",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.apply(
                                                      color: Colors.black38),
                                            ),
                                            GestureDetector(
                                                child: Text(
                                                  to,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.apply(
                                                          color:
                                                              Colors.black87),
                                                ),
                                                onTap: () {}),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Color(0xfff0f3f7),
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.import_export,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    if (this.from == "SFAX") {
                                      setState(() {
                                        this.from = "KERKENNAH";
                                        this.to = "SFAX";
                                      });
                                      _onRefresh();
                                    } else {
                                      setState(() {
                                        this.from = "SFAX";
                                        this.to = "KERKENNAH";
                                        _onRefresh();
                                      });
                                    }
                                    print("inverse from to");
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, -5),
                            blurRadius: 9,
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35.0),
                          topRight: Radius.circular(35.0),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          // MeansTransportMenu(),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                              child: SmartRefresher(
                                controller: _refreshController,
                                enablePullDown: true,
                                onRefresh: _onRefresh,
                                child: ListView.builder(
                                  itemCount: _timetable.length,
                                  itemBuilder: (context, index) {
                                    return buildCard(
                                        context, _timetable[index]);
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
