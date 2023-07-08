import 'package:flutter/material.dart';
import 'dart:async';
import 'package:glass/glass.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:io';
// import img to get image resolution
import 'package:image_size_getter/image_size_getter.dart';
import 'package:flutter/foundation.dart'
    show consolidateHttpClientResponseBytes;
import 'package:flutter/services.dart';
// win32
import 'package:win32/win32.dart' as win32;

// button widget
class MyElevatedButton extends StatefulWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;

  MyElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
    this.width,
    this.height = 44.0,
    this.gradient = const LinearGradient(colors: [Colors.cyan, Colors.indigo]),
  }) : super(key: key);

  @override
  _MyElevatedButtonState createState() => _MyElevatedButtonState();
}

class _MyElevatedButtonState extends State<MyElevatedButton> {
  @override
  // final BorderRadiusGeometry? borderRadius;
  // final double? width;
  // final double height;
  // final Gradient gradient;
  // final VoidCallback? onPressed;
  // final Widget child;

  // _MyElevatedButtonState({
  //   Key? key,
  //   required this.onPressed,
  //   required this.child,
  //   this.borderRadius,
  //   this.width,
  //   this.height = 44.0,
  //   this.gradient = const LinearGradient(colors: [Colors.cyan, Colors.indigo]),
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(0);
    final width = widget.width ?? double.infinity;
    final height = widget.height;
    final gradient = widget.gradient;
    final onPressed = widget.onPressed;
    final child = widget.child;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}

