import 'package:flutter/material.dart';
import 'package:cadoultau/src/pages/gift_page.dart';
import 'package:cadoultau/src/pages/login_page.dart';
import 'package:cadoultau/src/pages/shopping_cart_page.dart';
import 'package:cadoultau/src/pages/relationship_page.dart';
import 'package:cadoultau/src/pages/my_orders_page.dart';
import 'package:cadoultau/src/themes/light_color.dart';
import 'package:cadoultau/src/model/cart_data.dart';
import 'package:cadoultau/src/themes/theme.dart';
import 'package:cadoultau/src/widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cadoultau/src/widgets/event_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final String title;

  MainPage({Key? key, this.title = 'Cadoul Tau'}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isHomePageSelected = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? currentUser = FirebaseAuth.instance.currentUser;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _navigateToHome() {
    setState(() {
      isHomePageSelected = true;
    });
    Navigator.pop(context);
  }

  void onBottomIconPressed(int index) {
    setState(() {
      isHomePageSelected = index == 0;
    });
  }

  Future<void> _logout() async {
  // Șterge UID-ul din SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userUid');
  
  // Deconectează utilizatorul din Firebase Auth
  await FirebaseAuth.instance.signOut();

  // Redirecționează către pagina de login
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}


  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black54),
            onPressed: _openDrawer,
            iconSize: 30,
          ),
          ClipOval(
            child: Image.asset(
              "assets/user.png",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          IconButton(
            icon: Icon(Icons.people, color: Colors.black54),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(cartList: cartList)));
            },
            iconSize: 30,
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Evenimentele Următoare',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Divider(color: Colors.black26, thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_scaffoldKey.currentState!.isDrawerOpen) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  height: AppTheme.fullHeight(context) - 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xfffbfbfb), Color(0xfff7f7f7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _appBar(),
                      _title(),
                      SizedBox(height: 10),
                      EventList(), // Componenta pentru lista de evenimente
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: CustomBottomNavigationBar(
                  onIconPressedCallback: onBottomIconPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [LightColor.lightBlue, LightColor.darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: LightColor.lightBlue),
              ),
              SizedBox(height: 10),
              Text(
                'Bine ai venit!',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                currentUser?.email ?? 'Utilizator',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.home, color: LightColor.lightBlue),
          title: Text('Home'),
          onTap: _navigateToHome,
        ),
        if (currentUser != null) // Arătăm aceste opțiuni doar dacă utilizatorul este autentificat
          ListTile(
            leading: Icon(Icons.shop, color: LightColor.lightBlue),
            title: Text('Comenzile Mele'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrdersPage()),
              );
            },
          ),
        if (currentUser != null)
          ListTile(
            leading: Icon(Icons.people, color: LightColor.lightBlue),
            title: Text('Relațiile mele'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RelationshipPage()),
              );
            },
          ),
        Divider(),
        if (currentUser != null)
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: _logout,
          ),
        if (currentUser == null) // Dacă nu este autentificat, arătăm butonul de login
          ListTile(
            leading: Icon(Icons.login, color: LightColor.lightBlue),
            title: Text('Login'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
      ],
    ),
  );
}
}