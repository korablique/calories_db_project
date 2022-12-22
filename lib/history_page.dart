import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:calories_db_project/history_entry.dart';
import 'package:calories_db_project/history_storage.dart';
import 'package:calories_db_project/select_foodstuff_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> implements HistoryStorageListener, FoodstuffsStorageListener {
  final _historyEntries = <HistoryEntry>[];
  final _foodstuffsMap = <int, Foodstuff>{};
  final _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    HistoryStorage.instance().addListener(this);
    FoodstuffsStorage.instance().addListener(this);
    _reloadHistory();
  }

  void _reloadHistory() async {
    final dbHistory = await HistoryStorage.instance().getMyHistory();
    final dbFoodstuffs = await FoodstuffsStorage.instance().getAllFoodstuffs();
    final dbFoodstuffsMap = { for (var foodstuff in dbFoodstuffs) foodstuff.id: foodstuff };
    setState(() {
      _historyEntries.clear();
      _historyEntries.addAll(dbHistory);
      _foodstuffsMap.clear();
      _foodstuffsMap.addAll(dbFoodstuffsMap);
    });
  }

  @override
  void dispose() {
    HistoryStorage.instance().removeListener(this);
    FoodstuffsStorage.instance().removeListener(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              ListView(
                shrinkWrap: true,
                children: _historyEntries
                    .map((e) =>
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Name: ${_foodstuffsMap[e.foodstuffId]!.name}, '),
                      Text('weight: ${e.foodstuffWeight}, '),
                      Text('date: ${_dateFormatter.format(e.date)}'),
                      IconButton(
                          onPressed: () {
                            _deleteHistoryEntry(e);
                          },
                          icon: const Icon(Icons.delete)),
                    ]))
                    .toList(),
              )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHistoryEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void onHistoryStorageUpdated() {
    _reloadHistory();
  }

  @override
  void onFoodstuffsStorageUpdated() {
    _reloadHistory();
  }

  void _deleteHistoryEntry(HistoryEntry e) async {
    await HistoryStorage.instance().deleteHistoryEntry(e.id);
  }

  void _addHistoryEntry() async {
    final foodstuff = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectFoodstuffPage()),
    );

    if (foodstuff is! Foodstuff) {
      return;
    }

    final weightController = TextEditingController();
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget okButton = TextButton(
      child: Text("Ok"),
      onPressed: () async {
        try {
          final weight = int.parse(weightController.text);
          Navigator.pop(context, weight);
        } catch (e) {
          _showMessage(e.toString());
        }
      },
    );

    // create dialog
    AlertDialog alert = AlertDialog(
      title: Text("Weight"),
      content: TextField(controller: weightController),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    final weight = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    if (weight is! int) {
      return;
    }

    HistoryStorage.instance().addHistoryEntry(foodstuff.id, weight);
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
