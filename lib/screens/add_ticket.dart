import 'package:flutter/material.dart';
import 'package:snowwhite_manager/api.dart' as prefix0;
import 'package:snowwhite_manager/button.dart';

class AddTicket extends StatefulWidget {
  @override
  _AddTicketState createState() => _AddTicketState();
}

class _AddTicketState extends State<AddTicket> {
  final key = GlobalKey<FormState>();
  String name, number;
  int amount;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Scaffold(
        appBar: AppBar(
          title:
              Text('Ticket hinzufügen', style: TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 16),
              TextFormField(
                onSaved: (val) => name = val.trim(),
                validator: (val) =>
                    val.isEmpty ? 'Bitte gebe einen Namen an' : null,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                onSaved: (val) => amount = int.parse(val.trim()),
                validator: (val) => int.tryParse(val.trim()) == null
                    ? 'Bitte gebe eine gültige Zahl an'
                    : null,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Anzahl"),
              ),
              TextFormField(
                onSaved: (val) => number = val,
                validator: (val) =>
                    val.isEmpty ? 'Bitte gebe eine Telefonnummer an' : null,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Telefonnummer"),
              ),
              SizedBox(height: 32),
              Center(
                child: Button.text(
                  onTap: () => addTicket(),
                  text: "Ticket hinzufügen",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addTicket() async {
    FormState state = key.currentState;
    if (!state.validate()) return;
    state.save();

    var res = await Navigator.pushNamed(context, '/verify');
    Map result = res;
    if (result.containsKey('pin')) {
      await prefix0.addTicket(name, result['pin'], number, amount);
      Navigator.pop(context);
    }
  }
}