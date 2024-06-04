import 'dart:convert';

import 'package:stash_app/config.dart';
import 'package:stash_app/store.dart';
import 'package:http/http.dart' as http;

Future<void> authRegister(
    String username, String email, String password) async {
  var response = await http.post(
      Uri.parse('${config['backend_url']}/api/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
          {"username": username, "email": email, "password": password}));

  if (response.statusCode != 201) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}

Future<User> authLogin(String email, String password) async {
  var response = await http.post(
      Uri.parse('${config['backend_url']}/api/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}));

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }

  var body = jsonDecode(utf8.decode(response.bodyBytes));

  var token = body['token'];
  var id = int.parse(body['id']);
  var username = body['username'];

  var user = User(id, username, email, token);

  return user;
}
