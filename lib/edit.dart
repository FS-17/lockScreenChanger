import 'dart:io';
import 'package:image/image.dart' as img;

// edit images
void main() async {
  // open image
  final path = 'assets/k.jpg';

  // get image size
  img.Image? image = img.decodeImage(File(path).readAsBytesSync());
  int height = image!.height;

  int width = (height * 16) ~/ 9;

  myResizeImage(imagepath: path, newW: width, newH: height);
}

void myResizeImage(
    {required String imagepath, int newW = 1920, int newH = 1080}) async {
  // read image
  final oldimage = img.decodeImage(File(imagepath).readAsBytesSync());

  // getpixel color
  var wantColor = oldimage!.getPixel(5, 10);

  // get pixel color
  final newImage =
      img.Image(width: newW, height: newH, backgroundColor: wantColor);

  int startPixel = (newImage.width - oldimage.width) ~/ 2;

  var last = 0;
  // make for loop to copy old image to new image with new size and start pixel to center image
  for (int x = 0; x < newImage.width; x++) {
    for (int y = 0; y < newImage.height; y++) {
      try {
        if (x < startPixel) {
          // the left side
          newImage.setPixel(x, y, oldimage.getPixel(0, y));
          last = 1;
        } else if (x >= (newImage.width - startPixel - 1)) {
          // the right side
          newImage.setPixel(x, y, oldimage.getPixel(oldimage.width - 1, y));
          last = 2;
        } else {
          // the center
          newImage.setPixel(x, y, oldimage.getPixel(x - startPixel, y));
          last = 3;
        }
      } catch (e) {
        print(last);
        print(x - startPixel);
        print(y);
        print(oldimage.width);
        print(oldimage.height);
      }
    }
  }

  // Encode the resulting image to the PNG image format.
  final jpg = img.encodeJpg(newImage);
  // Write the PNG formatted data to a file.
  await File(imagepath).writeAsBytes(jpg);
}
