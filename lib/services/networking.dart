import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  final String apiKey = 'YOUR_API_KEY';
  
  /// 根据经纬度获取天气数据
  Future<dynamic> getWeatherData({required double latitude, required double longitude}) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey');
    return await _getRequest(url);
  }
  
  /// 根据城市名称获取天气数据
  Future<dynamic> getWeatherByCity(String cityName) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey');
    return await _getRequest(url);
  }
  
  /// 执行HTTP GET请求
  Future<dynamic> _getRequest(Uri url) async {
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('请求失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('网络请求错误: $e');
      return null;
    }
  }
}

