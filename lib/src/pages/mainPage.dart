import 'package:flutter/material.dart';
import 'package:cadoultau/src/pages/gift_page.dart';
import 'package:cadoultau/src/pages/login_page.dart';
import 'package:cadoultau/src/themes/light_color.dart';
import 'package:cadoultau/src/themes/theme.dart';
import 'package:cadoultau/src/widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:cadoultau/src/widgets/title_text.dart';
import 'package:cadoultau/src/widgets/extentions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MainPage extends StatefulWidget {
  final String title;

  MainPage({Key? key, this.title = 'Cadoul Tau'}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isHomePageSelected = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Obține UID-ul utilizatorului logat
  User? currentUser = FirebaseAuth.instance.currentUser;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _navigateToHome() {
    setState(() {
      isHomePageSelected = true;
    });
    Navigator.pop(context);
  }

  void _navigateToShop() {
    setState(() {
      isHomePageSelected = false;
    });
    Navigator.pop(context);
  }

  void onBottomIconPressed(int index) {
    setState(() {
      isHomePageSelected = index == 0;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
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
            child: _icon(Icons.sort, color: Colors.black54, onPressed: _openDrawer),
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
              TitleText(text: 'Evenimentele', fontSize: 27, fontWeight: FontWeight.w400),
              TitleText(text: 'Următoare', fontSize: 27, fontWeight: FontWeight.w700),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  // Funcția pentru preluarea datelor despre persoanele favorite din Firestore
  Widget _eventList() {
    if (currentUser == null) {
      return Center(child: Text('Nu sunteți autentificat.'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Eroare la încărcarea datelor'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Nu există date disponibile'));
        }

        // Extragem datele utilizatorului
        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> favoritePeople = userData['favorite_people'] ?? [];

        if (favoritePeople.isEmpty) {
          return Center(child: Text('Nu există persoane favorite'));
        }

        // Afișăm lista persoanelor favorite sub formă de slider
        return CarouselSlider(
          options: CarouselOptions(
            height: 250.0,  // Poți ajusta înălțimea cardului dacă e nevoie
            enlargeCenterPage: true,
            viewportFraction: 0.6,  // Afișează 25% din următorul card
            autoPlay: false,
            enableInfiniteScroll: false,
          ),
          items: favoritePeople.map((person) {
            if (person.containsKey('basic_info')) {
              Map<String, dynamic> personData = person['basic_info'] ?? {};
              return _eventCard(personData);
            }
            return Container();
          }).toList(),
        );
      },
    );
  }

  // Widget pentru a afișa cardul cu datele unei persoane
  Widget _eventCard(Map<String, dynamic> personData) {
  String firstName = personData['firstName'] ?? 'N/A';
  String lastName = personData['lastName'] ?? 'N/A';
  String relation = personData['relation'] ?? 'Relație necunoscută';
  String birthdateString = personData['birthdate'] ?? '';

  if (birthdateString.isEmpty) {
    return Container();
  }

  DateTime birthdate = DateTime.parse(birthdateString);
  int daysUntilBirthday = daysUntilNextBirthday(birthdate);

  return Card(
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),  // Ajustează margin pentru a lărgi cardul
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  // Centrează pe verticală
        crossAxisAlignment: CrossAxisAlignment.center, // Centrează pe orizontală
        children: [
          Text('$firstName $lastName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('$relation', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('Aniversare in: $daysUntilBirthday zile', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GiftPage()));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,  // Setează butonul la alb
              backgroundColor: LightColor.lightBlue  // Textul va fi negru
            ),
            child: Text('Trimite un cadou'),
          ),
        ],
      ),
    ),
  );
}


  // Funcție pentru a calcula numărul de zile până la următoarea aniversare
  int daysUntilNextBirthday(DateTime birthdate) {
    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthdate.month, birthdate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthdate.month, birthdate.day);
    }

    return nextBirthday.difference(now).inDays;
  }

  // Funcția pentru meniul personalizat
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
          ListTile(
            leading: Icon(Icons.shopping_cart, color: LightColor.lightBlue),
            title: Text('Shop'),
            onTap: _navigateToShop,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: _logout,
          ),
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
        drawer: _buildDrawer(),  // Meniul personalizat
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
                      _eventList(),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
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
}
