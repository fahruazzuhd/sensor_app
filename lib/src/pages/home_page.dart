import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensor_app/src/pages/page_a.dart';
import 'package:sensor_app/src/pages/page_b.dart';
import 'package:sensor_app/src/pages/page_c.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);
  final List<Widget> _children = [
    PageA(),
    PageB(),
    PageC(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _children[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.hardware),
            label: 'Page A'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.phone_android),
              label: 'Page B'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.graphic_eq),
              label: 'Page C',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
