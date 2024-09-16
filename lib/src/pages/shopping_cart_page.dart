import 'package:flutter/material.dart';
import '../model/cart_data.dart';
import '../model/activity.dart';
import '../model/product.dart';
import '../model/hobbies.dart';
import '../model/services.dart';
import './order_page.dart';  // Import the new Order Page

class ShoppingCartPage extends StatefulWidget {
  final List<dynamic> cartList;

  ShoppingCartPage({required this.cartList});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  // Remove an item from the cart
  void removeFromCart(dynamic item) {
    setState(() {
      widget.cartList.remove(item);
    });
  }

  // Increase the quantity of the item
  void increaseQuantity(dynamic item) {
    setState(() {
      if (item is Product || item is Activity || item is Service || item is Hobby) {
        item.quantity++;
      }
    });
  }

  // Decrease the quantity of the item
  void decreaseQuantity(dynamic item) {
    setState(() {
      if (item is Product || item is Activity || item is Service || item is Hobby) {
        if (item.quantity > 1) {
          item.quantity--;
        }
      }
    });
  }

  // Calculate total price
  double getTotalPrice() {
    double total = 0;
    widget.cartList.forEach((item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: widget.cartList.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cartList.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartList[index];

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            leading: Image.network(
                              item.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(item.title),
                            subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => decreaseQuantity(item),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => increaseQuantity(item),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => removeFromCart(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${getTotalPrice().toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: widget.cartList.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderPage(
                                    totalAmount: getTotalPrice(), // Trimite suma totală către OrderPage
                                  ),
                                ),
                              );
                            },
                      child: Text('Finalizează comanda'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
