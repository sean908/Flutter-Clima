import 'package:geolocator/geolocator.dart';

class LocationService {
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100,
  );

  /// 获取当前位置
  Future<Position?> getCurrentLocation() async {
    print('LocationService: 开始获取位置');
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('LocationService: 位置服务状态: $serviceEnabled');
    if (!serviceEnabled) {
      print('位置服务被禁用');
      return null;
    }

    // 检查权限
    permission = await Geolocator.checkPermission();
    print('LocationService: 当前权限状态: $permission');
    if (permission == LocationPermission.denied) {
      print('LocationService: 请求位置权限');
      permission = await Geolocator.requestPermission();
      print('LocationService: 权限请求结果: $permission');
      if (permission == LocationPermission.denied) {
        print('位置权限被拒绝');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('位置权限被永久拒绝，无法请求权限');
      return null;
    }

    // 权限已授予，获取位置
    try {
      print('LocationService: 开始获取具体位置');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      print('LocationService: 获取位置成功: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('获取位置时出错: $e');
      return null;
    }
  }
}


