import 'package:calories_db_project/add_foodstuff_page.dart';
import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter/material.dart';

import 'edit_foodstuff_page.dart';

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
  var _amIAdmin = false;
  var _searchQueryEmpty = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQueryEmpty = _searchController.text.isEmpty;
      });
    });
    _initAsync();
  }

  @override
  void dispose() {
    super.dispose();
    final storage = FoodstuffsStorage.instance();
    storage.removeListener(this);
  }

  void _initAsync() async {
    final holder = await PsqlConnectionHolder.instance();
    final amIAdmin = await holder.amIAdmin();
    setState(() {
      _amIAdmin = amIAdmin;
    });

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
        actions: [
          IconButton(onPressed: _logOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _amIAdmin
              ? TextButton(
                  onPressed: _deleteDatabase, child: Text('Delete database'))
              : const SizedBox.shrink(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 300, child: TextField(controller: _searchController)),
              IconButton(
                  onPressed: () {
                    _searchFoodstuffs();
                  },
                  icon: const Icon(Icons.search)),
              !_searchQueryEmpty
                  ? IconButton(
                      onPressed: () {
                        _deleteFoodstuffsBySubstring();
                      },
                      icon: const Icon(Icons.delete))
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
              onPressed: _deleteAllFoodstuffs,
              child: const Text('Delete all foodstuffs',
                  style: TextStyle(color: Colors.redAccent))),
          ListView(
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
                            _editFoodstuff(e);
                          },
                          icon: const Icon(Icons.edit)),
                      IconButton(
                          onPressed: () {
                            _deleteFoodstuff(e);
                          },
                          icon: const Icon(Icons.delete)),
                    ]))
                .toList(),
          )
        ],
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

  void _editFoodstuff(Foodstuff oldFoodstuff) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditFoodstuffPage(oldFoodstuff: oldFoodstuff)),
    );
  }

  void _deleteFoodstuff(Foodstuff e) async {
    final storage = FoodstuffsStorage.instance();
    await storage.deleteFoodstuff(e.id);
  }

  void _deleteFoodstuffsBySubstring() async {
    final storage = FoodstuffsStorage.instance();
    await storage.deleteFoodstuffsBySubstr(_searchController.text);
    _searchController.clear();
    _reloadFoodstuffs();
    _showMessage('Foodstuffs were deleted!');
  }

  void _deleteAllFoodstuffs() async {
    // create dialog buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () async {
        final storage = FoodstuffsStorage.instance();
        await storage.deleteAllFoodstuffs();
        _showMessage('All foodstuffs were deleted!');
        Navigator.pop(context);
      },
    );

    // create dialog
    AlertDialog alert = AlertDialog(
      title: Text("Deletion"),
      content: Text("Are you sure you want to delete all foodstuffs?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _searchFoodstuffs() async {
    final storage = FoodstuffsStorage.instance();
    final foundFoodstuffs =
        await storage.searchFoodstuffs(_searchController.text);
    setState(() {
      _foodstuffs.clear();
      _foodstuffs.addAll(foundFoodstuffs);
    });
  }

  void _deleteDatabase() async {
    await PsqlConnectionHolder.deleteDatabase();
  }

  void _logOut() async {
    await PsqlConnectionHolder.logOut();
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
