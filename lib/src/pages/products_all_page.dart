import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/cart_data.dart'; // Importă coșul global
import '../model/product.dart'; // Importă modelul de produs
import './shopping_cart_page.dart'; // Importă pagina de coș

class ProductsAllPage extends StatefulWidget {
  @override
  _ProductsAllPageState createState() => _ProductsAllPageState();
}

class _ProductsAllPageState extends State<ProductsAllPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Fetch products from the Fake Store API
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

  // Adaugă produsul în coșul global
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
      cartList.add(product); // Adaugă produsul în coșul global
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} a fost adăugat în coș'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toate produsele'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigare către pagina de coș
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoppingCartPage(cartList: cartList), // Transmite coșul
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: products.isNotEmpty
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 produse per rând
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.55, // Raportul dintre lățime și înălțime
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            product['image'],
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          Text(
                            product['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            '\$${product['price'].toString()}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => addToCart(product), // Adaugă în coș
                            child: Text('Adaugă în coș'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(child: CircularProgressIndicator()), // Afișează indicator de încărcare
      ),
    );
  }
}
