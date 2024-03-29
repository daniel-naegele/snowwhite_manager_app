import 'package:flutter/material.dart';
import 'package:snowwhite_manager/screens/dashboard.dart';
import 'package:snowwhite_manager/screens/scan_ticket.dart';
import 'package:snowwhite_manager/screens/ticket_list.dart';

class HomeScreen extends StatefulWidget {
  final bool manager;

  const HomeScreen({Key key, this.manager}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  Widget body = TicketList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snowwhite Manager', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text("Tickets"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            title: Text("Scannen"),
          ),
          if (widget.manager)
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text("Dashboard"),
            ),
        ],
        currentIndex: _index,
        onTap: onNavigate,
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/addTicket'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : Container(),
      body: body,
    );
  }

  onNavigate(int index) {
    setState(() {
      _index = index;
      if (_index == 0) body = TicketList();
      if (_index == 1) body = ScanTicket();
      if (_index == 2) body = Dashboard();
    });
  }
}
