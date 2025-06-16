import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location.dart';
import '../services/networking.dart';
import '../services/weather.dart';
import '../utilities/error_handler.dart';
import 'location_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final WeatherModel weatherModel = WeatherModel();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('LoadingScreen: initState');
    getLocationData();
  }

  Future<void> getLocationData() async {
    print('LoadingScreen: 开始获取位置数据');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('LoadingScreen: 调用 getLocationWeather');
      var weatherData = await weatherModel.getLocationWeather();
      print('LoadingScreen: 获取到天气数据: ${weatherData != null}');
      
      if (weatherData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LocationScreen(weatherData: weatherData);
            },
          ),
        );
      } else {
        setState(() {
          _errorMessage = '无法获取天气数据';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('LoadingScreen: 发生错误: $e');
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/location_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.8), BlendMode.dstATop),
          ),
        ),
        child: Center(
          child: _isLoading
              ? SpinKitDoubleBounce(
                  color: Colors.white,
                  size: 100.0,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage ?? '发生错误',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: getLocationData,
                      child: Text('重试'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
