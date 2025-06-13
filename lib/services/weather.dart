import 'networking.dart';
import 'location.dart';
import 'package:geolocator/geolocator.dart';

class WeatherModel {
  final NetworkHelper networkHelper = NetworkHelper();
  final LocationService locationService = LocationService();

  /// 获取当前位置的天气数据
  Future<dynamic> getLocationWeather() async {
    Position? position = await locationService.getCurrentLocation();
    if (position != null) {
      return await networkHelper.getWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
    return null;
  }

  /// 通过城市名称获取天气数据
  Future<dynamic> getCityWeather(String cityName) async {
    return await networkHelper.getWeatherByCity(cityName);
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}
