import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';
import 'dart:math';
import 'myclass.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MyApp(title: 'LockScreen'),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.title}) : super(key: key);

  String imageurl =
      'https://i.pinimg.com/564x/34/db/80/34db803a43771add5707601d655193b5.jpg';

  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        foregroundDecoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(177, 0, 0, 0),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0, 0.4],
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: NetworkImage(imageurl),
            opacity: 0.8,

            fit: BoxFit.cover,
            // fade top to bottom
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Change Lock Screen Wallpaper',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // make 2 buttons in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyElevatedButton(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 159, 212),
                        Color.fromARGB(221, 54, 22, 142)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    width: 250,
                    height: 60,
                    child: const Text('Change Wallpaper',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    onPressed: () {
                      String newimageUrl = changeLockScreenWallpaper();

                      if (newimageUrl == "setting.json not found") {
                        // ask user to send bored link
                        // if user send link, save it to file
                        print("no link");
                      } else {
                        // change app background image to new image
                        // setState(() {
                        //   imageUrl = newimageUrl;
                        // });
                      }

                      // balck fade effect

                      // change app background image to new image
                      // setState(() {});
                    },
                  ),
                  const SizedBox(width: 15),

                  // make a button transparent inside and colored border

                  outlineButton(
                    btnColor: const Color.fromARGB(200, 0, 159, 212),
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                    width: 100,
                    height: 55,
                    borderWidth: 2,
                    radius: 5,
                    text: "settings",
                    onPressed: () {
                      showDataAlert(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@override
String changeLockScreenWallpaper() {
  print("pressed");
  String imageUrl =
      "https://i.pinimg.com/474x/df/e3/fe/dfe3fe146fc0d995c06e07e70520bc03.jpg";

  String image = pickRandomImage();
  return image;
//   // get path to C:\Users\faisa\Documents\lockscreen
//   final home = Directory(Platform.environment['USERPROFILE']!).path +
//  '\\LockScreenImage';
//   print(home);

//   // get all files in the directory
//   final files = await Directory(home).list().toList();
//   for (var file in files) {
//     print(file);
//   }
}

String pickRandomImage() {
  // check if there is file called "./assets/setting.json"
  // if not ask user to send a bored link
  // if yes read the file and get the bored link
  final file = File("./assets/setting.json");
  if (!file.existsSync()) {
    // ask user to send bored link
    // if user send link, save it to file
    return "setting.json not found";
  }

  // setting.json = {"boardLink":"https://www.pinterest.com/***/**","imageNum":70.0,"imageSize":[2232, 1014],"changeTime":38.767605633802816}
  // get bored link
  // get number of images
  final boredLink = jsonDecode(file.readAsStringSync())["boardLink"];
  final numberOfImages = jsonDecode(file.readAsStringSync())["imageNum"];
  final imageSize = jsonDecode(file.readAsStringSync())["imageSize"];
  // board name = foraiandml/lockscreen
  // from .com/ to the end
  final boardName = boredLink.split(".com/")[1];
  print(boardName);

  // url = boardName + "/feed.rss"
  final link =
      "https://www.pinterest.com/resource/BoardFeedResource/get/?source_url=$boardName&data={%22options%22:{%22board_id%22:%22$boardName%22,%22page_size%22:$numberOfImages,%22field_set_key%22:%22unauth_react%22,%22sort%22:%22default%22,%22layout%22:%22default%22},%22context%22:{}}";

  print(link);

  // get http response
  final response = http.get(Uri.parse(link));
  return "https://i.pinimg.com/474x/df/e3/fe/dfe3fe146fc0d995c06e07e70520bc03.jpg";
}
