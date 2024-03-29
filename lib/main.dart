import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:snowwhite_manager/api.dart';
import 'package:snowwhite_manager/button.dart';
import 'package:snowwhite_manager/screens/add_ticket.dart';
import 'package:snowwhite_manager/screens/home.dart';
import 'package:snowwhite_manager/screens/scan_ticket.dart';
import 'package:snowwhite_manager/screens/verify.dart';

void main() => runApp(SnowwhiteManager());

class SnowwhiteManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snowwhite Manager',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(55, 0, 255, 1),
       // fontFamily: 'Segoe UI',
      ),
      routes: {
        '/': (context) => MainScreen(),
        '/addTicket': (context) => AddTicket(),
        '/scanTicket': (context) => ScanTicket(),
      },
      onGenerateRoute: (settings) {
        String name = settings.name;
        if (name == "/verify")
          return MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => VerifyPin(),
          );
        return null;
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _loggedIn;
  bool _manager = false;
  final key = GlobalKey<FormState>();
  String name, pin, message;

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) return Container();

    if (_loggedIn) {
      return HomeScreen(manager: _manager,);
    } else {
    return Form(
      key: key,
      child: new Scaffold(
        appBar: AppBar(
          title: Text(
            'Einloggen',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (message != null)
                    Text(
                      message,
                      style:
                          TextStyle(color: Colors.red.shade900, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  TextFormField(
                    validator: (val) =>
                        val.isEmpty ? 'Bitte gebe deinen Nachnamen an' : null,
                    onSaved: (val) => name = val,
                    decoration: InputDecoration(labelText: 'Nachname'),
                  ),
                  TextFormField(
                    validator: (val) =>
                        val.isEmpty ? 'Bitte gebe dein Passwort an' : null,
                    onSaved: (val) => pin = val,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Passwort'),
                  ),
                  Center(
                      child: Button.text(
                    text: "Einloggen",
                    onTap: () => onTap(),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    }
  }

  onTap() async {
    final state = key.currentState;
    if (!state.validate()) {
      return;
    }
    state.save();
    setState(() {
      message = null;
    });

    Future<String> token = logIn(name, pin);
    token.then((val) async {
      FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: val);
      checkUser();
    }).catchError((_) {
      setState(() {
        message = "Falscher Benutzer oder falsches Passwort";
      });
    });
  }

  checkUser() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String token = await storage.read(key: 'token');

    if (token != null) {
      VerifyResult res = await verifyToken(token);
      if (res == VerifyResult.not) {
        await storage.delete(key: 'token');
        token = null;
      }
      _manager = res == VerifyResult.manager;
    }
    if (_loggedIn != (token != null))
      setState(() {
        _loggedIn = token != null;
      });
  }
}
