import 'networking.dart';
import 'location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeatherModel {
  final NetworkHelper networkHelper = NetworkHelper();
  final LocationService locationService = LocationService();
  static const String _cacheKey = 'weather_cache';
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// 获取当前位置的天气数据
  Future<dynamic> getLocationWeather() async {
    try {
      Position? position = await locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('无法获取位置信息');
      }

      final weatherData = await networkHelper.getWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (weatherData != null) {
        await _cacheWeatherData(weatherData);
      }
      return weatherData;
    } catch (e) {
      // 如果网络请求失败，尝试从缓存获取数据
      final cachedData = await _getCachedWeatherData();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  /// 通过城市名称获取天气数据
  Future<dynamic> getCityWeather(String cityName) async {
    try {
      final weatherData = await networkHelper.getWeatherByCity(cityName);
      if (weatherData != null) {
        await _cacheWeatherData(weatherData);
      }
      return weatherData;
    } catch (e) {
      final cachedData = await _getCachedWeatherData();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  /// 缓存天气数据
  Future<void> _cacheWeatherData(dynamic weatherData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': weatherData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_cacheKey, jsonEncode(cacheData));
    } catch (e) {
      print('缓存天气数据失败: $e');
    }
  }

  /// 获取缓存的天气数据
  Future<dynamic> _getCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_cacheKey);
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp > _cacheDuration.inMilliseconds) {
        return null;
      }

      return cacheData['data'];
    } catch (e) {
      print('获取缓存天气数据失败: $e');
      return null;
    }
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
