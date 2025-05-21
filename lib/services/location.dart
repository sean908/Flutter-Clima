import 'package:geolocator/geolocator.dart';

class LocationService {
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100,
  );

  /// 获取当前位置
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('位置服务被禁用');
      return null;
    }

    // 检查权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return position;
    } catch (e) {
      print('获取位置时出错: $e');
      return null;
    }
  }
}
