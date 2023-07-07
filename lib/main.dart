import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:win32/win32.dart';
import 'dart:math';
import 'myclass.dart';
import 'edit.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:glass/glass.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MyApp(title: 'LockScreen Changer'),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  var ImageBG =
      Image.file(File('${getUserPath()}\\LockScreenImage\\img.jpg')).image;
  bool _visible = true;

  // ramdom color number between 0 and 5
  int randomColor = Random().nextInt(6);

  // list of colors
  List<Color> colors1 = const [
    Color.fromARGB(255, 46, 49, 146),
    Color.fromARGB(255, 212, 20, 90),
    Color.fromARGB(255, 102, 45, 140),
    Color.fromARGB(255, 97, 67, 133),
    Color.fromARGB(255, 78, 102, 255),
    Color.fromARGB(255, 9, 32, 63),
  ];
  List<Color> colors2 = const [
    Color.fromARGB(255, 27, 255, 255),
    Color.fromARGB(255, 251, 177, 59),
    Color.fromARGB(255, 237, 30, 120),
    Color.fromARGB(255, 81, 99, 149),
    Color.fromARGB(255, 146, 239, 253),
    Color.fromARGB(255, 83, 120, 149),
  ];

  // final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // and gradient color as background
        decoration: BoxDecoration(
          color: Colors.black,
          gradient: LinearGradient(
            colors: [
              colors1[randomColor],
              colors2[randomColor],
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            // If the widget is visible, animate to 0.0 (invisible).
            // If the widget is hidden, animate to 1.0 (fully visible).
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            // The green box must be a child of the AnimatedOpacity widget.

            child: Container(
              foregroundDecoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(185, 0, 0, 0),
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
                  image: ImageBG,
                  fit: BoxFit.cover,
                ),
              ),
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
                        gradient: LinearGradient(
                          colors: [
                            colors1[randomColor],
                            colors2[randomColor],
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
                        onPressed: () async {
                          // black color Fade out the image to black
                          setState(() {
                            _visible = false;
                          });

                          String newimageUrl =
                              await changeLockScreenWallpaper();
                          String ImagePath = await getUserPath() +
                              "\\LockScreenImage\\img.jpg";

                          // // wait 1 second to make sure the image is loaded
                          // await Future.delayed(const Duration(seconds: 1));

                          setState(() {
                            ImageBG = Image.network(newimageUrl).image;
                          });

                          List<int> imageBytes = await getImageSize(ImagePath);
                          print(imageBytes);
                          double ratio = imageBytes[0] / imageBytes[1];

                          if (ratio < 1) {
                            int newH = imageBytes[1];
                            int newW = (imageBytes[1] * 16) ~/ 9;
                            myResizeImage(
                                imagepath: ImagePath, newW: newW, newH: newH);
                          }

                          // setState(() {
                          //   ImageBG = Image.file(File(getUserPath() +
                          //           "\\LockScreenImage\\img.jpg"))
                          //       .image;
                          // });

                          // change lock screen wallpaper

                          File file = File("./assets/setting.json");

                          var setting = jsonDecode(file.readAsStringSync());
                          setting["lastImage"] = newimageUrl;
                          setting["lastChange"] = DateTime.now().toString();

                          file.writeAsStringSync(jsonEncode(setting));

                          // Fade in the image
                          // wait 1 second to make sure the image is loaded
                          // await Future.delayed(const Duration(seconds: 1));
                          setState(() {
                            _visible = true;
                          });
                        },
                      ),
                      const SizedBox(width: 15),

                      // make a button transparent inside and colored border

                      outlineButton(
                        btnColor: colors1[randomColor],
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
        ),
      ),
    );
  }
}

@override
Future<String> changeLockScreenWallpaper() async {
  final file = File("./assets/setting.json");
  if (!file.existsSync()) {
    makeSettingFile();
  }
  final setting = jsonDecode(file.readAsStringSync());
  // run this function getImagesUrl() to get list of images url and store it in a list
  List<String?> imagesUrls = await getImagesUrl(setting);

  // write the images to assets/images.json file
  File imagesFile = File("./assets/images.json");
  imagesFile.writeAsStringSync(jsonEncode(imagesUrls));

  // get random image url from the list
  String imageUrl = imagesUrls[Random().nextInt(imagesUrls.length)]!;
  var headers = {
    'authority': 'i.pinimg.com',
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'accept-language': 'en-US,en;q=0.9,ar;q=0.8',
    'cache-control': 'max-age=0',
    'if-none-match': '"5650a1c0a8316486f4c65e798b260569"',
    'sec-ch-ua':
        '"Not.A/Brand";v="8", "Chromium";v="114", "Google Chrome";v="114"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
  };

  print("image url: $imageUrl");
  // String imgExt = imageUrl.split('.').last;

  // download the image
  final response = await http.get(Uri.parse(imageUrl), headers: headers);
  final bytes = response.bodyBytes;

  // save the image to a file to user path using path_provider package
  // %USERPROFILE%\lockscreen\img.jpg

  String userpath = getUserPath();

  final img = File('${userpath}\\LockScreenImage\\img.jpg');
  await img.writeAsBytes(bytes);

  return imageUrl;
}

Future<List<String?>> getImagesUrl(setting) async {
  // setting.json = {"boardLink":"https://www.pinterest.com/***/**","imageNum":70.0,"imageSize":[2232, 1014],"changeTime":38.767605633802816}
  // get bored link
  // get number of images
  final boardLink = setting["boardLink"];
  final numberOfImages = setting["imageNum"];
  final imageSize = setting["imageSize"];
  final boardid = setting["board_id"];
  final recommended = setting["recommended"];

  // board name = foraiandml/lockscreen
  final boardName = boardLink.split(".com/")[1];

  // if recommended is true then get recommended images
  if (recommended) {
    final link =
        "https://www.pinterest.com/resource/BoardContentRecommendationResource/get/?source_url=${boardName}%2F_tools%2Fmore-ideas%2F%3Fideas_referrer%3D2&data=%7B%22options%22%3A%7B%22type%22%3A%22board%22%2C%22id%22%3A%22${boardid}%22%2C%22__track__referrer%22%3A%222%22%7D%2C%22context%22%3A%7B%7D%7D";
    print(link);

    // get http response
    final response = await http.get(Uri.parse(link));

    // get image urls start with "https://i.pinimg.com/originals/" end before '"'
    final imageUrls = RegExp(r'https://i.pinimg.com/originals/.*?(?=")')
        .allMatches(response.body)
        .map((match) => match.group(0))
        .toList();

    print("there is ${imageUrls.length} images");

    return imageUrls;
  } else {
    final link =
        "https://www.pinterest.com/resource/BoardFeedResource/get/?source_url=$boardName&data={%22options%22:{%22board_id%22:%22$boardid%22,%22page_size%22:$numberOfImages,%22field_set_key%22:%22unauth_react%22,%22sort%22:%22default%22,%22layout%22:%22default%22},%22context%22:%7B%7D%7D";
    print(link);

    // get http response
    final response = await http.get(Uri.parse(link));

    // get image urls start with "https://i.pinimg.com/originals/" end before '"'
    final imageUrls = RegExp(r'https://i.pinimg.com/originals/.*?(?=")')
        .allMatches(response.body)
        .map((match) => match.group(0))
        .toList();

    print("there is ${imageUrls.length} images");

    return imageUrls;
  }
}
