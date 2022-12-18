import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/psql_connection_holder.dart';

class FoodstuffsStorage {
  final _listeners = <FoodstuffsStorageListener>[];

  static FoodstuffsStorage? _instance;

  FoodstuffsStorage._();

  static FoodstuffsStorage instance() {
    _instance ??= FoodstuffsStorage._();
    return _instance!;
  }

  Future<List<Foodstuff>> getAllFoodstuffs() async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    final rows = await connection.query('SELECT * FROM f_get_all_foodstuffs()');

    final result = <Foodstuff>[];
    for (final row in rows) {
      result.add(Foodstuff(
        row[0] as int,
        row[1] as String,
        row[2] as String,
        double.parse(row[3] as String),
        double.parse(row[4] as String),
        double.parse(row[5] as String),
        double.parse(row[6] as String),
      ));
    }
    return result;
  }

  Future<void> addFoodstuff(
      String name, double protein, double fats, double carbs) async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    await connection.query(
        'SELECT f_add_foodstuff(@name:text, @protein:numeric, @fats:numeric, @carbs:numeric)',
        substitutionValues: {
          "name": name,
          "protein": protein,
          "fats": fats,
          "carbs": carbs,
        });

    for (var l in _listeners.toList()) {
      l.onFoodstuffsStorageUpdated();
    }
  }

  Future<void> deleteFoodstuff(int id) async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    await connection
        .query('SELECT f_delete_foodstuff(@id)', substitutionValues: {
      "id": id,
    });

    for (var l in _listeners.toList()) {
      l.onFoodstuffsStorageUpdated();
    }
  }

  Future<void> updateFoodstuff(
      int id, String name, double protein, double fats, double carbs) async {
    final holder = await PsqlConnectionHolder.instance();
    final connection = holder.connection;
    await connection.query(
        'SELECT f_update_foodstuff(@id, @new_name, @new_protein, @new_fats, @new_carbs)',
        substitutionValues: {
          "id": id,
          "new_name": name,
          "new_protein": protein,
          "new_fats": fats,
          "new_carbs": carbs,
        });

    for (var l in _listeners.toList()) {
      l.onFoodstuffsStorageUpdated();
    }
  }

  void addListener(FoodstuffsStorageListener listener) {
    _listeners.add(listener);
  }

  void removeListener(FoodstuffsStorageListener listener) {
    _listeners.remove(listener);
  }
}

abstract class FoodstuffsStorageListener {
  void onFoodstuffsStorageUpdated();
}
