import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:course_b/model/curentCityDataModel.dart';
import 'package:course_b/model/sixDaysWeather.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var cityName = "london";
  var lat  ;
  var lon ;
  var apikey = '02fb71550df66bc5f3fd1ef8953c2ad4';

  TextEditingController Controller = TextEditingController();
  late StreamController<List<SixDaysWeather>> streamController;

  late Future<CurrentCityDataModel> weatherData;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weatherData = sendRequestCurrentWeather(cityName);

    streamController = StreamController<List<SixDaysWeather>>();




  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: FutureBuilder<CurrentCityDataModel>(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            sendRequestForSixDays(lat,lon);
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("images/pic_bg.jpeg"),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 4),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                     weatherData = sendRequestCurrentWeather(Controller.text);
                                    });
                                  }, child: Text("Find")),
                            ),
                            Expanded(
                              child: TextField(
                                controller: Controller,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.white),
                                    border: UnderlineInputBorder()),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Text(
                          "${snapshot.data?.name}",
                          style: TextStyle(color: Colors.white, fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          snapshot.data!.weather?.last?.description ?? "clear",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: setIconForMain(
                            snapshot!.data!.weather!.last!.icon.toString()),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          "${snapshot.data!.main!.temp!.toInt().round()}°",
                          style: TextStyle(fontSize: 35, color: Colors.white),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Max",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 20),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  "${snapshot.data!.main!.tempMax!.toInt().round()}°",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 1,
                              color: Colors.white,
                              height: 45,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                Text(
                                  "Min",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 20),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "${snapshot.data!.main!.tempMin!.toInt().round()}°",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Container(
                          color: Colors.grey[600],
                          width: MediaQuery.of(context).size.width - 10,
                          height: 1,
                        ),
                      ),
                      SizedBox(
                          width: double.infinity,
                          height: 80,
                          child: Center(
                            child: StreamBuilder<List<SixDaysWeather>>(
                              stream: streamController.stream,
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                print(snapshot.data);
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: 5,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, pos) => ListViewItem(snapshot.data![pos])

                                      );
                                }
                                else{
                                 return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },

                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Container(
                          color: Colors.grey[600],
                          width: MediaQuery.of(context).size.width - 10,
                          height: 1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "Wind speed",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              Text(
                                "${snapshot.data!.wind?.speed} m/s",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              width: 1,
                              height: 35,
                              color: Colors.grey[600],
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "sunrise",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              Text(
                                "${DateTime.fromMillisecondsSinceEpoch(snapshot.data!.sys!.sunrise!.toInt() * 1000).toString().substring(10, 16)} AM ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              width: 1,
                              height: 35,
                              color: Colors.grey[600],
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "sunset",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              Text(
                                "${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(snapshot.data!.sys!.sunset!.toInt() * 1000))} ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              width: 1,
                              height: 35,
                              color: Colors.grey[600],
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "Humidity",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              Text(
                                "${snapshot.data!.main?.humidity}%",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Image setIconForMain(String iconCode) {
    switch (iconCode) {
      case "01d":
        {
          return Image(image: AssetImage("images/01d@2x.png"));
        }
      case "01n":
        {
          return Image(image: AssetImage("images/01n@2x.png"));
        }
      case "02d":
        {
          return Image(image: AssetImage("images/02d@2x.png"));
        }
      case "02n":
        {
          return Image(image: AssetImage("images/02n@2x.png"));
        }
      case "03d":
        {
          return Image(image: AssetImage("images/03d@2x.png"));
        }
      case "03n":
        {
          return Image(image: AssetImage("images/03d@2x.png"));
        }
      case "04d":
        {
          return Image(image: AssetImage("images/04d@2x.png"));
        }
      case "04n":
        {
          return Image(image: AssetImage("images/04d@2x.png"));
        }
      case "09d":
        {
          return Image(image: AssetImage("images/09d@2x.png"));
        }
      case "09n":
        {
          return Image(image: AssetImage("images/09d@2x.png"));
        }
      case "10d":
        {
          return Image(image: AssetImage("images/10d@2x.png"));
        }
      case "10n":
        {
          return Image(image: AssetImage("images/10n@2x.png"));
        }
      case "11d":
        {
          return Image(image: AssetImage("images/11d@2x.png"));
        }
      case "11n":
        {
          return Image(image: AssetImage("images/11d@2x.png"));
        }
      case "13d":
        {
          return Image(image: AssetImage("images/13d@2x.png"));
        }
      case "13n":
        {
          return Image(image: AssetImage("images/13d@2x.png"));
        }
      case "50d":
        {
          return Image(image: AssetImage("images/50d@2x.png"));
        }
      case "50n":
        {
          return Image(image: AssetImage("images/50d@2x.png"));
        }
      default:
        {
          return Image(image: AssetImage("images/01d@2x.png"));
        }
    }
  }

  SizedBox ListViewItem(SixDaysWeather sixDaysWeather ){
    return SizedBox(
      width: 65,
      height: 65,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 5, left: 3, right: 3),
          child: Column(
            children:  [
              Text(
                "${DateFormat.MMMd().format(DateTime.fromMillisecondsSinceEpoch(sixDaysWeather!.dataTime.toInt() * 1000))}",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13),
              ),
              Expanded(child: setIconForMain(sixDaysWeather.icon)),
              Text(
                "${sixDaysWeather.temp.round()}°",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<CurrentCityDataModel> sendRequestCurrentWeather(
      String cityName) async {
    var response = await Dio().get(
        "https://api.openweathermap.org/data/2.5/weather?q=${cityName}&appid=${apikey}&units=metric");
    print(response.data);
    print(response.statusCode);
    lat = response.data["coord"]["lat"];
    lon = response.data["coord"]["lon"];

    var dataModel = CurrentCityDataModel.fromJson(jsonDecode(response.toString()));


    return dataModel ;

  }

  void sendRequestForSixDays(lat,lon) async {
    try{
      List<SixDaysWeather> list = [];

      var response = await Dio().get(
          "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${apikey}&units=metric&cnt=40");


      for(int i = 0;i<40;i+=8){
        var model = response.data["list"][i];


        var datamodel = SixDaysWeather(model["dt"], model["main"]["temp"], model["weather"][0]["icon"]);

        list.add(datamodel);
      }


      streamController.add(list);

    }
    on DioError catch (e){
      print(e.response!.statusCode);
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("there is an")));
    }

  }
}
