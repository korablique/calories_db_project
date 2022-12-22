import 'package:calories_db_project/history_page.dart';
import 'package:calories_db_project/home_page.dart';
import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter/material.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.fastfood_rounded)),
                Tab(icon: Icon(Icons.access_time_rounded)),
              ],
            ),
            actions: [
              IconButton(onPressed: _logOut, icon: const Icon(Icons.logout)),
            ],
            title: const Text('My calories diary')),
        body: const TabBarView(
          children: [
            HomePage(),
            HistoryPage(),
          ],
        ),
      ),
    );
  }

  void _logOut() async {
    await PsqlConnectionHolder.logOut();
  }
}
