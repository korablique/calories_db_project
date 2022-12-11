import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter your login and password'),
      ),
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login: '),
                  SizedBox(
                      width: 300,
                      child: TextField(controller: _loginController)),
                ]),
            SizedBox(height: 16),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Password: '),
                  SizedBox(
                      width: 300,
                      child: TextField(controller: _passwordController)),
                ]),
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: _login,
        child: const Icon(Icons.check),
      ),
    );
  }

  void _login() async {
    try {
      await PsqlConnectionHolder.init(
          _loginController.text, _passwordController.text);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error in login data! Error: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
