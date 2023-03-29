import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html1;
import 'dart:convert';

import '../models/functions.dart';
import 'thread_class.dart';

class Threads with ChangeNotifier {
  List<ThreadClass> _threads = [
    // Board(title: 'test', board: 'hmh'),
    // Board(title: 'test2', board: 'mah'),
    // Board(title: 'test3', board: 'h'),
  ];

  List<ThreadClass> get threads {
    return _threads;
  }

  String _filteringDescription(String? text) {
    if (text == null) {
      return '';
    }
    String description = text;
    description = Functions.filteringTextReplace(description, '<br><br>', '\n');
    description = Functions.filteringTextReplace(description, '<br>', '\n');
    return html1.parse(description).body!.text;
    ;
    ;
  }

  String _filteringTitle(String? text) {
    if (text == null) {
      return '';
    }
    String title = text;
    return html1.parse(title).body!.text;
    ;
  }

  Future<void> fetchAndSetThreads(String boardTag) async {
    final url = Uri.parse('https://a.4cdn.org/$boardTag/catalog.json');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as List<dynamic>;
      List<ThreadClass> loadedThreads = [];
      List tempThreads = [];
      for (Map<String, dynamic> page in extractedData) {
        List pageThreads = page['threads'] as List;
        for (var thread in pageThreads) {
          //remove pages
          tempThreads.add(thread);
        }
      }
      for (var thread in tempThreads) {
        int imageWidth = 0;
        int imageHeight = 0;
        String attachmentSize = '';
        String fileName = '';
        String fileType = '';

        String imageUrlSmall = '';
        if (!(thread['tim'] == null || thread['ext'] == null)) {
          imageUrlSmall = 'https://i.4cdn.org/$boardTag/${thread['tim']}s.jpg';
        }

        String attachmentUrl = '';
        if (!(thread['tim'] == null || thread['ext'] == null)) {
          attachmentUrl =
              'https://i.4cdn.org/$boardTag/${thread['tim']}${thread['ext']}';
          imageWidth = thread['w'];
          imageHeight = thread['h'];
          fileName = thread['filename'];
          fileType = thread['ext'];
          attachmentSize = Functions.formatBytes(thread['fsize'], 1);
        }

        //filtering title
        String title = _filteringTitle(thread['sub']);

        int replies = 0;
        if (thread['replies'] != null) {
          replies = thread['replies'];
        }

        int images = 0;
        if (thread['images'] != null) {
          images = thread['images'];
        }

        int opId = 0;
        if (thread['resto'] != null) {
          opId = thread['resto'];
        }
        int lastReplyTimestamp = 0;
        if(thread['last_replies'] != null)
          lastReplyTimestamp = (thread['last_replies'] as List)[(thread['last_replies'] as List).length -1]['time'];

        loadedThreads.add(
          ThreadClass(
            id: thread['no'],
            name: thread['name'],
            title: title,
            imageUrlSmall: imageUrlSmall,
            attachmentUrl: attachmentUrl,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            fileSize: attachmentSize,
            fileName: fileName,
            fileType: fileType,
            description: thread['com'],
            images: thread['images'],
            replies: thread['replies'],
            filteredDescription: _filteringDescription(thread['com']),
            boardTag: boardTag,
            timestamp: thread['time'],
            dateAndTime: Functions.converterFromTimestampToFormattedDateTime(
                thread['time']),
            opId: opId,
            lastReplyTimestamp: lastReplyTimestamp,
            postReplies: {},
          ),
        );
      }
      _threads = loadedThreads;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<bool> isThreadStillAlive(ThreadClass thread) async {
    final url = Uri.parse(
        'https://a.4cdn.org/${thread.boardTag}/thread/${thread.id}.json');
    try {
      final response = await http.get(url);
      return (response.statusCode >= 200 && response.statusCode < 300);
    } catch (error) {
      throw error;
    }
  }
}
