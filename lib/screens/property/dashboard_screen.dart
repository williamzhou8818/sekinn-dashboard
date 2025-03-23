import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/data.dart';
import '../../widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 根据屏幕宽度调整布局
          if (constraints.maxWidth > 600) {
            // Web或平板布局
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 每行显示4个卡片
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: dashboardItems.length,
              itemBuilder: (context, index) {
                return DashboardCard(
                  title: dashboardItems[index].title,
                  value: dashboardItems[index].value,
                  icon: dashboardItems[index].icon,
                );
              },
            );
          } else {
            // 手机布局
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dashboardItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DashboardCard(
                    title: dashboardItems[index].title,
                    value: dashboardItems[index].value,
                    icon: dashboardItems[index].icon,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
