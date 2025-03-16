import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:seikinn_dashboard/models/property_status.dart';

import '../models/property_model.dart';
import '../services/api_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  AddPropertyScreenState createState() => AddPropertyScreenState();
}

class AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _facilitiesController = TextEditingController();
  final _photosController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加房源'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30), // **只让表格往下移动 30px**

            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500), // 设置最大宽度
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                    crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '房源名称',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入房源名称';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: '地址',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入地址';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '描述',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入描述';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _facilitiesController,
                        decoration: const InputDecoration(
                          labelText: '设施（用逗号分隔）',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入设施';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveProperty,
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProperty() async {
    if (_formKey.currentState!.validate()) {
      // 创建房源对象
      final property = Property(
          id: DateTime.now().toString(),
          name: _nameController.text,
          type: "",
          address: _addressController.text,
          description: _descriptionController.text,
          facilities: _facilitiesController.text.split(','),
          images: _photosController.text.split(','),
          status: "",
          basePrice: 200.00,
          holidayPrice: 2000.00,
          additionalFees: 10000.00,
          availableRooms: 10,
          minStayDays: '10',
          checkInTime: '14:00',
          checkOutTime: '10:00',
          cancellationPolicy: '',
          reviews: [],
          availableFrom: {});

      try {
        // 调用 API 保存房源
        await ApiService.saveProperty(property);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('房源保存成功！')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存房源失败: $e')),
        );
      }
    }
  }
}
