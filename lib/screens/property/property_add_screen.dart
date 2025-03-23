import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:seikinn_dashboard/models/property_status.dart';
import '../../models/property_model.dart';
import '../../services/api_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  AddPropertyScreenState createState() => AddPropertyScreenState();
}

class AddPropertyScreenState extends State<AddPropertyScreen> {
  // List of available facilities in Chinese
  final List<String> facilities = ["无线网络", "停车场", "游泳池", "健身房"];
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$', // 货币符号
    decimalDigits: 2, // 小数点后位数
  );

  // This will hold the selected facilities
  List<String> selectedFacilities = [];
  List<String> imageList = [];
  // Availability data: Date => {status, price}
  Map<String, Map<String, dynamic>> _events = {};

  final List<String> _typeOptions = [
    '海景房',
    '城市景观',
    '豪华套房',
    '单人房',
    '双人房',
    '家庭房',
    '商务房'
  ];
  String _selectedType = '海景房'; // Default to first item";

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _statusController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _holidayPriceController = TextEditingController();
  final _additionalFees = TextEditingController();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  final _cancellationPolicyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化当天的可用性数据
    _initializeAvailability();
  }

  // 初始化当天的可用性数据
  void _initializeAvailability() {
    // Initialize event data and selected values
    _events = {
      _normalizeDate(DateTime.now()).toString(): {
        'status': '可用',
        'price': 20000
      }
    };
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final maxContentWidth =
        isSmallScreen ? double.infinity : 800.0; // 在大屏幕上限制内容宽度为 800px

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加房源'),
        actions: [
          IconButton(onPressed: _saveProperty, icon: const Icon(Icons.save))
        ],
      ),
      body: Center(
        child: Container(
          width: maxContentWidth, // 限制内容宽度
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 基本信息
                _buildTextField(_nameController, '名称'),
                const SizedBox(height: 10),
                _buildTextField(_addressController, '地址'),
                const SizedBox(height: 10),
                _buildTextField(_descController, '描述'),
                const SizedBox(height: 10),
                // 照片
                _buildImageList(_imageController),
                // 设施
                const SizedBox(height: 10),
                const Text("选择的设施:"),
                Wrap(
                  children: selectedFacilities.map((facility) {
                    return Chip(label: Text(facility));
                  }).toList(),
                ),
                // Display the list of checkboxes
                ...facilities.map((facility) {
                  return CheckboxListTile(
                    title: Text(facility),
                    value: selectedFacilities.contains(facility),
                    onChanged: (bool? selected) {
                      _onFacilityChanged(selected, facility);
                    },
                  );
                }).toList(),
                // Prices
                _buildNumberField(_basePriceController, '基本定价'),
                const SizedBox(height: 10),
                _buildNumberField(_holidayPriceController, '节假日定价'),
                const SizedBox(height: 10),
                _buildDropdownField('房型', _typeOptions, _selectedType,
                    (newValue) {
                  setState(() {
                    _selectedType = newValue as String;
                  });
                }),
                // Check-In Time Picker
                TextField(
                  controller: _checkInController,
                  decoration: InputDecoration(
                    labelText: '入住时间',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () =>
                          _selectCheckInTime(context, _checkInController),
                    ),
                  ),
                  readOnly: true, // Prevent manual input
                  onTap: () => _selectCheckInTime(
                      context, _checkInController), // Open time picker on tap
                ),
                const SizedBox(height: 10),
                // Check-Out Time Picker
                TextField(
                  controller: _checkOutController,
                  decoration: InputDecoration(
                    labelText: '退房时间',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () =>
                          _selectCheckInTime(context, _checkOutController),
                    ),
                  ),
                  readOnly: true, // Prevent manual input
                  onTap: () => _selectCheckInTime(
                      context, _checkInController), // Open time picker on tap
                ),
                const SizedBox(height: 10),
                // 取消预约规约
                TextFormField(
                  controller: _cancellationPolicyController,
                  decoration: InputDecoration(
                    labelText: '预定取消规约',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // allow multi-line input
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a text field with a label
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true), // 允许小数
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // 允许数字和小数点
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (value.isEmpty) {
          return;
        }

        // 解析输入值为 double
        double parsedValue = double.tryParse(value) ?? 0.0;

        // 更新控制器值，但保留光标位置
        final int cursorPosition = controller.selection.base.offset;
        controller.value = TextEditingValue(
          text: parsedValue.toString(),
          selection: TextSelection.collapsed(
            offset: cursorPosition > parsedValue.toString().length
                ? parsedValue.toString().length
                : cursorPosition,
          ),
        );
      },
    );
  }

  Widget _buildImageList(TextEditingController controller) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '房源图片',
            hintText: 'https://yourimages.jpg',
          ),
          keyboardType: TextInputType.url,
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              imageList.add(controller.text.trim());
              controller.clear(); // 清空输入框
            });
          },
          child: Text('添加图片'),
        ),
        const SizedBox(height: 10),
        // 显示已添加的图片
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // 禁止滚动
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 每行显示 3 张图片
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: imageList.length,
          itemBuilder: (context, index) {
            return Image.network(
              imageList[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('无法加载图片'));
              },
            );
          },
        ),
      ],
    );
  }

  // Function to show the time picker
  Future<void> _selectCheckInTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Default to current time
    );

    if (pickedTime != null) {
      setState(() {
        // Format the selected time as a string (e.g., "14:00")
        controller.text =
            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      });
    }
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
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Method to handle checkbox changes
  void _onFacilityChanged(bool? selected, String facility) {
    setState(() {
      if (selected!) {
        // Add facility to selected list
        selectedFacilities.add(facility);
      } else {
        // Remove facility from selected list
        selectedFacilities.remove(facility);
      }
    });
  }

  void _saveProperty() async {
    // Trim extra spaces from each item in the selectedFacilities list
    selectedFacilities =
        selectedFacilities.map((facility) => facility.trim()).toList();
    imageList = imageList.map((image) => image.trim()).toList();
    // 创建房源对象
    final property = Property(
        id: DateTime.now().toString(),
        name: _nameController.text,
        type: _selectedType,
        address: _addressController.text,
        description: _descController.text,
        facilities: selectedFacilities,
        images: imageList,
        status: "可用", // fixed
        basePrice: double.tryParse(_basePriceController.text) ?? 0.0,
        holidayPrice: double.tryParse(_holidayPriceController.text) ?? 0.0,
        additionalFees: 10000.00,
        availableRooms: 1,
        minStayDays: '1',
        checkInTime: _checkInController.text,
        checkOutTime: _checkOutController.text,
        cancellationPolicy: _cancellationPolicyController.text,
        reviews: [],
        availableFrom: _events ?? <String, Map<String, dynamic>>{});

    try {
      // 调用 API 保存房源
      await ApiService.saveProperty(property);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('房源保存成功！')),
      );
      // 返回 true 表示需要刷新数据
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存房源失败: $e')),
      );
      Navigator.pop(context, false);
    }
  }
}
