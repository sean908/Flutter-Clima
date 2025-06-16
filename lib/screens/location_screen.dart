import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import '../services/weather.dart';
import '../utilities/error_handler.dart';
import '../services/weather_icons.dart';
import 'city_screen.dart';

class LocationScreen extends StatefulWidget {
  final dynamic weatherData;

  LocationScreen({this.weatherData});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weather = WeatherModel();
  int temperature = 0;
  String weatherIcon = '';
  String cityName = '';
  String weatherMessage = '';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    updateUI(widget.weatherData);
  }

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      temperature = 0;
      weatherIcon = '错误';
      weatherMessage = '无法获取天气数据';
      cityName = '';
      return;
    }

    setState(() {
      double temp = weatherData['main']['temp'] - 273.15;
      temperature = temp.toInt();
      var condition = weatherData['weather'][0]['id'];
      weatherIcon = WeatherIcons.getWeatherIcon(condition);
      weatherMessage = WeatherIcons.getMessage(temperature);
      cityName = weatherData['name'];
    });
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      var weatherData = await weather.getLocationWeather();
      updateUI(weatherData);
    } catch (e) {
      ErrorHandler.showError(context, ErrorHandler.getErrorMessage(e));
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/location_background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.dstATop),
            ),
          ),
          constraints: BoxConstraints.expand(),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: _isRefreshing ? null : _refreshWeather,
                      child: Icon(
                        Icons.near_me,
                        size: 50.0,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        var typedName = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CityScreen(),
                          ),
                        );
                        if (typedName != null) {
                          try {
                            var weatherData = await weather.getCityWeather(typedName);
                            updateUI(weatherData);
                          } catch (e) {
                            ErrorHandler.showError(context, ErrorHandler.getErrorMessage(e));
                          }
                        }
                      },
                      child: Icon(
                        Icons.location_city,
                        size: 50.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '$temperature°',
                        style: kTempTextStyle,
                      ),
                      Text(
                        weatherIcon,
                        style: kConditionTextStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Text(
                    '$weatherMessage in $cityName',
                    textAlign: TextAlign.right,
                    style: kMessageTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
