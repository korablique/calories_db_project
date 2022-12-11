import 'package:postgres/postgres.dart';

class PsqlConnectionHolder {
  static const _PSQL_DB_NAME = "postgres";
  static const _CALORIES_DB_NAME = "calories_db";
  static String? _login;
  static String? _password;
  static final _listeners = <PsqlConnectionHolderListener>[];

  static PsqlConnectionHolder? _instance;

  PsqlConnectionHolder._();

  late PostgreSQLConnection connection;

  static Future<PsqlConnectionHolder> instance() async {
    if (_instance == null) {
      PostgreSQLConnection? caloriesConnection;

      try {
        final connection = PostgreSQLConnection(
            "localhost", 5432, _CALORIES_DB_NAME,
            username: _login, password: _password);
        await connection.open();
        caloriesConnection = connection;
      } catch (e) {
        var connection = PostgreSQLConnection("localhost", 5432, _PSQL_DB_NAME,
            username: _login, password: _password);
        await connection.open();
        await connection
            .query("SELECT f_create_calories_db('$_CALORIES_DB_NAME');");
        await connection.close();

        connection = PostgreSQLConnection("localhost", 5432, _CALORIES_DB_NAME,
            username: _login, password: _password);
        await connection.open();
        caloriesConnection = connection;
      }
      _instance = PsqlConnectionHolder._();
      _instance!.connection = caloriesConnection;
    }
    return _instance!;
  }

  static Future<void> init(String login, String password) async {
    _login = login;
    _password = password;
    try {
      await instance();
      for (var listener in _listeners) {
        listener.onDbConnectionInited();
      }
    } catch (e) {
      _login = null;
      _password = null;
      rethrow;
    }
  }

  static bool inited() {
    return _login != null && _password != null;
  }

  static void addListener(PsqlConnectionHolderListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(PsqlConnectionHolderListener listener) {
    _listeners.remove(listener);
  }
}

abstract class PsqlConnectionHolderListener {
  void onDbConnectionInited();
}
