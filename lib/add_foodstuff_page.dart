import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:flutter/material.dart';

class AddFoodstuffPage extends StatefulWidget {
  const AddFoodstuffPage({super.key});

  @override
  State<AddFoodstuffPage> createState() => _AddFoodstuffPageState();
}

class _AddFoodstuffPageState extends State<AddFoodstuffPage> {
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new foodstuff'),
      ),
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Name: '),
                  SizedBox(
                      width: 300,
                      child: TextField(controller: _nameController)),
                ]),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Protein: '),
                  SizedBox(
                      width: 300,
                      child: TextField(controller: _proteinController)),
                ]),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Fats: '),
                  SizedBox(
                      width: 300,
                      child: TextField(controller: _fatsController)),
                ]),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Carbs: '),
                  SizedBox(
                      width: 300,
                      child: TextField(controller: _carbsController)),
                ]),
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveProduct,
        child: const Icon(Icons.check),
      ),
    );
  }

  void _saveProduct() async {
    String name;
    double protein;
    double fats;
    double carbs;
    try {
      name = _nameController.text;
      if (name.length < 3) {
        throw ArgumentError('Name is too short');
      }
      protein = double.parse(_proteinController.text);
      fats = double.parse(_fatsController.text);
      carbs = double.parse(_carbsController.text);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error in input data! Error: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    await FoodstuffsStorage.instance().addFoodstuff(name, protein, fats, carbs);
    Navigator.pop(context);
  }
}
