import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html1;
import 'dart:convert';

import '../models/functions.dart';
import 'thread_class.dart';

class ThreadPosts with ChangeNotifier {
  List<ThreadClass> _threadPosts = [];

  List<ThreadClass> get threadPosts {
    return _threadPosts;
  }

  String _filteringDescription(String? text) {
    if (text == null) {
      return '';
    }
    String description = text;
    description = Functions.filteringTextReplace(description, '<br><br>', '\n');
    description = Functions.filteringTextReplace(description, '<br>', '\n');
    return html1.parse(description).body!.text;
  }

  String _filteringTitle(String? text) {
    if (text == null) {
      return '';
    }
    String title = text;
    return html1.parse(title).body!.text;
  }

  Future<void> fetchAndSetThreadPosts(String boardTag, int opId) async {
    final url = Uri.parse('https://a.4cdn.org/$boardTag/thread/$opId.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List listOfPosts = (extractedData['posts'] as List);
      List<ThreadClass> loadedPostsThread = [];
      Map<String,List> postReplies = {};
      for (var post in listOfPosts) {
        //attachment details
        int imageWidth = 0;
        int imageHeight = 0;
        String attachmentSize = '';
        String fileName = '';
        String fileType = '';

        String imageUrlSmall = '';
        if (!(post['tim'] == null || post['ext'] == null)) {
          imageUrlSmall = 'https://i.4cdn.org/$boardTag/${post['tim']}s.jpg';
        }

        String attachmentUrl = '';
        if (!(post['tim'] == null || post['ext'] == null)) {
          attachmentUrl =
              'https://i.4cdn.org/$boardTag/${post['tim']}${post['ext']}';
          imageWidth = post['w'];
          imageHeight = post['h'];
          fileName = post['filename'];
          fileType = post['ext'];
          attachmentSize = Functions.formatBytes(post['fsize'], 1);
        }

        //filtering title
        String title = _filteringTitle(post['sub']);

        int replies = 0;
        if (post['replies'] != null) {
          replies = post['replies'];
        }

        int images = 0;
        if (post['images'] != null) {
          images = post['images'];
        }

        int opId = 0;
        if (post['resto'] != null) {
          opId = post['resto'];
        }
        int lastReplyTimestamp = 0;
        if (post['last_replies'] != null)
          lastReplyTimestamp = (post['last_replies']
              as List)[(post['last_replies'] as List).length - 1]['time'];

        // if(post['com']!= null){
        //   print(_filteringDescription(post['com']).contains('>>'));
        // }
        // TODO: replies map
        loadedPostsThread.add(
          ThreadClass(
            id: post['no'],
            name: post['name'],
            title: title,
            replies: replies,
            images: images,
            description: post['com'],
            imageUrlSmall: imageUrlSmall,
            attachmentUrl: attachmentUrl,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            fileSize: attachmentSize,
            fileName: fileName,
            fileType: fileType,
            filteredDescription: _filteringDescription(post['com']),
            boardTag: boardTag,
            timestamp: post['time'],
            dateAndTime: Functions.converterFromTimestampToFormattedDateTime(
                post['time']),
            opId: opId,
            lastReplyTimestamp: lastReplyTimestamp,
            postReplies: postReplies,
          ),
        );
      }

      _threadPosts = loadedPostsThread;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