// transparent button widget with gradient border and text
class outlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? btnColor;
  final TextStyle? textStyle;
  final double width;
  final double height;
  final double borderWidth;
  final double radius;

  const outlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.btnColor = Colors.white,
    this.textStyle,
    this.width = 200,
    this.height = 50,
    this.borderWidth = 2,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      // decoration: BoxDecoration(
      //   gradient: gradient,
      //   borderRadius: BorderRadius.circular(radius),
      // ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: const Color.fromARGB(0, 213, 196, 196),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(
              color: btnColor!,
              style: BorderStyle.solid,
              width: borderWidth,
            ),
          ),
        ),
        child: Text(
          text,
          style: textStyle ??
              const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

// background image widget
class BaseLayout extends StatelessWidget {
  const BaseLayout({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("./images/img.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: null /* add child content here */,
      ),
    );
  }
}

// setting page widget
// got 4 setting options
// 1. set board link
// 2. how many images to show
// 3. set image size
// 4. every how many minutes to change image
// then add it to"assets/setting.json"

bool _checkFileExists(String path) {
  return File(path).existsSync();
}

String getUserPath() {
  Map<String, String> envVars = Platform.environment;
  String userPath = envVars['USERPROFILE']!;
  return userPath;
}

void showDataAlert(context) async {
  // check if there is setting.json file in assets

  if (!_checkFileExists("assets/setting.json")) {
    // if not, create one
    makeSettingFile();
  }
  File file = File("assets/setting.json");

  var setting = jsonDecode(file.readAsStringSync());

  showDialog(
      context: context,
      barrierColor: Color.fromARGB(0, 0, 0, 0),
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Color.fromARGB(120, 255, 255, 255),
          // shadowColor: Color.fromARGB(0, 0, 0, 0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.only(
            top: 40.0,
          ),
          title: const Text(
            "Settings",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          content: Container(
            height: 400,
            width: 1000,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // set board link text input and make the text in the left
                        const Text(
                          "Set Board Link",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // get the board link from user and save it to setting.json
                        SizedBox(
                          width: 250,
                          child: TextFormField(
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.link),
                              border: OutlineInputBorder(),
                              labelText: 'Board Link',
                              hintText: 'https://www.pinterest.com/***/***',
                              counterText: "https://www.pinterest.com/***/***",
                              counterStyle: TextStyle(
                                fontSize: 9,
                              ),
                            ),
                            initialValue: setting["boardLink"],
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                            onChanged: (value) {
                              setting["boardLink"] = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // set image number text input and make the text in the left
                        const Text(
                          "Image Number",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 200,
                          height: 70,
                          child: MySlider(
                              oldSize:
                                  double.parse(setting["imageNum"].toString()),
                              onChanged: (value) {
                                setting["imageNum"] = value;
                              }),
                          // get the image number from user and save it to setting.json
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // set image size text input and make the text in the left
                        const Text(
                          "Image Size",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(children: [
                          SizedBox(
                            width: 100,
                            height: 70,
                            child: TextFormField(
                              // the text must be number
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Width',
                                hintText: '1920',
                                counterText: '1920',
                                counterStyle: TextStyle(
                                  fontSize: 9,
                                ),
                              ),
                              initialValue: setting["imageSize"][0].toString(),
                              onChanged: (value) {
                                setting["imageSize"] = [
                                  int.parse(value),
                                  setting["imageSize"][1]
                                ];
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 100,
                            height: 70,
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                // suffixIcon: const Icon(Icons.image),
                                border: OutlineInputBorder(),
                                labelText: 'Height',
                                hintText: '1080',
                                counterText: '1080',
                                counterStyle: TextStyle(
                                  fontSize: 9,
                                ),
                              ),
                              initialValue: setting["imageSize"][1].toString(),
                              onChanged: (value) {
                                setting["imageSize"] = [
                                  setting["imageSize"][0],
                                  int.parse(value)
                                ];
                              },
                            ),

                            // get the image size from user and save it to setting.json
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // set change time text input and make the text in the left
                        Text(
                          "Changes every",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        // drop down menu to choose the time
                        SizedBox(
                          width: 80,
                          height: 38,
                          child: DropdownButtonFormField(
                            decoration: const InputDecoration(
                                // border: OutlineInputBorder(),
                                // labelText: 'Time',
                                // hintText: 'Time',
                                ),
                            value: setting["changeTime"],
                            onChanged: (value) {
                              setting["changeTime"] = value.toString();
                            },
                            items: <String>[
                              'login',
                              'hour',
                              'day',
                              'week',
                              'month',
                              'never'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // set image size text input and make the text in the left
                      const Text(
                        "recommended",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // SizedBox(
                      //   height: 2,
                      // ),
                      // switch to choose if the app will run on startup or not
                      const SwitchExample(),
                      // hint text
                      Text(
                        "change recommended wallpaper\ndepending on board link",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey[700],
                        ),
                        // make the text in the center
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () async {
                if (setting["boardLink"] == "") {
                  setting["boardLink"] =
                      "https://www.pinterest.com/mosssaige/desktop-wallpaper-art/";
                }
                if (setting["imageNum"] == "") {
                  setting["imageNum"] = 10;
                }

                Navigator.pop(context);

                setting["recommended"] =
                    jsonDecode(File("assets/setting.json").readAsStringSync())[
                        "recommended"];

                // Get board id
                var response = await http.get(Uri.parse(setting["boardLink"]));
                var html = response.body;
                setting["board_id"] =
                    html.split('board_id=')[1].split('\\"')[1];

                // save setting
                file.writeAsStringSync(jsonEncode(setting));
              },
              child: const Text(
                "save",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ).asGlass(frosted: true);
      });
}

class SwitchExample extends StatefulWidget {
  const SwitchExample({
    Key? key,
  }) : super(key: key);

  @override
  _SwitchExampleState createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  @override
  File file = File("assets/setting.json");
  var light =
      jsonDecode(File("assets/setting.json").readAsStringSync())["recommended"];
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: const Color.fromARGB(255, 24, 165, 26),
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
        // add the value to setting.json
        var setting = jsonDecode(file.readAsStringSync());
        setting["recommended"] = value;
        file.writeAsStringSync(jsonEncode(setting));
      },
    );
  }
}

class MySlider extends StatefulWidget {
  double oldSize;
  final double max;
  final double min;
  final int divisions;
  final String? suffixLabel;
  Function(double) onChanged;

  MySlider(
      {Key? key,
      this.oldSize = 200,
      required this.onChanged,
      this.max = 200.0,
      this.min = 10.0,
      this.divisions = 19,
      this.suffixLabel = ""})
      : super(key: key);

  @override
  State<MySlider> createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
        value: widget.oldSize,
        max: widget.max,
        min: widget.min,
        divisions: widget.divisions,
        onChanged: (double value) {
          setState(() {
            widget.oldSize = value;
          });
          widget.onChanged(value);
        },
        // view 2 decimal places
        label: "${widget.oldSize.toStringAsFixed(1)} ${widget.suffixLabel}");
  }
}

// get image resolution without downloading it using image getter and http
/// get image http or local image
/// return image width and height
Future<List<int>> getImageSize(String url) async {
  WidgetsFlutterBinding.ensureInitialized();

  // check if the url is local or not
  if (url.contains("http")) {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    final image = await decodeImageFromList(bytes);

    return [image.width, image.height];
  } else {
    // get size of local image
    final bytes = File(url).readAsBytesSync();
    final image = await decodeImageFromList(bytes);

    return [image.width, image.height];
  }
}

void makeSettingFile() {
  // make setting.json file if it doesn't exist
  File file = File("assets/setting.json");
  file.createSync();

  // and write the default setting
  file.writeAsStringSync(
      '{"boardLink":"https://www.pinterest.com/mosssaige/desktop-wallpaper-art/","board_id":"51017476968205679","imageNum":10,"imageSize": [1920, 1080],"changeTime":"never", "lastImage":"https://i.pinimg.com/originals/8f/29/ab/8f29ab1660348242aa17383322398e2a.jpg","lastChange":"2023-07-04 07:54:21.530205","recommended":false}');
}

// // make the app run on startup
// void makeRunOnStartup() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final startup = FlutterWindowsStartup();
//   await startup.enableLaunchAtStartup();
// }

