import 'package:flutter/material.dart';
import 'package:cadoultau/src/pages/mainPage.dart';
import 'package:cadoultau/src/pages/login_page.dart';
import 'package:cadoultau/src/pages/register_page.dart';
import 'package:cadoultau/src/pages/add_person_page.dart';
import 'package:cadoultau/src/pages/product_detail.dart';
import 'package:cadoultau/src/pages/home_page.dart';
import 'package:cadoultau/src/pages/relationship_page.dart';


class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      'MainPage': (context) => MainPage(),
      'LoginPage': (context) => LoginPage(),
      'RegisterPage': (context) => RegisterPage(),
      'AddPersonPage': (context) => AddPersonPage(),
      '/detail': (context) => ProductDetailPage(),
      'HomePage': (context) => MyHomePage(),
       '/relationship': (context) => RelationshipPage(),
};

  }
}
