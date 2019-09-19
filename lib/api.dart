import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final prefix = "https://naegele.dev/snowwhite_manager/";

Future<bool> verifyWithUsername(String token, String pin) async {
  if (token == null) return false;
  String url = prefix + "verify_pin.php";
  Map body = {'token': token, 'pin': pin};
  http.Response response = await http.post(url, body: jsonEncode(body));
  if (response.statusCode == 400) {
    return Future.error("error");
  } else if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> verify(String pin) async {
  String token = await FlutterSecureStorage().read(key: 'token');
  return verifyWithUsername(token, pin);
}

Future<Scan> checkTicket(String tid) async {
  String token = await FlutterSecureStorage().read(key: 'token');
  Future<Scan> result = Future.error("error");
  Map body = {'token': token, "tid": tid};
  http.Response response =
      await http.post(prefix + "check_ticket.php", body: jsonEncode(body));

  if (response.statusCode == 404) {
    result = Future.value(Scan(ScanResult.not_found));
  } else if (response.statusCode == 423) {
    result = Future.value(Scan(ScanResult.already_used));
  } else if (response.statusCode == 200) {
    result = Future.value(Scan(ScanResult.allowed));
  }
  return result;
}

Future<String> logIn(String name, String pin) async {
  Future<String> token;
  String url = prefix + "login.php";
  Map body = {'name': name, 'pin': pin};
  http.Response response = await http.post(url, body: jsonEncode(body));
  if (response.statusCode != 200) {
    token = Future.error("error");
  } else {
    token = Future.value(jsonDecode(response.body)["token"]);
  }
  return token;
}

Future<bool> addTicket(
    String name, String pin, String number, int amount) async {
  String token = await FlutterSecureStorage().read(key: 'token');
  String url = prefix + "add_ticket.php";
  Map body = {
    'name': name,
    'pin': pin,
    'token': token,
    'number': number,
    'amount': amount
  };
  http.Response response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 201) {
    return true;
  } else {
    return false;
  }
}

Future<List<Ticket>> listTickets({int limit: 20, int offset: 0}) async {
  String token = await FlutterSecureStorage().read(key: 'token');
  http.Response response = await http.get(
      prefix + "list_tickets.php?token=$token&limit=$limit&offset=$offset");
          List list = jsonDecode(response.body);
  List<Ticket> tickets = list.map((ticket) => Ticket.fromJson(ticket)).toList();

  return tickets;
}

class Scan {
  final ScanResult result;

  Scan(this.result);

  Color get color => resultColors[result];

  String get message => resultMessages[result];

  IconData get icon => resultIcons[result];
}

class Ticket {
  final String name, number;
  final DateTime created;

  Ticket(this.name, this.number, this.created);

  Ticket.fromJson(Map<String, dynamic> map)
      : this(map['buyer'], map['number'],
            DateTime.fromMillisecondsSinceEpoch(int.parse(map['created']) * 1000));
}

enum ScanResult { allowed, already_used, not_found, error }

Map<ScanResult, Color> resultColors = {
  ScanResult.allowed: Colors.green,
  ScanResult.already_used: Colors.red,
  ScanResult.not_found: Colors.red,
  ScanResult.error: Colors.yellow.shade700
};

Map<ScanResult, String> resultMessages = {
  ScanResult.allowed: 'Ticket gültig',
  ScanResult.already_used: 'Ticket bereits benutzt',
  ScanResult.not_found: 'Ticket wurde nicht gefunden',
  ScanResult.error: 'Fehler'
};

Map<ScanResult, IconData> resultIcons = {
  ScanResult.allowed: Icons.check_circle,
  ScanResult.already_used: Icons.close,
  ScanResult.not_found: Icons.close,
  ScanResult.error: Icons.error
};
