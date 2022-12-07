import 'package:calories_db_project/add_foodstuff_page.dart';
import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    implements FoodstuffsStorageListener {
  final _foodstuffs = <Foodstuff>[];

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void dispose() {
    super.dispose();
    final storage = FoodstuffsStorage.instance();
    storage.removeListener(this);
  }

  void _initAsync() async {
    _reloadFoodstuffs();
    final storage = FoodstuffsStorage.instance();
    storage.addListener(this);
  }

  void _reloadFoodstuffs() async {
    final storage = FoodstuffsStorage.instance();
    final dbFoodstuffs = await storage.getAllFoodstuffs();
    setState(() {
      _foodstuffs.clear();
      _foodstuffs.addAll(dbFoodstuffs);
    });
  }

  @override
  void onFoodstuffsStorageUpdated() {
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView(
        shrinkWrap: true,
        children: _foodstuffs
            .map((e) =>
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Name: ${e.name}, '),
                  Text('protein: ${e.protein}, '),
                  Text('fats: ${e.fats}, '),
                  Text('carbs: ${e.carbs}, '),
                  Text('calories: ${e.calories}'),
                  IconButton(
                      onPressed: () {
                        _deleteFoodstuff(e);
                      },
                      icon: const Icon(Icons.delete))
                ]))
            .toList(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFoodstuff,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addFoodstuff() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodstuffPage()),
    );
  }

  void _deleteFoodstuff(Foodstuff e) async {
    final storage = FoodstuffsStorage.instance();
    await storage.deleteFoodstuff(e.id);
  }
}
