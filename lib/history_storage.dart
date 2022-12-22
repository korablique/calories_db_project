import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/history_entry.dart';
import 'package:calories_db_project/psql_connection_holder.dart';

class HistoryStorage {
  final _listeners = <HistoryStorageListener>[];

  static HistoryStorage? _instance;

  HistoryStorage._();

  static HistoryStorage instance() {
    _instance ??= HistoryStorage._();
    return _instance!;
  }

  Future<List<HistoryEntry>> getMyHistory() async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    final rows = await connection.query('SELECT * FROM f_get_my_history()');

    final result = <HistoryEntry>[];
    for (final row in rows) {
      result.add(HistoryEntry(
        row[0] as int,
        row[1] as int,
        row[2] as DateTime,
        row[3] as int,
        row[4] as int,
      ));
    }
    return result;
  }

  Future<void> addHistoryEntry(
      int foodstuffId, int foodstuffWeight) async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    await connection.query(
        'SELECT f_add_history_entry(@foodstuffId, @weight)',
        substitutionValues: {
          "foodstuffId": foodstuffId,
          "weight": foodstuffWeight,
        });

    for (var l in _listeners.toList()) {
      l.onHistoryStorageUpdated();
    }
  }

  Future<void> deleteHistoryEntry(int id) async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    await connection
        .query('SELECT f_delete_history_entry(@id)', substitutionValues: {
      "id": id,
    });

    for (var l in _listeners.toList()) {
      l.onHistoryStorageUpdated();
    }
  }

  Future<void> deleteMyHistory() async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    await connection.query('SELECT f_delete_all_history()');

    for (var l in _listeners.toList()) {
      l.onHistoryStorageUpdated();
    }
  }

  void addListener(HistoryStorageListener listener) {
    _listeners.add(listener);
  }

  void removeListener(HistoryStorageListener listener) {
    _listeners.remove(listener);
  }
}

abstract class HistoryStorageListener {
  void onHistoryStorageUpdated();
}
