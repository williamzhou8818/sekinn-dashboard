import 'package:flutter/material.dart';
import 'package:seikinn_dashboard/screens/property/property_edit_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/property_model.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month; // 日历格式（月/周）
  DateTime _focusedDay = DateTime.now(); // 当前聚焦的日期
  DateTime? _selectedDay = DateTime.now();
  late String _selectedStatus;
  Map<DateTime, Map<String, dynamic>> _events = {};

  @override
  void initState() {
    super.initState();

    // Initialize event data and selected values
    _events = {
      _normalizeDate(DateTime(2025, 3, 20)): {'status': '可用', 'price': 200},
      _normalizeDate(DateTime(2025, 3, 21)): {'status': '已预订', 'price': 300},
      _normalizeDate(DateTime(2025, 3, 22)): {'status': '待审核', 'price': 250},
    };

    _selectedStatus = widget.property.status;
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final maxContentWidth =
        isSmallScreen ? double.infinity : 800.0; // 在大屏幕上限制内容宽度为 800px

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.name),
        actions: [
          // 添加编辑按钮
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              // 跳转到编辑页面并等待返回结果
              var updateProperty = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditPropertyScreen(property: widget.property),
                ),
              );
              if (updateProperty != null) {
                setState(() {
                  widget.property.name = updateProperty['name'];
                  widget.property.address = updateProperty['address'];
                  widget.property.type = updateProperty['type'];
                  widget.property.description = updateProperty['description'];
                  widget.property.status = updateProperty['status'];
                });
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: maxContentWidth, // 限制内容宽度
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片轮播
                _buildImageSlider(isSmallScreen),
                // 基本信息
                _buildBasicInfo(isSmallScreen),
                // 设施
                _buildFacilities(isSmallScreen),
                // 可用日期/价格
                _buildAvailableFrom('可用日期/价格', _events, isSmallScreen),
                // 评价
                _buildSectionTitle('评价'),
                ...widget.property.reviews
                    .map((review) => _buildReviewItem(review, isSmallScreen))
                    .toList(),
                // 规则
                _buildSectionTitle('规则'),
                _buildInfoRow('最少入住天数', '${widget.property.minStayDays} 天'),
                _buildInfoRow('入住时间', widget.property.checkInTime),
                _buildInfoRow('退房时间', widget.property.checkOutTime),
                _buildInfoRow('取消政策', widget.property.cancellationPolicy),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 图片轮播组件
  Widget _buildImageSlider(bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 150 : 250, // 根据屏幕尺寸调整高度
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.property.images.length,
            itemBuilder: (ctx, index) => Image.network(
              widget.property.images[index],
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.property.images.length}张',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 基础信息组件
  Widget _buildBasicInfo(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.property.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isSmallScreen) // 在小屏幕上隐藏类型标签
                Expanded(
                  child: Chip(
                    backgroundColor: Color.fromARGB(255, 141, 174, 245),
                    label: Text(
                      widget.property.type,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              Chip(
                backgroundColor: Colors.green,
                label: Text(
                  _selectedStatus,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.property.address,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.property.description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              Text(
                '4.8 (${widget.property.reviews.length} 条评价)',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 117, 117, 117),
        ),
      ),
    );
  }

  // 可用日期/价格组件
  Widget _buildAvailableFrom(String label,
      Map<DateTime, Map<String, dynamic>> event, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime(2023, 1, 1), // 日历的起始日期
            lastDay: DateTime(2025, 12, 31), // 日历的结束日期
            focusedDay: _focusedDay, // 当前聚焦的日期
            calendarFormat: isSmallScreen
                ? CalendarFormat.week
                : _calendarFormat, // 在小屏幕上默认显示周视图
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                // Normalize the selectedDay and check in the events map
                DateTime normalizedSelectedDay = _normalizeDate(selectedDay);
                print(selectedDay);
                _selectedStatus = _events[normalizedSelectedDay]?['status'] ??
                    'Unknown'; // Default to 'Unknown' if no event is found
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format; // 更新日历格式
              });
            },
            eventLoader: (day) {
              final formattedDay =
                  DateTime(day.year, day.month, day.day); // 去掉时间部分
              print(
                  'Loading events for $formattedDay: ${event[formattedDay]}'); // 调试日志
              return event[formattedDay] != null ? [event[formattedDay]] : [];
            },
            calendarBuilders: CalendarBuilders(
              // 自定义日历标记
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  final event = events.first as Map<String, dynamic>; // 强制类型转换
                  return Container(
                    width: 40, // 调整宽度
                    height: 40, // 调整高度
                    decoration: BoxDecoration(
                      color: event['status'] == 'booked'
                          ? Colors.red
                          : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: event['status'] == 'booked'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          if (event['price'] != null)
                            Text(
                              '¥${event['price']}',
                              style: TextStyle(
                                color: event['status'] == 'booked'
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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

  // 设施标签组件
  Widget _buildFacilities(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.property.facilities
            .map<Widget>((f) => Chip(
                  label: Text(f),
                  backgroundColor: Colors.blue[50],
                ))
            .toList(),
      ),
    );
  }

  // 构建评价
  Widget _buildReviewItem(Reviews review, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.user,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      review.rating.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  review.createdAt,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
