import 'dart:math';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/thread_class.dart';

class Functions {
  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  // static String filteringTextDeleteBetween(
  //     String start, String end, String text, var pat) {
  //   return '';
  // }

  static String getTextBetween(String text, String start, String end) {
    final startIndex = text.indexOf(start);
    final endIndex = text.indexOf(end, startIndex + start.length);
    return text.substring(startIndex + start.length, endIndex);
  }

  static String filteringTextReplace(
      String text, String old, String replacement) {
    return text.replaceAll(old, replacement);
  }

  static String converterFromTimestampToFormattedDateTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formattedDate = DateFormat('yyyy/MM/dd, h:mm a').format(date);
    return formattedDate;
  }

  static String convertFromTimestampToTimeAgo(int timestamp) {
    return timeago
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
  }

  static Future<void> saveImage(ThreadClass post) async {
    final imgUrl = Uri.parse(post.attachmentUrl);
    var response = await http.get(imgUrl);

    // Get the image name
    final imageName = path.basename(post.attachmentUrl);
    // Get the document directory path
    final appDir = await path_provider.getApplicationDocumentsDirectory();

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);

    // Directory documentDirectory = await getApplicationDocumentsDirectory();
    // File file = new File(p.join(documentDirectory.path, 'imagetest.png'));
    // file.writeAsBytesSync(response.bodyBytes);
  }

  static Future<bool?> saveNetworkImage(String path) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      return await GallerySaver.saveImage(path, albumName: 'Four Channer');
    }
    return Future.value(false);
  }

  static Future<bool?> saveNetworkVideo(String path) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      return await GallerySaver.saveVideo(path, albumName: 'Four Channer');
    }
    return Future.value(false);
  }

  static void share(String text) {
    Share.share(text);
  }
}
