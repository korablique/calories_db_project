import 'package:calories_db_project/foodstuff.dart';
import 'package:calories_db_project/foodstuffs_storage.dart';
import 'package:flutter/material.dart';

class EditFoodstuffPage extends StatefulWidget {
  final Foodstuff oldFoodstuff;
  const EditFoodstuffPage({super.key, required this.oldFoodstuff});

  @override
  State<EditFoodstuffPage> createState() => _EditFoodstuffPageState();
}

class _EditFoodstuffPageState extends State<EditFoodstuffPage> {
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.oldFoodstuff.name;
    _proteinController.text = widget.oldFoodstuff.protein.toString();
    _fatsController.text = widget.oldFoodstuff.fats.toString();
    _carbsController.text = widget.oldFoodstuff.carbs.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit foodstuff'),
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

    await FoodstuffsStorage.instance()
        .updateFoodstuff(widget.oldFoodstuff.id, name, protein, fats, carbs);
    Navigator.pop(context);
  }
}
