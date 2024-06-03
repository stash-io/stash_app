import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:stash_app/config.dart';

class Collection {
  String title;
  String description;
  bool published;
  int userId;
  int id;

  Collection(
      this.title, this.description, this.published, this.userId, this.id);

  Collection.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        published = json['published'] as bool,
        userId = json['userId'] as int,
        id = json['id'] as int;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'published': published,
        'userId': userId,
        'id': id
      };
}

Future<void> collectionsCreate(
    String token, String title, String description, bool published) async {
  var response = await http.post(
      Uri.parse('${config['backend_url']}/api/collections/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "title": title,
        "description": description,
        "published": published
      }));

  if (response.statusCode != 201) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}

class CollectionListResponse {
  List<Collection> collections;

  CollectionListResponse(this.collections);

  CollectionListResponse.fromJson(Map<String, dynamic> json)
      : collections = (json['collections'] as List<dynamic>)
            .map((e) => Collection.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {
        'collections': collections.map((e) => e.toJson()).toList(),
      };
}

Future<List<Collection>> collectionsList(String token) async {
  var response = await http.get(
    Uri.parse('${config['backend_url']}/api/collections/list'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }

  final body = CollectionListResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)));

  return body.collections;
}

class CollectionFindResponse {
  Collection collection;

  CollectionFindResponse(this.collection);

  CollectionFindResponse.fromJson(Map<String, dynamic> json)
      : collection =
            Collection.fromJson(json['collection'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        'collection': collection.toJson(),
      };
}

Future<Collection> collectionsFind(String token, int id) async {
  var response = await http.get(
    Uri.parse('${config['backend_url']}/api/collections/$id'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }

  final body = CollectionFindResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)));

  return body.collection;
}

Future<void> collectionsDelete(String token, int id) async {
  var response = await http.delete(
    Uri.parse('${config['backend_url']}/api/collections/$id'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}
