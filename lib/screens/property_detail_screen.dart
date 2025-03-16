import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../models/property_status.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            _buildSectionTitle('基本信息'),
            _buildInfoRow('名称', property.name),
            _buildInfoRow('类型', property.type),
            _buildInfoRow('地址', property.address),
            _buildInfoRow('描述', property.description),
            _buildImageGallery(property.images),

            // 设施
            _buildSectionTitle('设施'),
            _buildFacilities(property.facilities),

            // 状态
            _buildSectionTitle('状态'),
            _buildInfoRow('房源状态', property.status),
            _buildAvailableFrom('可用日期', property.availableFrom),

            // 价格
            _buildSectionTitle('价格'),
            _buildInfoRow('基础价格', '${property.basePrice} 元'),
            _buildInfoRow('节假日价格', '${property.holidayPrice} 元'),
            _buildInfoRow('附加费用', '${property.additionalFees} 元'),

            // 库存
            _buildSectionTitle('库存'),
            _buildInfoRow('可预订房间数量', '${property.availableRooms} 间'),

            // 规则
            _buildSectionTitle('规则'),
            _buildInfoRow('最少入住天数', '${property.minStayDays} 天'),
            _buildInfoRow('入住时间', property.checkInTime),
            _buildInfoRow('退房时间', property.checkOutTime),
            _buildInfoRow('取消政策', property.cancellationPolicy),

            // 评价
            _buildSectionTitle('评价'),

            ...property.reviews.map((review) => _buildReview(review)).toList(),

            // 位置信息
            // _buildSectionTitle('位置信息'),
            // _buildInfoRow('经纬度', '${property.latitude}, ${property.longitude}'),
            // _buildInfoRow('周边设施', property.nearbyFacilities.join(', ')),
            // _buildInfoRow('交通指南', property.transportationGuide),

            // 附加服务
            // _buildSectionTitle('附加服务'),
            // _buildInfoRow('服务', property.additionalServices.join(', ')),

            // 运营数据
            // _buildSectionTitle('运营数据'),
            // _buildInfoRow('入住率', '${property.occupancyRate}%'),
            // _buildInfoRow('收入统计', '${property.revenue} 元'),
            // _buildInfoRow('客户来源', property.customerSource),

            // 历史记录
            // _buildSectionTitle('历史记录'),
            // ...property.historyRecords
            //     .map((record) => _buildHistoryRecord(record))
            //     .toList(),
          ],
        ),
      ),
    );
  }

  // 构建标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // 构建图片库
  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.network(
              images[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  // 构建设施
  Widget _buildFacilities(List<String> facilities) {
    return Wrap(
      spacing: 8.0,
      children: facilities.map((entry) {
        return Chip(
          label: Text(entry),
          backgroundColor:
              entry.isNotEmpty ? Colors.green[100] : Colors.red[100],
        );
      }).toList(),
    );
  }

  // 可使用日期
  //
  Widget _buildAvailableFrom(String label, Map<String, bool> availableFrom) {
    return Column(
      children: [
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // 使用 ListView 展示
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: availableFrom.entries.map((entry) {
                final date = entry.key;
                final isAvailable = entry.value;
                return ListTile(
                  title: Text(date),
                  trailing: Icon(
                    isAvailable ? Icons.check_circle : Icons.cancel,
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                  subtitle: Text(isAvailable ? '可用' : '不可用'),
                );
              }).toList(),
            ),
          ],
        )
      ],
    );
  }

  // 构建评价
  Widget _buildReview(Reviews review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用户: ${review.user}'),
            Text('评分: ${review.rating}'),
            Text('评论: ${review.comment}'),
            if (review.reply.isNotEmpty) Text('回复: ${review.reply}'),
          ],
        ),
      ),
    );
  }

  // 构建历史记录
  // Widget _buildHistoryRecord(HistoryRecord record) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('时间: ${record.timestamp}'),
  //           Text('操作: ${record.action}'),
  //           Text('用户: ${record.user}'),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
