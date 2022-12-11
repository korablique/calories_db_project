import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PsqlConnectionHolder.init('postgres', 'qweexrty');
  });

  test('add, get all, remove', () async {
    final storage = await FoodstuffsStorage.instance();

    // Initially the product is not in the DB
    var foodstuffs = await storage.getAllFoodstuffs();
    for (final foodstuff in foodstuffs) {
      expect(foodstuff.name, isNot(equals("Kase")));
    }

    // Let's add the product
    await storage.addFoodstuff("Kase", 30, 20, 10);

    // Now the product should be in DB
    foodstuffs = await storage.getAllFoodstuffs();
    Foodstuff? kase;
    for (final foodstuff in foodstuffs) {
      if (foodstuff.name == "Kase") {
        kase = foodstuff;
      }
    }
    expect(kase, isNot(equals(null)));

    // Let's delete the product
    storage.deleteFoodstuff(kase!.id);

    // The product should be gone from DB
    foodstuffs = await storage.getAllFoodstuffs();
    for (final foodstuff in foodstuffs) {
      expect(foodstuff.name, isNot(equals("Kase")));
    }
  });
}
