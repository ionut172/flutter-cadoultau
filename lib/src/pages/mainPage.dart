import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cadoultau/src/pages/home_page.dart';
import 'package:cadoultau/src/pages/shopping_cart_page.dart';
import 'package:cadoultau/src/pages/login_page.dart';
import 'package:cadoultau/src/themes/light_color.dart';
import 'package:cadoultau/src/themes/theme.dart';
import 'package:cadoultau/src/widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:cadoultau/src/widgets/title_text.dart';
import 'package:cadoultau/src/widgets/extentions.dart';

class MainPage extends StatefulWidget {
  final String title;

  MainPage({Key? key, this.title = 'Cadoul Tau'}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isHomePageSelected = true;

  // Create a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Deloghează utilizatorul din Firebase
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirecționează către pagina de login
    );
  }

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotatedBox(
            quarterTurns: 4,
            child: _icon(
              Icons.sort,
              color: Colors.black54,
              onPressed: _openDrawer, // Call the drawer opening method
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0xfff8f8f8),
                    blurRadius: 10,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Image.asset("assets/user.png"),
            ),
          ).ripple(() {}, borderRadius: BorderRadius.all(Radius.circular(13))),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, {Color color = LightColor.iconColor, required VoidCallback onPressed}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
        color: Theme.of(context).colorScheme.background,
        boxShadow: AppTheme.shadow,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _title() {
    return Container(
      margin: AppTheme.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TitleText(
                text: isHomePageSelected ? 'Our' : 'Shopping',
                fontSize: 27,
                fontWeight: FontWeight.w400,
              ),
              TitleText(
                text: isHomePageSelected ? 'Products' : 'Cart',
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          Spacer(),
          !isHomePageSelected
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.delete_outline,
                    color: LightColor.orange,
                  ),
                ).ripple(() {}, borderRadius: BorderRadius.all(Radius.circular(13)))
              : SizedBox(),
        ],
      ),
    );
  }

  void onBottomIconPressed(int index) {
    if (index == 0 || index == 1) {
      setState(() {
        isHomePageSelected = true;
      });
    } else {
      setState(() {
        isHomePageSelected = false;
      });
    }
  }

  void _navigateToHome() {
    setState(() {
      isHomePageSelected = true;
    });
    Navigator.pop(context); // Close the drawer
  }

  void _navigateToShop() {
    setState(() {
      isHomePageSelected = false;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_scaffoldKey.currentState!.isDrawerOpen) {
          Navigator.pop(context); // Close the drawer if tapped outside
        }
      },
      child: Scaffold(
        key: _scaffoldKey, // Attach the GlobalKey to the Scaffold
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: LightColor.lightBlue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: _navigateToHome,
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Shop'),
                onTap: _navigateToShop,
              ),
              Divider(), // Divider între opțiuni și butonul de delogare
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: _logout, // Deloghează și redirecționează
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  height: AppTheme.fullHeight(context) - 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xfffbfbfb),
                        Color(0xfff7f7f7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _appBar(),
                      _title(),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInToLinear,
                          switchOutCurve: Curves.easeOutBack,
                          child: isHomePageSelected
                              ? MyHomePage()
                              : Align(
                                  alignment: Alignment.topCenter,
                                  child: ShoppingCartPage(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CustomBottomNavigationBar(
                  onIconPressedCallback: onBottomIconPressed, // Asigură-te că callback-ul corect este folosit
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
