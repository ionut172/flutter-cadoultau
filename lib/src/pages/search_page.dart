import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cadoultau/src/model/services.dart';
import 'shopping_cart_page.dart';
import '../model/cart_data.dart'; // Import the global cart list

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> searchResults = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSearchResults();
  }

  // Fetch products (or search results) from the Fake Store API
  Future<void> fetchSearchResults() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load search results');
    }
  }

  // Add product to cart
  void addToCart(dynamic service) {
    Service product = Service(
      id: service['id'],
      title: service['title'],
      category: service['category'],
      description: service['description'],
      image: service['image'],
      price: (service['price'] as num).toDouble(),
    );

    setState(() {
      cartList.add(product); // Use global cartList
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service['title']} a fost adăugat în coș'),
      ),
    );
  }

  // Function to filter the search results based on the text entered
  void searchProducts(String query) {
    setState(() {
      searchResults = searchResults.where((service) {
        return service['title'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caută Produse'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search here',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchProducts(value);
              },
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final service = searchResults[index];
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
                                service['image'],
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 10),
                              Text(
                                service['title'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '\$${service['price']}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.green),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  addToCart(service);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${service['title']} a fost adăugat în coș'),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShoppingCartPage(cartList: cartList)),
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
