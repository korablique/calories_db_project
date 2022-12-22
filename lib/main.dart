import 'package:calories_db_project/home_page.dart';
import 'package:calories_db_project/login_page.dart';
import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:calories_db_project/tabs_page.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements PsqlConnectionHolderListener {
  var _psqlInited = false;

  @override
  void initState() {
    super.initState();
    _psqlInited = PsqlConnectionHolder.inited();
    PsqlConnectionHolder.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    PsqlConnectionHolder.removeListener(this);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My calories diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _psqlInited
          ? const TabsPage()
          : const LoginPage(),
    );
  }

  @override
  void onDbConnectionInited() {
    setState(() {
      _psqlInited = PsqlConnectionHolder.inited();
    });
  }
}
