import 'package:flutter/material.dart';

class ThreadClass with ChangeNotifier {
  final int id;
  final String name;
  final String title;
  final int replies;
  final int images;
  final String imageUrlSmall;
  final String attachmentUrl;
  final String? description;
  final String filteredDescription;
  final String boardTag;
  final int opId;
  final int timestamp;
  final int imageWidth ;
  final int imageHeight ;
  final String fileSize;
  final String fileName ;
  final String fileType ;
  final String dateAndTime;
  final int lastReplyTimestamp;
  final Map postReplies;
  bool dead = false;

  ThreadClass({
    required this.id,
    required this.name,
    required this.title,
    required this.replies,
    required this.images,
    required this.description,
    required this.imageUrlSmall,
    required this.attachmentUrl,
    required this.filteredDescription,
    required this.boardTag,
    required this.timestamp,
    required this.imageWidth,
    required this.imageHeight,
    required this.fileSize,
    required this.fileName,
    required this.fileType,
    required this.dateAndTime,
    required this.opId,
    required this.lastReplyTimestamp,
    required this.postReplies,
  });

  void threadIsDead(){
    dead = true;
  }

}
