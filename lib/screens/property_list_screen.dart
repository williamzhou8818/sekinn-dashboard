import 'package:flutter/material.dart';
import 'package:seikinn_dashboard/screens/add_property_screen.dart';
import 'package:seikinn_dashboard/screens/property_detail_screen.dart';
import 'package:seikinn_dashboard/services/api_service.dart';
import '../models/property_model.dart';
import 'package:go_router/go_router.dart';

import '../models/property_status.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  PropertyListScreenState createState() => PropertyListScreenState();
}

class PropertyListScreenState extends State<PropertyListScreen> {
  late Future<List<Property>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = ApiService.getProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('房源管理'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    '民宿管理系统',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('房源管理'),
              onTap: () {
                context.go('/properties'); // 直接调用，不要返回
              },
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Property>>(
          future: ApiService.getProperties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('加载房源列表失败: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('暂无房源信息'));
            } else {
              final properties = snapshot.data!;
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 30), // **只让表格往下移动 30px**
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, // 垂直滑动
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // 水平滑动
                          child: Card(
                            margin: const EdgeInsets.all(16),
                            elevation: 4,
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  1.5, // 设置表格宽度为屏幕宽度的1.5倍
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                columnSpacing: 20, // 调整列间距
                                headingRowColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      Color.fromARGB(255, 211, 212, 212),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text('操作'),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Text('名称'),
                                    numeric: false, // 非数字列
                                  ),
                                  DataColumn(
                                    label: Text('地址'),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Text('状态'),
                                    numeric: false,
                                  ),
                                ],
                                rows: properties.map(
                                  (property) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.info),
                                                onPressed: () {
                                                  //詳細画面
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PropertyDetailScreen(
                                                              property:
                                                                  property),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 100, // 设置列宽
                                            child: Text(property.name),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 150, // 设置列宽
                                            child: Text(property.address),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 80, // 设置列宽
                                            child:
                                                Text(property.status), // 显示状态
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 添加房源
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPropertyScreen(),
            ),
          );
          if (shouldRefresh == true) {
            setState(() {
              // properties.add(newProperty);
              _propertiesFuture = ApiService.getProperties(); // 重新加载数据
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
