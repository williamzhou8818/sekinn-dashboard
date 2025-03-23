import 'package:flutter/material.dart';
import 'package:seikinn_dashboard/screens/property/property_add_screen.dart';
import 'package:seikinn_dashboard/screens/property/property_detail_screen.dart';
import 'package:seikinn_dashboard/services/api_service.dart';
import '../../models/property_model.dart';
import 'package:go_router/go_router.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  PropertyListScreenState createState() => PropertyListScreenState();
}

class PropertyListScreenState extends State<PropertyListScreen> {
  late Future<List<Property>> _propertiesFuture;
  List<Property> _properties = []; // List to hold properties
  String _sortBy = 'name'; // Default sorting by name
  bool _ascending = true; // Sort order (ascending by default)

  @override
  void initState() {
    super.initState();
    _propertiesFuture = ApiService.getProperties().then((properties) {
      setState(() {
        _properties = properties; // Initialize the list
      });
      return properties;
    });
  }

  // Function to sort properties
  void _sortProperties(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _ascending = !_ascending; // Toggle sort order

      switch (sortBy) {
        case 'name':
          _properties.sort((a, b) =>
              _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
          break;
        case 'status':
          _properties.sort((a, b) => _ascending
              ? a.status.compareTo(b.status)
              : b.status.compareTo(a.status));
          break;
        case 'address':
          _properties.sort((a, b) => _ascending
              ? a.address.compareTo(b.address)
              : b.address.compareTo(a.address));
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('房源管理'),
        actions: [
          // Dropdown for sorting
          DropdownButton<String>(
            value: _sortBy,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _sortProperties(newValue);
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'name',
                child: Text('按名称排序'),
              ),
              DropdownMenuItem(
                value: 'status',
                child: Text('按状态排序'),
              ),
              DropdownMenuItem(
                value: 'address',
                child: Text('按地址排序'),
              ),
            ],
          ),
        ],
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
                context.go('/properties');
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
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('加载房源列表失败: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('暂无房源信息'));
          } else {
            return _buildPropertyTable(context, isSmallScreen);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPropertyScreen(),
            ),
          );
          if (shouldRefresh == true) {
            setState(() {
              _propertiesFuture = ApiService.getProperties();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build the property table
  Widget _buildPropertyTable(BuildContext context, bool isSmallScreen) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 800, // 设置最小宽度为 800px
          maxWidth: isSmallScreen ? double.infinity : 1200, // 在大屏幕上最大宽度为 1200px
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive layout: Use DataTable for large screens, ListView for small screens
                  if (constraints.maxWidth > 600) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: DataTable(
                              columnSpacing: 100,
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Color.fromARGB(255, 211, 212, 212),
                              ),
                              columns: const [
                                DataColumn(label: Text('#ID')),
                                DataColumn(label: Text('操作')),
                                DataColumn(label: Text('名称')),
                                DataColumn(label: Text('地址')),
                                DataColumn(label: Text('状态')),
                              ],
                              rows: _properties.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final property = entry.value;
                                return DataRow(
                                  cells: [
                                    DataCell(Text(index.toString())),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.info),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PropertyDetailScreen(
                                                          property: property),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(SizedBox(
                                      child: Text(property.name),
                                    )),
                                    DataCell(SizedBox(
                                      child: Text(property.address),
                                    )),
                                    DataCell(SizedBox(
                                      child: Text(property.status),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    // For small screens, use a ListView
                    return ListView.builder(
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        final property = _properties[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(property.name),
                            subtitle: Text(property.address),
                            trailing: Text(property.status),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailScreen(property: property),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
