import 'package:postgres/postgres.dart';

class PsqlConnectionHolder {
  static PsqlConnectionHolder? _instance;

  PsqlConnectionHolder._();

  final connection = PostgreSQLConnection("localhost", 5432, "postgres",
      username: "postgres", password: "qweexrty");

  static Future<PsqlConnectionHolder> instance() async {
    if (_instance == null) {
      _instance = PsqlConnectionHolder._();
      await _instance!.connection.open();
      // await _instance!.connection.query("SELECT f_create_db('calories_db');");
      await _instance!.connection.query("SELECT f_init_tables();");
      await _instance!.connection.query("SELECT f_init_triggers();");
    }
    return _instance!;
  }
}
