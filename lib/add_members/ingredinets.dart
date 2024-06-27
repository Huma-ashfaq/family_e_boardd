import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientsPage extends StatefulWidget {
  @override
  _IngredientsPageState createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<Map<String, dynamic>> _ingredients = [];

  void _addIngredient() {
    final String ingredient = _ingredientController.text;
    final String price = _priceController.text;

    if (ingredient.isNotEmpty && price.isNotEmpty && double.tryParse(price) != null) {
      setState(() {
        _ingredients.add({'ingredient': ingredient, 'price': double.parse(price)});
      });

      _ingredientController.clear();
      _priceController.clear();
    }
  }

  Future<void> _showTotalPrice() async {
    double totalPrice = 0;
    _ingredients.forEach((item) {
      totalPrice += item['price'];
    });

    double foodExpense = 0;
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expense')
          .where('category', isEqualTo: 'food')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        foodExpense = querySnapshot.docs.fold(0, (previousValue, doc) => previousValue + doc['amount']);
        print('Food expense from Firestore: Rs $foodExpense'); // Debugging print
      }
    } catch (e) {
      print('Error fetching food expense: $e'); // Debugging print
    }

    print('Total price of ingredients: Rs $totalPrice'); // Debugging print

    String message;
    if (totalPrice <= foodExpense) {
      message = 'Total price (Rs ${totalPrice.toStringAsFixed(2)}) is within your budget (Rs ${foodExpense.toStringAsFixed(2)}).';
    } else {
      message = 'Total price (Rs ${totalPrice.toStringAsFixed(2)}) exceeds your budget (Rs ${foodExpense.toStringAsFixed(2)}).';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Budget Check'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/watercolor bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Ingredients List'),
          backgroundColor: Colors.black26, // Semi-transparent background color
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _ingredientController,
                decoration: InputDecoration(
                  labelText: 'Ingredient',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addIngredient,
                child: Text('Add Ingredient'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = _ingredients[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(ingredient['ingredient']),
                        trailing: Text('Rs ${ingredient['price'].toStringAsFixed(2)}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showTotalPrice,
          child: Icon(Icons.calculate),
          backgroundColor: Colors.teal,
        ),
      ),
    );
  }
}
