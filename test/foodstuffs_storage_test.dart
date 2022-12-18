import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await PsqlConnectionHolder.init('postgres', 'qweexrty');
  });

  test('add, get all, update, remove', () async {
    final storage = FoodstuffsStorage.instance();

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

    // Let's update product
    await storage.updateFoodstuff(kase!.id, "Kase", 10, 30, 3);
    // Now the product should be updated
    foodstuffs = await storage.getAllFoodstuffs();
    for (final foodstuff in foodstuffs) {
      if (foodstuff.name == "Kase") {
        kase = foodstuff;
      }
    }
    expect(kase!.protein, equals(10));
    expect(kase.fats, equals(30));
    expect(kase.carbs, equals(3));

    // Let's delete the product
    await storage.deleteFoodstuff(kase.id);

    // The product should be gone from DB
    foodstuffs = await storage.getAllFoodstuffs();
    for (final foodstuff in foodstuffs) {
      expect(foodstuff.name, isNot(equals("Kase")));
    }
  });
}
