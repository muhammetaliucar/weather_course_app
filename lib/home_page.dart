import 'package:flutter/material.dart';
import 'search_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dailyWeather.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String city = "İstanbul";
  int degree;

  var locationData;
  var woeid;
  var hava_durumu;
  Position position;

  List temps = List.generate(5, (index) => null);
  List<String> hava_durumu_haftalik = List(5);
  List<String> tarihler = List(5);
  List<String> daysOfWeek = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  //

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(position);
    } catch (error) {
      print("Şu hata oluştu $error");
    } finally {

    }
  }

  //
  //getLocationData
  Future<void> getLocationData() async {
    locationData = await http
        .get("https://www.metaweather.com/api/location/search/?query=$city");
    var locationDataParsed = jsonDecode(locationData.body)[0];
    woeid = locationDataParsed["woeid"];
  }

  //
  Future<void> getLocationTemperature() async {
    var response =
        await http.get("https://www.metaweather.com/api/location/$woeid/");
    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      degree =
          temperatureDataParsed["consolidated_weather"][0]["the_temp"].round();
      hava_durumu = temperatureDataParsed["consolidated_weather"][1]
          ["weather_state_abbr"];
      for (int i = 0; i < temps.length; i++) {
        temps[i] = temperatureDataParsed["consolidated_weather"][i + 1]
                ["the_temp"]
            .round();
      }
      //
      for (int i = 0; i < hava_durumu_haftalik.length; i++) {
        hava_durumu_haftalik[i] = temperatureDataParsed["consolidated_weather"]
            [i + 1]["weather_state_abbr"];
      }
      for (int i = 0; i < tarihler.length; i++) {
        tarihler[i] = temperatureDataParsed["consolidated_weather"][i + 1]
            ["applicable_date"];
      }
      print(tarihler);
    });
  }

  Future<void> getLocationLatLong() async {
    locationData = await http.get(
        "https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}");
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes))[0];
    woeid = locationDataParsed["woeid"];
    city = locationDataParsed["title"];
  }

  void getDataFromAPI() async {
    await getDevicePosition(); 
    await getLocationLatLong();
    getLocationTemperature(); 
  }

  void getDataFromAPIByCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    getDataFromAPI();
    super.initState();
  } //

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: hava_durumu == null
              ? AssetImage("assets/c.jpg")
              : AssetImage("assets/$hava_durumu.jpg"),
        ),
      ),
      child: degree == null
          ? Center(
              child: Container(
                  height: MediaQuery.of(context).size.width * 0.5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitPouringHourGlass(
                        color: Colors.black,
                        size: 100,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Loading...",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            decoration: TextDecoration.none),
                      ),
                    ],
                  )))
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      height: MediaQuery.of(context).size.height*0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                        color: Colors.white.withOpacity(0.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              child: Image.network(
                                  "https://www.metaweather.com/static/img/weather/png/$hava_durumu.png"),
                            ),
                            Text(
                              "$degree°C",
                              style: TextStyle(
                                  fontSize: 70,
                                  fontWeight: FontWeight.bold,
                                  color:Colors.black54,
                                  //gölge için
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 0,
                                      offset: Offset(0, 0),
                                    ),
                                  ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  city.toString(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black54,
                                    //gölge için
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 0,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.search,color:Colors.black54),
                                  onPressed: () async {
                                    city = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SearchPage()));
                                    getDataFromAPIByCity();
                                    setState(() {
                                      city = city;
                                    });
                                  },
                                  iconSize: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                    ),
                    buildDailyCards(context)
                  ],
                ),
              )),
    );
  }

  Container buildDailyCards(BuildContext context) {
    List<Widget> cards = List.generate(5,(index)=> null);
    for(int i=0;i<cards.length;i++)
    {
      cards[i]=DailyWeather(
                          date: daysOfWeek[DateTime.parse(tarihler[i]).weekday-1],
                          temp: temps[i].toString(),
                          image: hava_durumu_haftalik[i].toString(),
                        );
    }
    return Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:cards,//cards ile gösterdik
                    ),
                  );
  }
}

