import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  final String apiKey = 'YOUR_API_KEY';
  

  /// 根据经纬度获取天气数据
  Future<dynamic> getWeatherData({required double latitude, required double longitude}) async {
    print('NetworkHelper: 开始获取位置天气数据');
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey');
    return await _getRequest(url);
  }
  
  /// 根据城市名称获取天气数据
  Future<dynamic> getWeatherByCity(String cityName) async {
    print('NetworkHelper: 开始获取城市天气数据: $cityName');
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey');
    return await _getRequest(url);
  }
  
  /// 执行HTTP GET请求
  Future<dynamic> _getRequest(Uri url) async {
    try {
      print('NetworkHelper: 发送请求: $url');
      final response = await http.get(url);
      print('NetworkHelper: 收到响应: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null) {
          throw Exception('返回数据为空');
        }
        print('NetworkHelper: 解析数据成功');
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('未找到城市');
      } else if (response.statusCode == 401) {
        throw Exception('API密钥无效');
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('NetworkHelper: 网络请求错误: $e');
      rethrow;
    }
  }
}

