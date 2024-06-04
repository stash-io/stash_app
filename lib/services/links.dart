import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:stash_app/config.dart';

class Link {
  String title;
  String description;
  String url;
  bool published;
  int userId;
  int? collectionId;
  int id;

  Link(this.title, this.description, this.url, this.published, this.userId,
      this.collectionId, this.id);

  Link.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        url = json['url'] as String,
        published = json['published'] as bool,
        userId = json['userId'] as int,
        collectionId = json['collectionId'] as int?,
        id = json['id'] as int;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'url': url,
        'published': published,
        'userId': userId,
        'collectionId': collectionId,
        'id': id
      };
}

Future<void> linksCreate(String token, String title, String description,
    String url, bool published) async {
  var response = await http.post(
      Uri.parse('${config['backend_url']}/api/links/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "title": title,
        "description": description,
        "url": url,
        "published": published,
        "collectionId": null
      }));

  if (response.statusCode != 201) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}

class LinkListResponse {
  List<Link> links;

  LinkListResponse(this.links);

  LinkListResponse.fromJson(Map<String, dynamic> json)
      : links = (json['links'] as List<dynamic>)
            .map((e) => Link.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {
        'links': links.map((e) => e.toJson()).toList(),
      };
}

Future<List<Link>> linksList(String token) async {
  var response = await http.get(
    Uri.parse('${config['backend_url']}/api/links/list'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    final message = "${response.statusCode} ${response.body}";
    throw Exception(message);
  }

  final body =
      LinkListResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

  return body.links;
}

class LinkFindResponse {
  Link link;

  LinkFindResponse(this.link);

  LinkFindResponse.fromJson(Map<String, dynamic> json)
      : link = Link.fromJson(json['link'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        'link': link.toJson(),
      };
}

Future<Link> linksFind(String token, int id) async {
  var response = await http.get(
    Uri.parse('${config['backend_url']}/api/links/$id'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }

  final body =
      LinkFindResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

  return body.link;
}

Future<void> linksDelete(String token, int id) async {
  var response = await http.delete(
    Uri.parse('${config['backend_url']}/api/links/$id'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}
