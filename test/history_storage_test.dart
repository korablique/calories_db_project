import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:calories_db_project/history_storage.dart';
import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await PsqlConnectionHolder.init('petya', 'pass');
    final historyStorage = HistoryStorage.instance();
    await historyStorage.deleteMyHistory();
    await PsqlConnectionHolder.logOut();

    await PsqlConnectionHolder.init('postgres', 'qweexrty');
    final storage = FoodstuffsStorage.instance();
    await storage.deleteAllFoodstuffs();
  });

  test('add, get all, remove', () async {
    // The postgres user cannot add history entries, so we're Petya now
    await PsqlConnectionHolder.logOut();
    await PsqlConnectionHolder.init('petya', 'pass');

    final historyStorage = HistoryStorage.instance();
    final initialHistory = await historyStorage.getMyHistory();

    final foodstuffsStorage = FoodstuffsStorage.instance();
    await foodstuffsStorage.addFoodstuff("Banana", 2, 4, 1);
    await foodstuffsStorage.addFoodstuff("Apple", 3, 4, 1);
    final foodstuffs = await foodstuffsStorage.getAllFoodstuffs();

    // Initially, the history should be empty
    expect(initialHistory, isEmpty);

    // Add the entries into the history
    historyStorage.addHistoryEntry(foodstuffs[0].id, 123);
    historyStorage.addHistoryEntry(foodstuffs[1].id, 321);

    // Check the entries were added
    final finalHistory = await historyStorage.getMyHistory();
    expect(finalHistory.length, equals(2));
    expect(finalHistory[0].foodstuffWeight, equals(123));
    expect(finalHistory[0].foodstuffId, equals(foodstuffs[0].id));
    expect(finalHistory[1].foodstuffWeight, equals(321));
    expect(finalHistory[1].foodstuffId, equals(foodstuffs[1].id));
  });
}
