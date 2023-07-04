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
// import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MyApp(title: 'LockScreen'),
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
  var _ImageBG =
      Image.file(File('${getUserPath()}\\LockScreenImage\\img.jpg')).image;

  // final String title;
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
            image: _ImageBG,
            fit: BoxFit.cover,
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
                    onPressed: () async {
                      String newimageUrl = await changeLockScreenWallpaper();
                      File file = File("./assets/setting.json");

                      var setting = jsonDecode(file.readAsStringSync());
                      setting["lastImage"] = newimageUrl;
                      setting["lastChange"] = DateTime.now().toString();

                      file.writeAsStringSync(jsonEncode(setting));

                      // change app background image to new image
                      setState(() {
                        _ImageBG = Image.file(File(
                                '${getUserPath()}\\LockScreenImage\\img.jpg'))
                            .image;
                      });
                      // view the image
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
Future<String> changeLockScreenWallpaper() async {
  // run this function getImagesUrl() to get list of images url and store it in a list
  List<String?> imagesUrls = await getImagesUrl();

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

  final file = File('${userpath}\\LockScreenImage\\img.jpg');
  await file.writeAsBytes(bytes);

  return imageUrl;
}

Future<List<String?>> getImagesUrl() async {
  // check if there is file called "./assets/setting.json"
  // if not ask user to send a bored link
  // if yes read the file and get the bored link
  final file = File("./assets/setting.json");
  if (!file.existsSync()) {
    makeSettingFile();
  }

  // setting.json = {"boardLink":"https://www.pinterest.com/***/**","imageNum":70.0,"imageSize":[2232, 1014],"changeTime":38.767605633802816}
  // get bored link
  // get number of images
  final boardLink = jsonDecode(file.readAsStringSync())["boardLink"];
  final numberOfImages = jsonDecode(file.readAsStringSync())["imageNum"];
  final imageSize = jsonDecode(file.readAsStringSync())["imageSize"];
  final boardid = jsonDecode(file.readAsStringSync())["board_id"];

  // board name = foraiandml/lockscreen
  final boardName = boardLink.split(".com/")[1];

  final link =
      "https://www.pinterest.com/resource/BoardFeedResource/get/?source_url=$boardName&data={%22options%22:{%22board_id%22:%22$boardid%22,%22page_size%22:$numberOfImages,%22field_set_key%22:%22unauth_react%22,%22sort%22:%22default%22,%22layout%22:%22default%22},%22context%22:%7B%7D%7D";

  // print(link);

  // get http response
  final response = await http.get(Uri.parse(link));

  // get image urls start with "https://i.pinimg.com/originals/" end before '"'
  final imageUrls = RegExp(r'https://i.pinimg.com/originals/.*?(?=")')
      .allMatches(response.body)
      .map((match) => match.group(0))
      .toList();

  return imageUrls;
}
