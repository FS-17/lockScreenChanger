// print all files in the directory using just dart code

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
// ui
import 'dart:ui' as ui;
//image size getter
import 'package:image_size_getter/image_size_getter.dart';
// material
import 'package:flutter/material.dart';

void main() {
  print("start");

  // get image size
  getImageSize(
          'https://i.pinimg.com/474x/df/e3/fe/dfe3fe146fc0d995c06e07e70520bc03.jpg')
      .then((value) => print(value));
}

// get image resolution from url
Future<List<int>> getImageSize(String url) async {
  WidgetsFlutterBinding.ensureInitialized();

  final request = await HttpClient().getUrl(Uri.parse(url));
  final response = await request.close();
  final bytes = await consolidateHttpClientResponseBytes(response);
  final image = await decodeImageFromList(bytes);
  return [image.width, image.height];
}
