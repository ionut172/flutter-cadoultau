import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cadoultau/src/model/product.dart';
import 'shopping_cart_page.dart'; // Import the Shopping Cart page
import '../model/cart_data.dart'; // Import the global cart list

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void addToCart(dynamic productData) {
    Product product = Product(
      id: productData['id'],
      title: productData['title'],
      category: productData['category'],
      description: productData['description'],
      image: productData['image'],
      price: (productData['price'] as num).toDouble(),
    );

    setState(() {
      cartList.add(product); // Use the global cartList
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produse'),
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
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
                          product['image'],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 10),
                        Text(
                          product['title'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${product['price']}',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product['title']} a fost adăugat în coș'),
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
            MaterialPageRoute(builder: (context) => ShoppingCartPage(cartList: cartList)), // Navigate to Shopping Cart
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
