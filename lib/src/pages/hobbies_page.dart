import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cadoultau/src/model/hobbies.dart';
import 'shopping_cart_page.dart';
import '../model/cart_data.dart'; // Import the global cart list

class HobbiesPage extends StatefulWidget {
  @override
  _HobbiesPageState createState() => _HobbiesPageState();
}

class _HobbiesPageState extends State<HobbiesPage> {
  List<dynamic> hobbies = [];

  @override
  void initState() {
    super.initState();
    fetchHobbies();
  }

  Future<void> fetchHobbies() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        hobbies = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load hobbies');
    }
  }

  void addToCart(dynamic hobby) {
    Hobby product = Hobby(
      id: hobby['id'],
      title: hobby['title'],
      category: hobby['category'],
      description: hobby['description'],
      image: hobby['image'],
      price: (hobby['price'] as num).toDouble(),
    );

    setState(() {
      cartList.add(product); // Use global cartList from cart_data.dart
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hobby-uri'),
      ),
      body: hobbies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: hobbies.length,
              itemBuilder: (context, index) {
                final hobby = hobbies[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          hobby['image'],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 10),
                        Text(
                          hobby['title'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${hobby['price']}',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            addToCart(hobby);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${hobby['title']} a fost adăugat în coș'),
                              ),
                            );
                          },
                          child: Text('Adaugă în coș'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShoppingCartPage(cartList: cartList)), // Use global cartList
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
