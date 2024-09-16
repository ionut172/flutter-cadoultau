import 'package:flutter/material.dart';
import 'package:cadoultau/src/themes/light_color.dart';
import 'package:cadoultau/src/widgets/BottomNavigationBar/bottom_curved_Painter.dart';
import 'package:cadoultau/src/pages/search_page.dart';
import 'package:cadoultau/src/pages/relationship_page.dart';
import 'package:cadoultau/src/pages/products_all_page.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onIconPressedCallback; // Ensure the parameter name is correct

  CustomBottomNavigationBar({Key? key, required this.onIconPressedCallback}) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}


class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _xController;
  late AnimationController _yController;

  @override
  void initState() {
    super.initState();

    _xController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
      animationBehavior: AnimationBehavior.preserve,
    );

    _yController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      animationBehavior: AnimationBehavior.preserve,
    );

    Listenable.merge([_xController, _yController]).addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _xController.value =
        _indexToPosition(_selectedIndex) / MediaQuery.of(context).size.width;
    _yController.value = 1.0;
  }

  double _indexToPosition(int index) {
    const buttonCount = 4.0;
    final appWidth = MediaQuery.of(context).size.width;
    final buttonsWidth = _getButtonContainerWidth();
    final startX = (appWidth - buttonsWidth) / 2;
    return startX +
        index.toDouble() * buttonsWidth / buttonCount +
        buttonsWidth / (buttonCount * 2.0);
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  Widget _icon(IconData icon, bool isEnabled, int index) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        onTap: () {
          _handlePressed(index);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          alignment: isEnabled ? Alignment.topCenter : Alignment.center,
          child: AnimatedContainer(
            height: isEnabled ? 40 : 20,
            duration: Duration(milliseconds: 300),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isEnabled ? LightColor.orange : Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: isEnabled ? Color(0xfffeece2) : Colors.white,
                  blurRadius: 10,
                  spreadRadius: 5,
                  offset: Offset(5, 5),
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Opacity(
              opacity: isEnabled ? _yController.value : 1,
              child: Icon(
                icon,
                color: isEnabled
                    ? LightColor.background
                    : Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final inCurve = ElasticOutCurve(0.38);
    return CustomPaint(
      painter: BackgroundCurvePainter(
        _xController.value * MediaQuery.of(context).size.width,
        Tween<double>(
          begin: Curves.easeInExpo.transform(_yController.value),
          end: inCurve.transform(_yController.value),
        ).transform(_yController.velocity.sign * 0.5 + 0.5),
        Theme.of(context).colorScheme.background,
      ),
    );
  }

  double _getButtonContainerWidth() {
    double width = MediaQuery.of(context).size.width;
    if (width > 400.0) {
      width = 400.0;
    }
    return width;
  }

  void _handlePressed(int index) {
  if (_selectedIndex == index || _xController.isAnimating) return;

  setState(() {
    _selectedIndex = index;
  });

  if (index == 0) {
    widget.onIconPressedCallback(index);
  } else if (index == 1) {
    // Navighează la pagina de căutare
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    ).then((value) {
      // La întoarcere, selectează butonul Home
      setState(() {
        _selectedIndex = 0;
      });
      widget.onIconPressedCallback(0); // Actualizează Home
    });
  } else if (index == 2) {
    // Navighează la pagina de produse
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RelationshipPage()),
    ).then((value) {
      // La întoarcere, selectează butonul Home
      setState(() {
        _selectedIndex = 0;
      });
      widget.onIconPressedCallback(0); // Actualizează Home
    });
  }

  // Animatie pentru selectie
  _yController.value = 1.0;
  _xController.animateTo(
      _indexToPosition(index) / MediaQuery.of(context).size.width);
  Future.delayed(
    Duration(milliseconds: 500),
    () {
      _yController.animateTo(1.0, duration: Duration(milliseconds: 1200));
    },
  );
  _yController.animateTo(0.0, duration: Duration(milliseconds: 300));
}


  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;
    final height = 60.0;
    return Container(
      width: appSize.width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            width: appSize.width,
            height: height - 10,
            child: _buildBackground(),
          ),
          Positioned(
            left: (appSize.width - _getButtonContainerWidth()) / 2,
            top: 0,
            width: _getButtonContainerWidth(),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _icon(Icons.home, _selectedIndex == 0, 0),
                _icon(Icons.search, _selectedIndex == 1, 1),
                _icon(Icons.people, _selectedIndex == 2, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
