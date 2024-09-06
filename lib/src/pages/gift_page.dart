import 'package:flutter/material.dart';
import 'hobbies_page.dart'; // Import the required pages
import 'activities_page.dart';
import 'products_page.dart'; // This could be your products API page
import 'services_page.dart'; // This could be your products API page
class GiftPage extends StatefulWidget {
  @override
  _GiftPageState createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadouri'),
      ),
      body: GridView.count(
        crossAxisCount: 2,  // Number of cards in a row
        padding: EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildCategoryCard(context, 'Hobbies', Icons.sports, Colors.blue, HobbiesPage()),
          _buildCategoryCard(context, 'Activități', Icons.run_circle, Colors.green, ActivitiesPage()),
          _buildCategoryCard(context, 'Produse', Icons.shopping_bag, Colors.purple, ProductsPage()),
          _buildCategoryCard(context, 'Servicii', Icons.shopping_bag, Colors.red, ServicesPage()),
          // Add more cards for other categories if needed
        ],
      ),
    );
  }

  // Helper method to build the card
  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),  // Navigate to the respective page
        );
      },
      child: Card(
        color: color,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50.0, color: Colors.white),
              SizedBox(height: 16.0),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
