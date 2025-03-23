import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/property_model.dart';
import '../../services/api_service.dart';

class EditPropertyScreen extends StatefulWidget {
  final Property property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  EditPropertyEditScreenState createState() => EditPropertyEditScreenState();
}

class EditPropertyEditScreenState extends State<EditPropertyScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Availability data: Date => {status, price}
  Map<DateTime, Map<String, dynamic>> _events = {};

  // Available options for status and type
  final List<String> _statusOptions = [
    '可用',
    '已预订',
    '已入住',
    '维修中',
    '已下线',
    '待审核',
    '审核未通过',
    '清洁中',
    '锁定',
    '已删除',
    '待确认',
    '等待付款',
    '暂停服务',
    '上架中',
    '已过期',
    '待处理',
    '未知状态'
  ];

  final List<String> _typeOptions = [
    '海景房',
    '城市景观',
    '豪华套房',
    '单人房',
    '双人房',
    '家庭房',
    '商务房'
  ];

  String? _selectedType;
  String? _selectedStatus;

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();

    // Initialize event data and selected values
    _events = {
      DateTime(2025, 3, 20): {'status': '可用', 'price': 200},
      DateTime(2025, 3, 21): {'status': '已预订', 'price': 300},
      DateTime(2025, 3, 22): {'status': '待审核', 'price': 250},
    };

    _selectedType = widget.property.type;
    _selectedStatus = widget.property.status;

    _nameController = TextEditingController(text: widget.property.name);
    _addressController = TextEditingController(text: widget.property.address);
    _descController = TextEditingController(text: widget.property.description);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final maxContentWidth =
        isSmallScreen ? double.infinity : 800.0; // 在大屏幕上限制内容宽度为 800px

    return Scaffold(
      appBar: AppBar(
        title: const Text("编辑房源"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: maxContentWidth, // 限制内容宽度
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(_nameController, '名称'),
                const SizedBox(height: 10),
                _buildDropdownField('房型', _typeOptions, _selectedType,
                    (newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                }),
                const SizedBox(height: 10),
                _buildTextField(_addressController, '地址'),
                const SizedBox(height: 10),
                _buildTextField(_descController, '描述'),
                const SizedBox(height: 10),
                _buildSelectedDateDetails(),
                TableCalendar(
                  firstDay: DateTime(2023, 1, 1),
                  lastDay: DateTime(2025, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showDateDialog(selectedDay);
                  },
                  eventLoader: (day) {
                    final formattedDay = DateTime(day.year, day.month, day.day);
                    if (_events.containsKey(formattedDay)) {
                      return [_events[formattedDay]!];
                    }
                    return [];
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        final event = events.first as Map<String, dynamic>;
                        return _buildEventMarker(day, event);
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Save Changes
  void _saveChanges() async {
    final newName = _nameController.text.trim();
    final newDesc = _descController.text.trim();
    final updatedFields = {
      "name": newName,
      "type": _selectedType,
      "address": _addressController.text.trim(),
      "description": newDesc,
      "status": _selectedStatus,
    };

    try {
      await ApiService.updateProperty(widget.property.id, updatedFields);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('房源信息更新成功！')));
      Navigator.pop(context, updatedFields);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('更新失败，请重试！')));
    }
  }

  // Build a text field with a label
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  // Build a dropdown field
  Widget _buildDropdownField(String label, List<String> options,
      String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Build an event marker for the calendar
  Widget _buildEventMarker(DateTime day, Map<String, dynamic> event) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: event['status'] == 'booked'
            ? Colors.red
            : event['status'] == 'underMaintenance'
                ? Colors.orange
                : Colors.green,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day.day.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12)),
            Text('¥${event['price']}',
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // Build selected date details
  Widget _buildSelectedDateDetails() {
    final selectedDate = _events[_selectedDay];
    if (selectedDate != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("日期: ${_selectedDay?.toLocal().toString().split(' ')[0]}"),
          Text("状态: ${selectedDate['status']}"),
          Text("价格: ¥${selectedDate['price']}"),
        ],
      );
    }
    return const Text("No events for selected date");
  }

  // Show date dialog to update status and price
  Future<void> _showDateDialog(DateTime selectedDay) async {
    late TextEditingController _priceController = TextEditingController();
    String? _selectedStatus = _events[selectedDay]?['status'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("设置状态/价格 ${selectedDay.toLocal().toString().split(' ')[0]}"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  hint: Text('状态'),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '价格(元)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() {
                  _events[selectedDay] = {
                    'status': _selectedStatus ?? 'available',
                    'price': double.tryParse(_priceController.text) ?? 0.0,
                  };
                });
                // Print the updated event data to verify
                print('Updated Event for ${selectedDay.toLocal()}:');
                print(_events[selectedDay]);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
