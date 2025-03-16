import 'package:dio/dio.dart';
import '../models/property_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.56.1:8080'; // Go API 地址
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // 将状态枚举转换为可读的字符串

  static String getStatusText(String value) {
    switch (value) {
      case 'available':
        return '可用';
      case 'booked':
        return '已预订';
      case 'occupied':
        return '已入住';
      case 'underMaintenance':
        return '维修中';
      case 'offline':
        return '已下线';
      case 'pendingReview':
        return '待审核';
      case 'reviewRejected':
        return '审核未通过';
      case 'cleaning':
        return '清洁中';
      case 'locked':
        return '锁定';
      case 'deleted':
        return '已删除';
      default:
        return '未知状态'; // 默认返回值
    }
  }

  // 保存房源信息
  static Future<void> saveProperty(Property property) async {
    try {
      final response = await _dio.post(
        '/properties',
        data: property.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201) {
        print('房源保存成功！');
      } else {
        throw Exception('保存房源失败: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('保存房源失败: ${e.message}');
    }
  }

  // 获取房源列表
  static Future<List<Property>> getProperties() async {
    try {
      final response = await _dio.get('/properties');
      print('API 响应: ${response.data}'); // 打印响应数据

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null || data is! List) {
          return []; // 返回空列表
        }

        return data
            .map((item) => Property(
                  id: item['id'],
                  name: item['name'],
                  address: item['address'],
                  type: item['type'],
                  description: item['description'],
                  facilities:
                      List<String>.from(item['facilities'] ?? []), // 处理空值
                  images: List<String>.from(item['images'] ?? []), // 处理空值
                  status: getStatusText(item['status']),
                  availableFrom: Map<String, bool>.from(item['available_from']),
                  basePrice: (item['base_price'] as num).toDouble(),
                  holidayPrice: (item['holiday_price'] as num).toDouble(),
                  additionalFees: (item['additional_fees'] as num).toDouble(),
                  availableRooms: (item['available_rooms'] as num).toInt(),
                  minStayDays: item['min_stay_days'],
                  checkInTime: item['check_in_time'],
                  checkOutTime: item['check_out_time'],
                  cancellationPolicy: item['cancellation_policy'],
                  reviews: (item['reviews'] as List<dynamic>?) // 处理空值
                          ?.map((review) => Reviews.fromJson(review))
                          .toList() ??
                      [], // 如果 reviews 为空，则返回空列表, // 处理空值
                ))
            .toList();
      } else {
        throw Exception('获取房源列表失败: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('服务器错误: ${e.response!.data}');
      } else {
        print('网络错误: ${e.message}');
      }
      throw Exception('获取房源列表失败: ${e.message}');
    } catch (e) {
      print('未知错误: $e');
      throw Exception('获取房源列表失败: $e');
    }
  }
}
